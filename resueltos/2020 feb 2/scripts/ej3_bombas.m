% ej3_bombas.m — Examen 13/feb/2020, Ejercicio 3.
% Dos bombas iguales en paralelo, succion comun desde un tanque
% (zT1=0, conocido) y manometro en el punto P inmediatamente aguas
% abajo de las bombas (pP=265 kPa) en vez de la cota del tanque de
% impulsion (zT2, desconocida). Adaptado de
% RESUMEN EXAMEN/Codigos/Bombas/Bomba_manometro_impulsion_paralelo.m
% (mismo patron: 1) succion+manometro fija Q: 2) manometro+impulsion
% despeja la cota del tanque elevado).
% Requiere colebrook.m (misma carpeta).
clear; clc;

%% ==== Datos de la instalacion ====
N_bombas = 2;
z_lago = 0.0;      % zT1, superficie libre del tanque de succion
zA = -2.0;         % cota de las bombas (succion=impulsion=punto A=punto P)
D1 = 0.150; L1 = 2;   k1 = 2; eps1 = 0.04e-3;   % succion
D2 = 0.150; L2 = 200; k2 = 3; eps2 = 0.04e-3;   % impulsion
pP = 265e3;        % Pa, presion medida en P (2 bombas funcionando)

Qb    = [0 10 14 17 20 22]/1000;      % m3/s
Hb    = [31 30 27.5 25 20 15];
etab  = [0 60 67 65 58 53]/100;
NPSHr = [1.6 1.8 2.2 2.8 3.9 5.5];    % primer valor (Q=0) no se usa

Patm = 101300; Pvap = 2340;  % Pa, agua ~20 C
%% ==================================

g = 9.81; ro = 1000; nu = 1e-6;
A1 = pi*D1^2/4; A2 = pi*D2^2/4;

Pman = pP/(ro*g);   % m.c.a.

%% ---- Paso 1: tanque succion -> punto P (manometro), hallar Q_total ----
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

printf('Pman (en P) = %.3f m.c.a.\n', Pman);
printf('Q total = %.5f m3/s (%.3f L/s) ; Q por bomba = %.5f m3/s (%.3f L/s)\n', ...
        Qtotal, Qtotal*1000, Qbomba, Qbomba*1000);
printf('H por bomba (punto de funcionamiento) = %.3f m ; eta = %.2f %%\n', Hbomba, eta_pf*100);
printf('V1=%.3f m/s Re1=%.0f f1=%.4f (succion=impulsion, mismo D)\n', V1,Re1,f1);
printf('hf succion (tanque->P) = %.4f m\n', hf_succ);

%% ---- Paso 2: punto P -> tanque elevado, cota zT2 ----
hf_imp = (f2*L2/D2 + k2) * V2^2/(2*g);
zT2 = zA + Pman + V2^2/(2*g) - hf_imp;
printf('\nPerdida impulsion (P->tanque elevado) = %.4f m\n', hf_imp);
printf('zT2 (cota del tanque elevado) = %.4f m\n', zT2);

%% ---- Potencia ----
Pot_bomba = ro*g*Qbomba*Hbomba/eta_pf;
printf('\nPotencia por bomba = %.1f W (%.3f kW)\n', Pot_bomba, Pot_bomba/1000);
printf('Potencia del sistema (2 bombas) = %.3f kW\n', N_bombas*Pot_bomba/1000);

%% ---- NPSH disponible (comun a ambas bombas, mismo tramo de succion) ----
NPSHdisp = (Patm-Pvap)/(ro*g) + (z_lago - zA) - hf_succ;
printf('\nNPSHdisp = %.3f m ; NPSHreq (en el PF) = %.3f m\n', NPSHdisp, NPSHr_pf);
if NPSHdisp>NPSHr_pf
  printf('=> NO cavita (margen %.3f m)\n', NPSHdisp-NPSHr_pf);
else
  printf('=> CAVITA (margen %.3f m)\n', NPSHdisp-NPSHr_pf);
end
