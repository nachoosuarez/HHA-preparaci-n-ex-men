% Ejercicio4_bomba.m -- Examen HHA 16/dic/2019, Ejercicio 4.
% Bomba unica entre tanque inferior (zT1=0) y tanque elevado (zT2=25m,
% zT2=30m en la parte 3), succion+impulsion mismo D=250mm, eps=0.02mm.
% Adaptado de RESUMEN EXAMEN/Codigos/Bombas/Bomba_sola.m (mismo metodo:
% interseccion de la curva de la bomba con la curva de instalacion,
% Colebrook-White para friccion). Requiere colebrook.m (mismo directorio).
addpath(pwd);

function s = merge(c,a,b)
  if c; s=a; else; s=b; end
endfunction
g = 9.81; ro = 1000; nu = 1e-6;
epsilon = 0.02e-3;   % 0.02 mm

% geometria
D  = 0.25;           % m, diametro (succion e impulsion, iguales)
Ls = 25;             % m, largo succion
Lt = 550;            % m, largo TOTAL impulsion
ks = 2.5;            % k succion (valvula de pie + codo)
ki = 1.5;            % k impulsion (incluye descarga al tanque elevado)

z1 = 0;              % cota tanque inferior
zB = 2;               % cota eje de la bomba (parte 1)
z2 = 25;              % cota tanque elevado (parte 1)
p1 = 0; p2 = 0;

% curva de la bomba (tabla del enunciado)
Q     = [0     0.015 0.03  0.045 0.06  0.075 0.09  0.105];
H     = [37    36    35    33    31    27    22    17];
NPSHr = [1.6   1.8   2.2   2.8   3.9   5.5   7.3   9.7];
eta   = [0     35    60    74    77    73    60    35];

function [Qpf,Hpf,eta_pf,NPSHdisp_pf,NPSHr_pf,vs_pf,HA_pf] = punto_func(z1,zB,z2,p1,p2,D,Ls,Lt,ks,ki,epsilon,Q,H,eta,NPSHr,ro,g,nu)
  A = pi*D^2/4;
  Qmalla = linspace(min(Q),max(Q),4000);
  Hb = interp1(Q,H,Qmalla,"pchip");
  Hm = zeros(size(Qmalla));
  NPSHdisp = zeros(size(Qmalla));
  for i=1:length(Qmalla)
    Qi = Qmalla(i);
    v = Qi/A;
    Re = v*D/nu;
    f = colebrook(Re, epsilon/D);
    deltaS = f*Ls*v^2/(2*D*g) + ks*v^2/(2*g);
    HA = z1 + p1/(ro*g) + v^2/(2*g) - deltaS;
    deltaI = f*Lt*v^2/(2*D*g) + ki*v^2/(2*g);
    HB = z2 + p2/(ro*g) + v^2/(2*g) + deltaI;
    Hm(i) = HB - HA;
    NPSHdisp(i) = 10.1 + HA - zB - v^2/(2*g);
  endfor
  [~,idx] = min(abs(Hb-Hm));
  Qpf = Qmalla(idx);
  Hpf = Hb(idx);
  eta_pf = interp1(Q,eta,Qpf,"pchip");
  NPSHr_pf = interp1(Q,NPSHr,Qpf,"pchip");
  NPSHdisp_pf = NPSHdisp(idx);
  vs_pf = Qpf/A;
  Re = vs_pf*D/nu; f = colebrook(Re,epsilon/D);
  HA_pf = z1 + p1/(ro*g) + vs_pf^2/(2*g) - (f*Ls*vs_pf^2/(2*D*g) + ks*vs_pf^2/(2*g));
endfunction

%% ============ PARTE 1 ============
[Qpf,Hpf,eta_pf,NPSHdisp_pf,NPSHr_pf,vs_pf,HA_pf] = punto_func(z1,zB,z2,p1,p2,D,Ls,Lt,ks,ki,epsilon,Q,H,eta,NPSHr,ro,g,nu);
Pcons = ro*g*Qpf*Hpf/(eta_pf/100);

printf("\n===== PARTE 1: punto de funcionamiento (z2=%.0fm, zB=%.0fm) =====\n", z2, zB);
printf("Qpf = %.5f m3/s = %.2f L/s\n", Qpf, Qpf*1000);
printf("Hpf = %.3f m\n", Hpf);
printf("eta(Qpf) = %.2f %%\n", eta_pf);
printf("Potencia consumida = %.3f kW\n", Pcons/1000);
printf("NPSHdisp = %.3f m , NPSHr = %.3f m -> %s\n", NPSHdisp_pf, NPSHr_pf, merge(NPSHdisp_pf>NPSHr_pf,"NO CAVITA","CAVITA"));

%% ============ PARTE 2: maxima cota zB sin cavitar (mismo Qpf, z2=25) ============
margen = NPSHdisp_pf - NPSHr_pf;
zB_max = zB + margen;
printf("\n===== PARTE 2: maxima cota de la bomba sin cavitar =====\n");
printf("NPSHdisp - NPSHr = %.3f m (margen actual, a zB=%.0fm)\n", margen, zB);
printf("Como Hm(Q) NO depende de zB (mismo Qpf,Hpf), NPSHdisp decrece 1:1 con zB.\n");
printf("zB_max = zB + margen = %.2f + %.3f = %.3f m\n", zB, margen, zB_max);

%% ============ PARTE 3: zB=zB_max fijo, z2 sube a 30m ============
z2_new = 30;
[Qpf3,Hpf3,eta_pf3,NPSHdisp_pf3,NPSHr_pf3] = punto_func(z1,zB_max,z2_new,p1,p2,D,Ls,Lt,ks,ki,epsilon,Q,H,eta,NPSHr,ro,g,nu);

printf("\n===== PARTE 3: zB=%.3fm (limite parte 2), z2 sube a %.0f m =====\n", zB_max, z2_new);
printf("Qpf = %.5f m3/s ,  Hpf = %.3f m\n", Qpf3, Hpf3);
printf("NPSHdisp = %.3f m , NPSHr = %.3f m -> %s\n", NPSHdisp_pf3, NPSHr_pf3, merge(NPSHdisp_pf3>NPSHr_pf3,"NO CAVITA","CAVITA"));
