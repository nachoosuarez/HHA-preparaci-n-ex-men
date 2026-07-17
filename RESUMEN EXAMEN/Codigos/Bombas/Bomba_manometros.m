% Bomba_manometros.m — calcula el punto de funcionamiento de una bomba
% cuando el enunciado da directamente las lecturas de DOS MANOMETROS
% ubicados justo antes (succion, pA) y despues (impulsion, pB) de la
% bomba, ambos a la MISMA cota zA. En ese caso no hace falta conocer la
% geometria/perdidas de las tuberias de succion e impulsion para hallar
% Hm(Q): alcanza con Hm = HB-HA = (pB-pA)/gamma + (Vimp^2-Vsuc^2)/(2g),
% que depende de Q solo a traves de las velocidades (areas Dsuc/Dimp,
% que pueden ser distintas). Tambien calcula el NPSH disponible a partir
% de la presion ABSOLUTA de succion (Patm+pA-Pvap), sin necesidad de
% conocer las perdidas del tramo de succion por separado.
%
% Entradas: Dsuc, Dimp (diametros de succion/impulsion, m), pA, pB
% (lecturas de los manometros, Pa, con su signo), Qb/Hb/eta/NPSHr (curva
% de catalogo de la bomba), Patm, Pvap (presion atmosferica y de vapor
% del agua a la temperatura de trabajo, Pa).
% Salidas: punto de funcionamiento (Qpf,Hpf), eficiencia y potencia
% consumida en Qpf, NPSH disponible y NPSH requerido en Qpf (para
% verificar cavitacion).
%
% Usar cuando: el enunciado da lecturas de manometro en las BRIDAS de la
% bomba (no presiones en tanques/depositos distantes) — tipico de
% ejercicios de "recirculacion" o de instalaciones ya construidas donde
% se mide en operacion. Si en cambio hay que calcular Hm a partir de las
% cotas y longitudes de tuberia de dos tanques, usar Bomba_sola.m o
% Bomba_curvaInstalacion.m (requieren colebrook.m para la perdida
% distribuida). Ver tambien: si ademas se pide el coeficiente de
% perdidas localizadas ks de un tramo (p.ej. succion) conocido el punto
% de funcionamiento, se despeja de la ecuacion de energia entre el
% deposito y la brida correspondiente: ks = (H_deposito-H_brida)/(V^2/2g)
% - f*L/D (requiere colebrook.m para f).
clc; clear; close all;

%% ==== DATOS (editar) ====
Dsuc = 0.118;   % m
Dimp = 0.084;   % m
pA = -58.6e3;   % Pa (manometro de succion)
pB = 13.8e3;    % Pa (manometro de impulsion)

g = 9.8;
ro = 1000;
gamma = ro*g;

Patm = 101300;  % Pa
Pvap = 2340;    % Pa (agua ~20 C; usar un valor mayor si el enunciado da otra temperatura)

% Curva de catalogo de la bomba
Qb = [0 3 6 9 12 15 18 21 24 27 30 33]/1000; % m3/s
Hb = [11.0 10.7 10.5 10.2 10.1 9.9 9.6 9.2 8.6 7.9 7.0 6.0];
etab = [0 56 64 74 76 77 75 73 69 64 53 45];
NPSHr = [1.6 1.65 1.7 1.75 1.8 1.85 1.95 2 2.2 3.1 4.2 6];
%% ========================

Asuc = pi*Dsuc^2/4;
Aimp = pi*Dimp^2/4;

Qm = linspace(min(Qb), max(Qb), 3000);
Hb_i = interp1(Qb, Hb, Qm, 'pchip');

Vsuc_m = Qm/Asuc;
Vimp_m = Qm/Aimp;
Hm = (pB-pA)/gamma + (Vimp_m.^2 - Vsuc_m.^2)/(2*g);

[~, idx] = min(abs(Hb_i - Hm));
Qpf = Qm(idx);
Hpf = Hb_i(idx);
eta_pf = interp1(Qb, etab, Qpf, 'pchip')/100;
NPSHreq_pf = interp1(Qb, NPSHr, Qpf, 'pchip');

Vsuc_pf = Qpf/Asuc;
NPSHdisp_pf = (Patm + pA - Pvap)/gamma + Vsuc_pf^2/(2*g);

Pot = gamma*Qpf*Hpf/eta_pf;

fprintf('Asuc=%.5f m2 ; Aimp=%.5f m2\n', Asuc, Aimp);
fprintf('Qpf=%.5f m3/s (%.2f l/s) ; Hpf=%.3f m ; eta_pf=%.1f%%\n', Qpf, Qpf*1000, Hpf, eta_pf*100);
fprintf('Potencia consumida = %.0f W (%.2f kW)\n', Pot, Pot/1000);
fprintf('NPSHdisp=%.3f m ; NPSHreq=%.3f m => ', NPSHdisp_pf, NPSHreq_pf);
if NPSHdisp_pf > NPSHreq_pf
  fprintf('NO cavita (margen %.3f m)\n', NPSHdisp_pf-NPSHreq_pf);
else
  fprintf('CAVITA\n');
end

figure(1); clf; hold on; grid on;
plot(Qm*1000, Hb_i, 'b-', 'LineWidth', 2, 'DisplayName', 'Curva de la bomba (catalogo)');
plot(Qm*1000, Hm, 'm-', 'LineWidth', 2, 'DisplayName', 'Hm(Q) = (pB-pA)/\gamma + \Delta(V^2/2g)');
plot(Qpf*1000, Hpf, 'ko', 'MarkerFaceColor', 'y', 'MarkerSize', 8, 'DisplayName', 'Punto de funcionamiento');
xlabel('Q (l/s)'); ylabel('H (m)'); legend('Location', 'best');
title('Punto de funcionamiento (Hm por lectura directa de manometros)');
