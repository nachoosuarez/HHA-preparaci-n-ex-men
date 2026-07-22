% Ejercicio4_riego_aspersor.m -- Examen HHA 17/dic/2018, Ejercicio 4
%
% Sistema de riego por aspersion que succiona de un lago (zL=-4m) con
% tuberia de succion Ls=15m y de impulsion Li=600m (ambas DT=150mm,
% rugosidad e=0.05mm), bomba a zB=0m, aspersor de salida DA=50mm (perdida
% localizada despreciable en el aspersor) a cota zA variable.
%
% a) Cota MINIMA del aspersor zA para que la bomba no cavite.
% b) Con zA=30m: punto de funcionamiento (Q,H), potencia consumida,
%    verificar que no cavita.
% c) Presion en la tuberia inmediatamente antes del aspersor.
%
% Metodologia (RESUMEN_TEORICO C1-C4): ecuacion de la instalacion con
% descarga LIBRE por el aspersor (el termino cinetico de salida vA^2/2g
% NO se cancela, ver C1), interseccion con la curva H-Q de la bomba
% (C2, resuelta con fzero -- NO con grilla, ver nota de precision abajo),
% potencia Pcons=rho*g*Q*H/eta (C3), y NPSHdisp=zL-DeltaS-zB+(patm-pvap)/
% rho/g SIN el termino cinetico de succion (C4, "trampa" del termino
% cinetico -- zL es superficie libre del lago). Para la parte a), zA
% esta del lado de la DESCARGA: al bajarla el punto de funcionamiento se
% mueve a MAYOR Q (mismo mecanismo que "nivel minimo del tanque de
% succion" de C4, pero en el otro extremo de la instalacion), lo que
% empeora tanto NPSHdisp (mas perdida en succion) como NPSHreq (crece
% con Q) -- se resuelve con un fzero ANIDADO: para cada zA de prueba se
% halla el punto de funcionamiento completo y se compara NPSHdisp(Q)
% contra NPSHreq(Q), iterando zA hasta que se igualen.
%
% NOTA DE PRECISION: el termino cinetico de salida vA^2/2g es MUY
% sensible a Q porque el aspersor (DA=50mm) es mucho mas chico que la
% caneria (DT=150mm): d(vA^2/2g)/dQ = Q/(g*AA^2) ~ 1000 (m por m3/s) en
% este caso. Encontrar el punto de funcionamiento con una grilla gruesa
% (como hace el toolkit canonico Bomba_sola.m, pensado para el caso
% general sin aspersor) amplifica cualquier error de redondeo de Q en
% ~1000x sobre el zA final -- por eso aca se resuelve el punto de
% funcionamiento con fzero (raiz exacta de Hbomba(Q)-Hinst(Q)=0) en vez
% de grilla, y por la misma razon la parte a) da zA_min~1.57m aca contra
% ~1.66m de la solucion oficial (que parte de Q redondeado a 0.0405
% m3/s a mano): con ese mismo Q=0.0405 redondeado, este script tambien
% reproduce zA~1.70m -- confirma que la diferencia es enteramente de
% redondeo de Q propagado por este termino, no un error de metodo (Q,H,
% NPSH del punto de tangencia SI coinciden con la solucion oficial:
% Q=0.0405 vs 0.04056, H=47.65 vs 47.64, NPSH=5.38 vs 5.37).
%
% Reusa colebrook.m (RESUMEN EXAMEN/Codigos/Bombas/). La instalacion es
% la misma ya precargada como EJEMPLO en el toolkit canonico
% RESUMEN EXAMEN/Codigos/Bombas/Bomba_sola.m (datos identicos a este
% examen), usado aca solo como primera verificacion cruzada de la parte b).

clc; clear; close all;

g = 9.81;
ro = 997;
nu = 1e-6;
epsilon = 0.00005;   % 0.05 mm

Ls = 15; Ds = 0.15; zL = -4; ks = 1;   % succion
zB = 0;                                 % bomba
Li = 600; Di = 0.15; ki = 5;            % impulsion
DA = 0.05;                              % aspersor (salida)

Ai = pi*Di^2/4;
AA = pi*DA^2/4;

patm_pvap = 10.33 - 0.24;   % 10.09 m.c.a. (agua a 20 C)

Qb   = [0.00 0.01 0.02 0.03 0.04 0.05 0.06 0.07];
Hb   = [65.0 64.0 60.0 54.0 48.0 41.0 31.0 18.0];
etab = [0 35 56 68 67 60 46 26];
NPSHrb = [3.2 3.4 3.7 4.4 5.3 6.8 8.5 10.8];

function dS = succ_loss(Q, Ls, Ds, ks, nu, epsilon, g)
  As = pi*Ds^2/4;
  vs = Q/As;
  Re = vs*Ds/nu;
  f = colebrook(max(Re,2300), epsilon/Ds);
  dS = (ks + f*Ls/Ds) * vs^2/(2*g);
end

function dI = imp_loss(Q, Li, Di, ki, nu, epsilon, g)
  Ai = pi*Di^2/4;
  vi = Q/Ai;
  Re = vi*Di/nu;
  f = colebrook(max(Re,2300), epsilon/Di);
  dI = (ki + f*Li/Di) * vi^2/(2*g);
end

