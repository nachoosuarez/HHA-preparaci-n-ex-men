% Ejercicio4_bombas_paralelo_manometro.m — Examen HHA 25/jul/2022, Ej.4.
% Dos bombas IGUALES en paralelo elevan agua desde un lago (z0=-4m) hasta
% un tanque elevado, pasando por succion (D1=110mm,L1=20m,k1=6) comun a
% ambas bombas (cota zA=+0.5m) y luego impulsion (D2=80mm,L2=80m,k2=4).
% Un manometro EN LA IMPULSION, inmediatamente aguas debajo de las
% bombas, mide Pimp=20 m.c.a. Perdidas en el acople entre bombas
% despreciables.
%
% A diferencia de Bombas_paralelo.m (que asume conocidas las cotas/
% presiones en AMBOS extremos, lago y tanque, y resuelve por interseccion
% de curvas), aca el extremo de aguas abajo NO es un tanque de cota
% conocida sino un MANOMETRO que da directamente la carga justo despues
% de las bombas -- se resuelve como Bomba_sola.m/Bomba_manometros.m pero
% con succion por tuberia (no por manometro) e impulsion por manometro
% (no por tuberia): la ecuacion de balance de energia entre el lago y el
% manometro fija Q_inst directamente (no hace falta conocer z1 para
% este paso); z1 (cota del tanque) se despeja DESPUES con una segunda
% ecuacion de energia entre el manometro y el tanque, usando ahi si la
% perdida de la tuberia de impulsion (L2,D2,k2).
%
% Requiere colebrook.m (mismo directorio "RESUMEN EXAMEN/Codigos/Bombas").

clear; clc;
addpath([fileparts(mfilename('fullpath')) filesep '..' filesep '..' filesep '..' filesep ...
         'RESUMEN EXAMEN' filesep 'Codigos' filesep 'Bombas']);

g = 9.81; ro = 1000; nu = 1e-6;

%% ---- datos de la instalacion ----
z0 = -4.0;      % cota lago
zA = 0.5;       % cota de las bombas (succion=impulsion, mismo nivel)
D1 = 0.110; L1 = 20; k1 = 6; eps1 = 0.05e-3;   % succion (comun a ambas bombas)
D2 = 0.080; L2 = 80; k2 = 4; eps2 = 0.05e-3;   % impulsion (comun, aguas abajo del punto de union)
Pimp = 20;      % m.c.a., lectura del manometro (ya en metros de columna de agua)

A1 = pi*D1^2/4;
A2 = pi*D2^2/4;

%% ---- curva de catalogo de CADA bomba (identicas) ----
Qb   = [0.5 2 4 6 8 10 12 14 16 18 20 22]/1000;  % m3/s (por bomba)
Hb   = [26.75 26.4 26.1 25.6 25 24.4 23.7 23.1 22.5 21.4 19.8 18];
etab = [23 51.8 65.6 73.6 78.2 81.7 85.1 88.6 89.7 88.6 86.3 82.8]/100;
NPSHr= [2.7 3.24 3.46 3.78 4.1 4.64 5.29 6.05 6.7 7.34 7.99 8.53];

%% ---- Parte 1.a): hallar Q_inst (dos bombas) resolviendo el balance ----
% Hb(Qinst/2) = zA - z0 + Pimp + V2^2/2g + (f1*L1/D1 + k1)*V1^2/2g
% (residuo = Hb_bomba(Qinst/2) - Hb_requerido; se busca su cruce por cero)
balance_res = @(Qi) interp1(Qb, Hb, Qi/2, 'pchip') - ...
    ( zA - z0 + Pimp + (Qi/A2)^2/(2*g) + ...
      (colebrook((Qi/A1)*D1/nu, eps1/D1)*L1/D1 + k1) * (Qi/A1)^2/(2*g) );

Qlo = 2*min(Qb)+1e-6; Qhi = 2*max(Qb)-1e-6;
rlo = balance_res(Qlo);
% biseccion
for it=1:80
  Qmid = (Qlo+Qhi)/2;
  r = balance_res(Qmid);
  if sign(r)==sign(rlo)
    Qlo = Qmid; rlo = r;
  else
    Qhi = Qmid;
  end
end
Qinst = (Qlo+Qhi)/2;
Qbomba = Qinst/2;

V1 = Qinst/A1; V2 = Qinst/A2;
Re1 = V1*D1/nu; f1 = colebrook(Re1, eps1/D1);
Re2 = V2*D2/nu; f2 = colebrook(Re2, eps2/D2);
hf_succ = (f1*L1/D1 + k1) * V1^2/(2*g);
Hbomba = interp1(Qb, Hb, Qbomba, 'pchip');
eta_pf = interp1(Qb, etab, Qbomba, 'pchip');
NPSHr_pf = interp1(Qb, NPSHr, Qbomba, 'pchip');

fprintf('===== PARTE 1.a =====\n');
fprintf('Q instalacion (2 bombas) = %.5f m3/s (%.3f L/s)\n', Qinst, Qinst*1000);
fprintf('Q por bomba              = %.5f m3/s (%.3f L/s)\n', Qbomba, Qbomba*1000);
fprintf('H por bomba (H funcionamiento) = %.3f m\n', Hbomba);
fprintf('V1 (succion, D=%.0fmm) = %.3f m/s ; Re1=%.0f ; f1=%.4f\n', D1*1000, V1, Re1, f1);
fprintf('V2 (impulsion, D=%.0fmm) = %.3f m/s ; Re2=%.0f ; f2=%.4f\n', D2*1000, V2, Re2, f2);
fprintf('Perdida succion (dist.+local) = %.3f m\n', hf_succ);
fprintf('eta por bomba = %.2f %%\n', eta_pf*100);

%% ---- Parte 1.b): cota del tanque elevado ----
% zA + Pimp + V2^2/2g = z1 + (f2*L2/D2 + k2)*V2^2/2g
hf_imp = (f2*L2/D2 + k2) * V2^2/(2*g);
z1 = zA + Pimp + V2^2/(2*g) - hf_imp;
fprintf('\n===== PARTE 1.b =====\n');
fprintf('Perdida impulsion (dist.+local) = %.3f m\n', hf_imp);
fprintf('Cota superficie libre del tanque elevado z1 = %.3f m\n', z1);

%% ---- Parte 2: Potencia consumida ----
Pot_bomba = ro*g*Qbomba*Hbomba/eta_pf;     % W
Pot_sistema = 2*Pot_bomba;
fprintf('\n===== PARTE 2 =====\n');
fprintf('Potencia por bomba = %.1f W = %.3f kW\n', Pot_bomba, Pot_bomba/1000);
fprintf('Potencia del sistema (2 bombas) = %.3f kW\n', Pot_sistema/1000);

%% ---- Parte 3: NPSH disponible vs requerido ----
Patm = 101300; Pvap = 2340; % Pa, agua a 20C
NPSHdisp = (Patm-Pvap)/(ro*g) + (z0 - zA) - hf_succ;
fprintf('\n===== PARTE 3 =====\n');
fprintf('NPSH disponible = (Patm-Pvap)/(rho g) + (z0-zA) - hf_succion = %.3f m\n', NPSHdisp);
fprintf('NPSH requerido (en Qbomba)      = %.3f m\n', NPSHr_pf);
if NPSHdisp > NPSHr_pf
  fprintf('NPSHdisp > NPSHreq => NO cavita (margen = %.3f m)\n', NPSHdisp-NPSHr_pf);
else
  fprintf('NPSHdisp < NPSHreq => CAVITA\n');
end
