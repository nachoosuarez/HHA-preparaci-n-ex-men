% Ejercicio4_bombas_paralelo_manometros.m -- HHA examen 23 julio 2018, Ejercicio 4
% Dos bombas distintas (B1,B2) EN PARALELO, tanque a cota +3 m, bombas a
% cota +6 m, con manometros en la succion y en la impulsion COMUNES
% (inmediatamente antes/despues de las dos bombas), ambos a cota +6 m.
% Tuberia de succion e impulsion (comunes, antes de repartirse entre las
% bombas): mismo diametro interno D=250 mm.
%
% Parte 1: Q y H de cada bomba (H es el mismo para ambas, por estar en
%          paralelo con la misma succion/impulsion comun).
% Parte 2: Kgs, Kgi (deltaH = Kg*Q_total^2) para succion e impulsion, y
%          expresion de la curva Q-H de toda la instalacion.
% Parte 3: potencia consumida por cada bomba y verificacion de cavitacion.
clear all; clc;

g = 9.81; ro = 1000; gamma = ro*g;
Patm = 101300; Pvap = 2340;  % Pa, agua ~20 C

% ---------------- Datos ----------------
z_tanque = 3.0;
z_bombas = 6.0;
D = 0.250;           % m, succion e impulsion (mismo diametro)
A = pi*D^2/4;

pA = -44.1e3;   % Pa, manometro de succion (comun a las 2 bombas)
pB =  240.1e3;  % Pa, manometro de impulsion (comun a las 2 bombas)

% Curva de catalogo, Bomba 1
Qb1    = [0 0.035 0.07 0.105 0.14 0.175 0.21 0.245];
Hb1    = [35 34 33 32 29 25 20 12];
etab1  = [0 30 53 68 72 69 59 36]/100;
NPSHr1 = [3.2 3.4 3.7 4.4 5.3 6.8 8.5 10.8];

% Curva de catalogo, Bomba 2
Qb2    = [0 0.015 0.03 0.045 0.06 0.075 0.09 0.105];
Hb2    = [35 34 33 32 29 25 20 12];
etab2  = [0 28 49 62 66 63 54 33]/100;
NPSHr2 = [3.4 3.6 3.9 4.7 5.6 7.2 9 11.5];

%% ---------------- PARTE 1: Q y H de cada bomba ----------------
% Mismo diametro en succion e impulsion => Vsuc=Vimp (para cualquier Q
% que pase por la tuberia comun) => el termino cinetico se cancela y
% Hm = (pB-pA)/gamma exactamente (no hace falta conocer Q para esto).
Hm = (pB-pA)/gamma;
printf("\n--- PARTE 1 ---\n");
printf("H (igual para ambas bombas, por estar en paralelo) = (pB-pA)/gamma = %.4f m\n", Hm);

Q1 = fsolve(@(Q) interp1(Qb1,Hb1,Q,'pchip') - Hm, 0.14);
Q2 = fsolve(@(Q) interp1(Qb2,Hb2,Q,'pchip') - Hm, 0.06);
Qtotal = Q1+Q2;
printf("Q1 (bomba 1) = %.5f m3/s\n", Q1);
printf("Q2 (bomba 2) = %.5f m3/s\n", Q2);
printf("Q_total = Q1+Q2 = %.5f m3/s\n", Qtotal);

%% ---------------- PARTE 2: Kgs, Kgi ----------------
Vc = Qtotal/A;   % velocidad en la tuberia comun (succion e impulsion, mismo D)
printf("\n--- PARTE 2 ---\n");
printf("V_comun (succion e impulsion, Q_total, D=%.3fm) = %.4f m/s\n", D, Vc);

% Energia: tanque(z=3,P=0,V=0) -> manometro succion (z=6,P=pA,V=Vc)
% 3 + 0 + 0 = 6 + pA/gamma + Vc^2/2g + hf_succ
hf_succ = z_tanque - z_bombas - pA/gamma - Vc^2/(2*g);
Kgs = hf_succ/Qtotal^2;
printf("hf_succion = z_tanque - z_bombas - pA/gamma - Vc^2/2g = %.4f m\n", hf_succ);
printf("Kgs = hf_succion/Qtotal^2 = %.4f  (h en m, Q en m3/s)\n", Kgs);

% Energia: manometro impulsion (z=6,P=pB,V=Vc) -> tanque (z=3,P=0,V=0)
% 6 + pB/gamma + Vc^2/2g = 3 + 0 + 0 + hf_imp
hf_imp = z_bombas + pB/gamma + Vc^2/(2*g) - z_tanque;
Kgi = hf_imp/Qtotal^2;
printf("hf_impulsion = z_bombas + pB/gamma + Vc^2/2g - z_tanque = %.4f m\n", hf_imp);
printf("Kgi = hf_impulsion/Qtotal^2 = %.4f  (h en m, Q en m3/s)\n", Kgi);

printf("\nCurva Q-H de toda la instalacion (recircula al mismo tanque, sin desnivel neto):\n");
printf("H_inst(Q) = (Kgs+Kgi)*Q^2 = %.4f*Q^2   (Q=Q_total=Q1+Q2, en m3/s; H en m)\n", Kgs+Kgi);
printf("Verificacion: H_inst(Qtotal) = %.4f m  (debe coincidir con Hm=%.4f m de la Parte 1)\n", ...
       (Kgs+Kgi)*Qtotal^2, Hm);

%% ---------------- PARTE 3: potencia y cavitacion ----------------
printf("\n--- PARTE 3 ---\n");
eta1 = interp1(Qb1,etab1,Q1,'pchip');
eta2 = interp1(Qb2,etab2,Q2,'pchip');
Pot1 = gamma*Q1*Hm/eta1;
Pot2 = gamma*Q2*Hm/eta2;
printf("Bomba 1: eta1=%.2f%%  Potencia1 = gamma*Q1*H/eta1 = %.1f W = %.3f kW\n", eta1*100, Pot1, Pot1/1000);
printf("Bomba 2: eta2=%.2f%%  Potencia2 = gamma*Q2*H/eta2 = %.1f W = %.3f kW\n", eta2*100, Pot2, Pot2/1000);
printf("Potencia total del sistema = %.3f kW\n", (Pot1+Pot2)/1000);

% NPSHdisp: se calcula con el caudal TOTAL en la succion comun (misma
% presion de succion para las 2 bombas); NPSHreq se interpola con el
% caudal INDIVIDUAL de cada bomba.
NPSHdisp = (Patm+pA-Pvap)/gamma + Vc^2/(2*g);
NPSHreq1 = interp1(Qb1,NPSHr1,Q1,'pchip');
NPSHreq2 = interp1(Qb2,NPSHr2,Q2,'pchip');
printf("\nNPSHdisp (comun, con Q_total) = (Patm+pA-Pvap)/gamma + Vc^2/2g = %.3f m\n", NPSHdisp);
printf("Bomba 1: NPSHreq(Q1) = %.3f m => %s (margen %.3f m)\n", NPSHreq1, ...
       merge(NPSHdisp>NPSHreq1,"NO cavita","CAVITA"), NPSHdisp-NPSHreq1);
printf("Bomba 2: NPSHreq(Q2) = %.3f m => %s (margen %.3f m)\n", NPSHreq2, ...
       merge(NPSHdisp>NPSHreq2,"NO cavita","CAVITA"), NPSHdisp-NPSHreq2);