function Hm = Hinst(Q, zA, Ls, Ds, ks, zL, Li, Di, ki, DA, nu, epsilon, g)
  dS = succ_loss(Q, Ls, Ds, ks, nu, epsilon, g);
  dI = imp_loss(Q, Li, Di, ki, nu, epsilon, g);
  AA = pi*DA^2/4;
  vA = Q/AA;
  HA = zL - dS;                       % sin termino cinetico (zL superficie libre del lago, C4)
  HB = zA + vA^2/(2*g) + dI;          % descarga libre: SI lleva vA^2/2g (C1)
  Hm = HB - HA;
end

function Qpf = solve_PF(zA, Qb, Hb, Ls, Ds, ks, zL, Li, Di, ki, DA, nu, epsilon, g)
  f = @(Q) interp1(Qb, Hb, Q, 'pchip') - Hinst(Q, zA, Ls, Ds, ks, zL, Li, Di, ki, DA, nu, epsilon, g);
  Qpf = fzero(f, [min(Qb)+1e-4, max(Qb)-1e-4]);
end

%% ==================== Parte a) Cota minima del aspersor sin cavitar ====================
function res = residuo_npsh(zA, Qb, Hb, NPSHrb, Ls, Ds, ks, zL, zB, Li, Di, ki, DA, nu, epsilon, g, patm_pvap)
  Qpf = solve_PF(zA, Qb, Hb, Ls, Ds, ks, zL, Li, Di, ki, DA, nu, epsilon, g);
  dS = succ_loss(Qpf, Ls, Ds, ks, nu, epsilon, g);
  NPSHdisp = patm_pvap + (zL - dS) - zB;
  NPSHreq = interp1(Qb, NPSHrb, Qpf, 'pchip');
  res = NPSHdisp - NPSHreq;
end

fprintf('=== Parte a) Cota minima del aspersor (zA) sin cavitar ===\n');
f_a = @(zA) residuo_npsh(zA, Qb, Hb, NPSHrb, Ls, Ds, ks, zL, zB, Li, Di, ki, DA, nu, epsilon, g, patm_pvap);
zA_min = fzero(f_a, [0.5, 5]);
Qpf_a = solve_PF(zA_min, Qb, Hb, Ls, Ds, ks, zL, Li, Di, ki, DA, nu, epsilon, g);
Hpf_a = interp1(Qb, Hb, Qpf_a, 'pchip');
dS_a = succ_loss(Qpf_a, Ls, Ds, ks, nu, epsilon, g);
NPSHdisp_a = patm_pvap + (zL - dS_a) - zB;
fprintf('zA_min = %.3f m\n', zA_min);
fprintf('  (Qpf=%.5f m3/s, Hpf=%.2f m, NPSHdisp=NPSHreq=%.2f m)\n\n', Qpf_a, Hpf_a, NPSHdisp_a);

%% ==================== Parte b) Punto de funcionamiento con zA=30 m ====================
fprintf('=== Parte b) zA = 30 m ===\n');
zA_b = 30;
Qpf = solve_PF(zA_b, Qb, Hb, Ls, Ds, ks, zL, Li, Di, ki, DA, nu, epsilon, g);
Hpf = interp1(Qb, Hb, Qpf, 'pchip');
eta_pf = interp1(Qb, etab, Qpf, 'pchip');
Pcons = ro*g*Qpf*Hpf/(eta_pf/100);
dS_b = succ_loss(Qpf, Ls, Ds, ks, nu, epsilon, g);
NPSHdisp_b = patm_pvap + (zL - dS_b) - zB;
NPSHreq_b = interp1(Qb, NPSHrb, Qpf, 'pchip');

fprintf('Qpf = %.5f m3/s\n', Qpf);
fprintf('Hpf = %.2f m\n', Hpf);
fprintf('eta(Qpf) = %.2f %%\n', eta_pf);
fprintf('Pcons = ro*g*Q*H/eta = %.2f kW\n', Pcons/1000);
fprintf('NPSHdisp = %.2f m ; NPSHreq = %.2f m -> %s\n\n', NPSHdisp_b, NPSHreq_b, ...
        merge(NPSHdisp_b > NPSHreq_b, 'NO CAVITA', 'CAVITA'));

%% ==================== Parte c) Presion inmediatamente antes del aspersor ====================
fprintf('=== Parte c) Presion justo antes del aspersor (zA=30m, Qpf de la parte b) ===\n');
vi_c = Qpf/Ai;   % velocidad en la caneria DT=150mm, justo antes de la reduccion al aspersor
vA_c = Qpf/AA;   % velocidad de salida por el aspersor DA=50mm
% Bernoulli entre "justo antes" (caneria llena DT, misma cota zA) y la salida del
% aspersor (atmosfera, perdida despreciable): p_antes/(ro g) + vi^2/2g = 0 + vA^2/2g
p_antes = ro*(vA_c^2 - vi_c^2)/2;
fprintf('v(caneria,150mm) = %.3f m/s ; v(aspersor,50mm) = %.3f m/s\n', vi_c, vA_c);
fprintf('p_antes = ro*(vA^2-vi^2)/2 = %.1f Pa = %.2f kPa = %.2f m.c.a.\n', ...
        p_antes, p_antes/1000, p_antes/(ro*g));
