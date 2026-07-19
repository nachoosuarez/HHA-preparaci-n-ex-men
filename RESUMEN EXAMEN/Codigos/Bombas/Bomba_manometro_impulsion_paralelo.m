% Bomba_manometro_impulsion_paralelo.m — punto de funcionamiento de UNA o
% VARIAS bombas iguales EN PARALELO cuando el enunciado da un LAGO/
% deposito de cota conocida en la succion, pero en la impulsion no da la
% cota del tanque final sino la lectura de un MANOMETRO inmediatamente
% aguas debajo de las bombas. Caso distinto de Bomba_manometros.m (que
% tiene manometros en AMBAS bridas, a la misma cota, y no necesita cotas
% de deposito ni perdidas de tuberia).
%
% El problema se resuelve en DOS pasos porque el manometro separa la
% incognita de la cota del tanque:
%  1) Lago -> manometro (usa succion completa con Colebrook-White): fija
%     Q sin necesidad de conocer la cota del tanque.
%  2) Manometro -> tanque (usa impulsion completa): con el Q ya hallado,
%     despeja la cota del tanque.
%
% Si N_bombas>1 (iguales, en paralelo, con perdida en el acople
% despreciable): Q_total = N_bombas * Q_por_bomba, y la curva H-Q a
% comparar contra el balance de energia es la de UNA bomba evaluada en
% Q_total/N_bombas (todas entregan la misma H).
%
% Requiere colebrook.m (mismo directorio).

clear; clc;
addpath(fileparts(mfilename('fullpath')));

%% ==== EDITAR ACA: datos de la instalacion ====
N_bombas = 2;          % 1 si es una sola bomba
z_lago = -4.0;         % cota superficie libre del lago/deposito de succion
zA = 0.5;              % cota de las bombas (succion=impulsion)
D1 = 0.110; L1 = 20; k1 = 6; eps1 = 0.05e-3;   % succion (hasta las bombas)
D2 = 0.080; L2 = 80; k2 = 4; eps2 = 0.05e-3;   % impulsion (desde las bombas)
Pman = 20;             % m.c.a., lectura del manometro en la impulsion (ya en metros)

% Curva de catalogo de UNA bomba
Qb   = [0.5 2 4 6 8 10 12 14 16 18 20 22]/1000;  % m3/s
Hb   = [26.75 26.4 26.1 25.6 25 24.4 23.7 23.1 22.5 21.4 19.8 18];
etab = [23 51.8 65.6 73.6 78.2 81.7 85.1 88.6 89.7 88.6 86.3 82.8]/100;
NPSHr= [2.7 3.24 3.46 3.78 4.1 4.64 5.29 6.05 6.7 7.34 7.99 8.53];

Patm = 101300; Pvap = 2340;  % Pa, agua ~20 C (cambiar Pvap si otra temperatura)
%% ==============================================

g = 9.81; ro = 1000; nu = 1e-6;
A1 = pi*D1^2/4; A2 = pi*D2^2/4;

%% ---- Paso 1: lago -> manometro, hallar Q_total ----
% Hbomba(Q_total/N) = zA - z_lago + Pman + V2^2/2g + (f1*L1/D1+k1)*V1^2/2g
balance_res = @(Qt) interp1(Qb, Hb, Qt/N_bombas, 'pchip') - ...
    ( zA - z_lago + Pman + (Qt/A2)^2/(2*g) + ...
      (colebrook((Qt/A1)*D1/nu, eps1/D1)*L1/D1 + k1) * (Qt/A1)^2/(2*g) );

Qlo = N_bombas*min(Qb)+1e-6; Qhi = N_bombas*max(Qb)-1e-6;
rlo = balance_res(Qlo);
for it=1:80
  Qmid = (Qlo+Qhi)/2;
  r = balance_res(Qmid);
  if sign(r)==sign(rlo)
    Qlo = Qmid; rlo = r;
  else
    Qhi = Qmid;
  end
end
Qtotal = (Qlo+Qhi)/2;
Qbomba = Qtotal/N_bombas;

V1 = Qtotal/A1; V2 = Qtotal/A2;
Re1 = V1*D1/nu; f1 = colebrook(Re1, eps1/D1);
Re2 = V2*D2/nu; f2 = colebrook(Re2, eps2/D2);
hf_succ = (f1*L1/D1 + k1) * V1^2/(2*g);
Hbomba = interp1(Qb, Hb, Qbomba, 'pchip');
eta_pf = interp1(Qb, etab, Qbomba, 'pchip');
NPSHr_pf = interp1(Qb, NPSHr, Qbomba, 'pchip');

fprintf('Q total = %.5f m3/s (%.3f L/s) ; Q por bomba = %.5f m3/s (%.3f L/s)\n', ...
        Qtotal, Qtotal*1000, Qbomba, Qbomba*1000);
fprintf('H por bomba = %.3f m ; eta = %.2f %%\n', Hbomba, eta_pf*100);
fprintf('V1=%.3f m/s Re1=%.0f f1=%.4f ; V2=%.3f m/s Re2=%.0f f2=%.4f\n', V1,Re1,f1,V2,Re2,f2);

%% ---- Paso 2: manometro -> tanque, cota del tanque ----
hf_imp = (f2*L2/D2 + k2) * V2^2/(2*g);
z_tanque = zA + Pman + V2^2/(2*g) - hf_imp;
fprintf('Perdida impulsion = %.3f m ; cota del tanque = %.3f m\n', hf_imp, z_tanque);

%% ---- Potencia ----
Pot_bomba = ro*g*Qbomba*Hbomba/eta_pf;
fprintf('Potencia por bomba = %.1f W (%.3f kW) ; Potencia sistema = %.3f kW\n', ...
        Pot_bomba, Pot_bomba/1000, N_bombas*Pot_bomba/1000);

%% ---- NPSH disponible ----
NPSHdisp = (Patm-Pvap)/(ro*g) + (z_lago - zA) - hf_succ;
fprintf('NPSHdisp = %.3f m ; NPSHreq = %.3f m => %s (margen %.3f m)\n', ...
        NPSHdisp, NPSHr_pf, merge(NPSHdisp>NPSHr_pf,'NO cavita','CAVITA'), NPSHdisp-NPSHr_pf);
