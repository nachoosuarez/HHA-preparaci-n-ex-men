% Bomba_paralelo_2manometros.m — DOS bombas (iguales o distintas) EN
% PARALELO, con dos manometros COMUNES (uno en la succion, otro en la
% impulsion), ubicados en la tuberia comun ANTES de repartirse entre las
% bombas / DESPUES de unirse, ambos a la MISMA cota. Caso distinto de
% Bomba_manometros.m (una sola bomba) y de
% Bomba_manometro_impulsion_paralelo.m (solo un manometro, con lago en
% la succion): aca hay DOS manometros y ninguno de los dos extremos es
% un lago/tanque de cota a calcular.
%
% Como la succion y la impulsion comunes tienen el MISMO diametro, el
% termino cinetico de Bernoulli se cancela: Hm=(pB-pA)/gamma es EXACTA,
% no depende de Q. Como las bombas estan en paralelo comparten esa misma
% Hm (aunque tengan curvas de catalogo distintas): se interseca Hm con
% la curva H-Q de CADA bomba por separado para hallar Q1, Q2 (Q1 != Q2
% en general, si las bombas son distintas).
%
% Tambien calcula, si se conoce ademas la cota de un tanque de origen/
% destino (mismo tanque, circuito que recircula): los coeficientes
% globales Kgs (succion) y Kgi (impulsion) tales que deltaH=Kg*Qtotal^2,
% despejados directamente de la ecuacion de energia entre el tanque
% (presion~0, V~0) y cada manometro — sin necesitar Colebrook-White ni
% conocer la geometria interna real de la tuberia (ver RESUMEN
% RESUMEN_TEORICO.md §C1, variante "despejar Kg de la ecuacion de
% energia"). Y la potencia + NPSH de cada bomba (NPSHdisp con el caudal
% TOTAL en la succion comun; NPSHreq interpolado con el caudal
% INDIVIDUAL de cada bomba, ver §C4).
%
% Que tipo de ejercicio resuelve: instalacion de laboratorio/planta que
% recircula a un tanque, con dos bombas distintas en paralelo y
% manometros ya instalados en la succion/impulsion comun (2018 jul,
% Ej.4).
clear all; clc;

g = 9.81; ro = 1000; gamma = ro*g;
Patm = 101300; Pvap = 2340;  % Pa, agua ~20 C (cambiar Pvap si otra temperatura)

%% ==== EDITAR ACA: datos de la instalacion ====
z_tanque = 3.0;      % cota del tanque (superficie libre, para Kgs/Kgi; poner NaN si no aplica)
z_bombas = 6.0;      % cota de los manometros (misma para succion e impulsion)
D = 0.250;           % m, diametro comun succion e impulsion (mismo en ambos lados)

pA = -44.1e3;   % Pa, manometro de succion (comun a las 2 bombas)
pB =  240.1e3;  % Pa, manometro de impulsion (comun a las 2 bombas)

% Curva de catalogo, Bomba 1
Qb1    = [0 0.035 0.07 0.105 0.14 0.175 0.21 0.245];
Hb1    = [35 34 33 32 29 25 20 12];
etab1  = [0 30 53 68 72 69 59 36]/100;
NPSHr1 = [3.2 3.4 3.7 4.4 5.3 6.8 8.5 10.8];

% Curva de catalogo, Bomba 2 (puede ser distinta o igual a la Bomba 1)
Qb2    = [0 0.015 0.03 0.045 0.06 0.075 0.09 0.105];
Hb2    = [35 34 33 32 29 25 20 12];
etab2  = [0 28 49 62 66 63 54 33]/100;
NPSHr2 = [3.4 3.6 3.9 4.7 5.6 7.2 9 11.5];
%% ==============================================

A = pi*D^2/4;

%% ---- Hm directa de los manometros (mismo D => termino cinetico se cancela) ----
Hm = (pB-pA)/gamma;
Q1 = fsolve(@(Q) interp1(Qb1,Hb1,Q,'pchip') - Hm, mean(Qb1(2:end)));
Q2 = fsolve(@(Q) interp1(Qb2,Hb2,Q,'pchip') - Hm, mean(Qb2(2:end)));
Qtotal = Q1+Q2;
fprintf('Hm = (pB-pA)/gamma = %.4f m  (igual para las 2 bombas)\n', Hm);
fprintf('Q1 = %.5f m3/s ; Q2 = %.5f m3/s ; Qtotal = %.5f m3/s\n', Q1, Q2, Qtotal);

%% ---- Kgs, Kgi (si hay un tanque de referencia) ----
if ~isnan(z_tanque)
  Vc = Qtotal/A;
  hf_succ = z_tanque - z_bombas - pA/gamma - Vc^2/(2*g);
  Kgs = hf_succ/Qtotal^2;
  hf_imp = z_bombas + pB/gamma + Vc^2/(2*g) - z_tanque;
  Kgi = hf_imp/Qtotal^2;
  fprintf('\nV_comun = %.4f m/s\n', Vc);
  fprintf('Kgs = %.4f ; Kgi = %.4f  (deltaH=Kg*Q^2, Q en m3/s, H en m)\n', Kgs, Kgi);
  fprintf('H_inst(Q) = (Kgs+Kgi)*Q^2 = %.4f*Q^2\n', Kgs+Kgi);
  fprintf('Verificacion: H_inst(Qtotal) = %.4f m (debe == Hm = %.4f m)\n', (Kgs+Kgi)*Qtotal^2, Hm);
end

%% ---- Potencia y NPSH ----
eta1 = interp1(Qb1,etab1,Q1,'pchip');
eta2 = interp1(Qb2,etab2,Q2,'pchip');
Pot1 = gamma*Q1*Hm/eta1;
Pot2 = gamma*Q2*Hm/eta2;
fprintf('\nBomba 1: eta=%.1f%%  Potencia = %.2f kW\n', eta1*100, Pot1/1000);
fprintf('Bomba 2: eta=%.1f%%  Potencia = %.2f kW\n', eta2*100, Pot2/1000);

Vc_npsh = Qtotal/A;   % NPSHdisp usa el caudal TOTAL en la succion comun
NPSHdisp = (Patm+pA-Pvap)/gamma + Vc_npsh^2/(2*g);
NPSHreq1 = interp1(Qb1,NPSHr1,Q1,'pchip');   % NPSHreq usa el caudal INDIVIDUAL
NPSHreq2 = interp1(Qb2,NPSHr2,Q2,'pchip');
fprintf('\nNPSHdisp (comun) = %.3f m\n', NPSHdisp);
fprintf('Bomba 1: NPSHreq=%.3f m => %s (margen %.3f m)\n', NPSHreq1, ...
        merge(NPSHdisp>NPSHreq1,'NO cavita','CAVITA'), NPSHdisp-NPSHreq1);
fprintf('Bomba 2: NPSHreq=%.3f m => %s (margen %.3f m)\n', NPSHreq2, ...
        merge(NPSHdisp>NPSHreq2,'NO cavita','CAVITA'), NPSHdisp-NPSHreq2);
