% ej4.m -- Examen HHA 24 de febrero de 2023, Ejercicio 4
% Instalacion de bombeo que recircula agua en un mismo tanque abierto:
% succion desde el nivel z1=1.5m, impulsion que descarga LIBREMENTE (no
% recuperable la energia cinetica) a z2=3m. Valvula de globo (kv) en la
% impulsion. Manometros pA (succion, antes de la bomba) y pB (impulsion,
% despues de la bomba), ambos a cota zA=0.3m.
%
% Parte 1: para Q=1 l/s, hallar kv y las presiones pA, pB.
% Parte 2: con la valvula totalmente abierta (kv=5), punto de funcionamiento.
% Parte 3: evaluar cavitacion (NPSHdisp vs NPSHreq) en la Parte 2.
%
% Requiere en esta misma carpeta: colebrook.m (canonico de
% RESUMEN EXAMEN/Codigos/Bombas/).
clc; clear; close all;
warning('off','all');

g = 9.8;
rho = 1000;
gamma = rho*g;
nu = 1e-6;

% ---- Geometria ----
L1 = 3;     D1 = 0.025;  eps1 = 0.007e-3;  k1 = 0.8;    % succion
L2 = 35;    D2 = 0.032;  eps2 = 0.007e-3;  k2 = 1.5;    % impulsion (sin kv)
z1 = 1.5;   z2 = 3;      zA = 0.3;

A1 = pi*D1^2/4;
A2 = pi*D2^2/4;

% ---- Curva de la bomba (catalogo) ----
Qb    = [0.05 0.20 0.40 0.60 0.80 1.00 1.20 1.40 1.60 1.80 2.00 2.20]/1000; % m3/s
Hb_t  = [9.4 9.2 9.1 9.0 8.8 8.5 8.3 8.1 7.9 7.5 6.9 6.3];
eta_t = [23 51.7 65.6 73.6 78.2 81.6 85.1 88.6 89.7 88.6 86.3 82.8];
NPSHr_t = [2.1 2.6 2.7 3.0 3.2 3.7 4.2 4.8 5.3 5.8 6.3 6.7];

function f = fric(v, D, eps)
  nu = 1e-6;
  Re = v*D/nu;
  f = colebrook(Re, eps/D);
end

%% ================= PARTE 1: Q=1 l/s, hallar kv, pA, pB =================
fprintf('=== PARTE 1 ===\n');
Q1 = 1e-3;  % m3/s
v1 = Q1/A1;
v2 = Q1/A2;
Re1 = v1*D1/nu;
Re2 = v2*D2/nu;
f1 = fric(v1, D1, eps1);
f2 = fric(v2, D2, eps2);
fprintf('v1=%.4f m/s ; Re1=%.3e ; eps/D1=%.3e ; f1=%.4f\n', v1, Re1, eps1/D1, f1);
fprintf('v2=%.4f m/s ; Re2=%.3e ; eps/D2=%.3e ; f2=%.4f\n', v2, Re2, eps2/D2, f2);

H1 = z1;                        % tanque, superficie libre, v~0
H2 = z2 + v2^2/(2*g);           % descarga LIBRE (no recuperable)
dHsucc = (f1*L1/D1 + k1)*v1^2/(2*g);
Hb1 = interp1(Qb, Hb_t, Q1, 'pchip');  % = 8.5 m (coincide con la tabla, sin interpolar)
fprintf('H1=%.4f m ; H2=%.4f m ; dHsucc=%.4f m ; Hb(Q=1l/s)=%.4f m\n', H1, H2, dHsucc, Hb1);

% Hb = (H2-H1) + dHsucc + dHimp(kv)  =>  dHimp = Hb - (H2-H1) - dHsucc
dHimp_needed = Hb1 - (H2-H1) - dHsucc;
coef_imp = dHimp_needed/(v2^2/(2*g));   % = f2*L2/D2 + kv + k2
kv = coef_imp - f2*L2/D2 - k2;
fprintf('dHimp necesario = %.4f m  =>  kv = %.2f\n', dHimp_needed, kv);

HA = H1 - dHsucc;
HB = HA + Hb1;
pA = gamma*(HA - zA - v1^2/(2*g));
pB = gamma*(HB - zA - v2^2/(2*g));
fprintf('H_A = %.4f m ; H_B = %.4f m\n', HA, HB);
fprintf('p_A = %.1f Pa (%.2f kPa) ; p_B = %.1f Pa (%.2f kPa)\n', pA, pA/1000, pB, pB/1000);

%% ================= PARTE 2: kv=5, punto de funcionamiento =================
fprintf('\n=== PARTE 2 ===\n');
kv2 = 5;

Qm = linspace(min(Qb), max(Qb), 4000);
Hb_i = interp1(Qb, Hb_t, Qm, 'pchip');

Hm = zeros(size(Qm));
for i=1:length(Qm)
  Q = Qm(i);
  v1i = Q/A1; v2i = Q/A2;
  f1i = fric(v1i, D1, eps1);
  f2i = fric(v2i, D2, eps2);
  H2i = z2 + v2i^2/(2*g);
  dHsucci = (f1i*L1/D1 + k1)*v1i^2/(2*g);
  dHimpi  = (f2i*L2/D2 + kv2 + k2)*v2i^2/(2*g);
  Hm(i) = (H2i - z1) + dHsucci + dHimpi;
end

[~, idx] = min(abs(Hb_i - Hm));
Qpf = Qm(idx);
Hpf = Hb_i(idx);
v1pf = Qpf/A1; v2pf = Qpf/A2;
f1pf = fric(v1pf, D1, eps1);
f2pf = fric(v2pf, D2, eps2);
eta_pf = interp1(Qb, eta_t, Qpf, 'pchip');
fprintf('Qpf = %.5f m3/s (%.3f l/s) ; Hpf = %.4f m\n', Qpf, Qpf*1000, Hpf);
fprintf('v1=%.4f m/s, f1=%.4f ; v2=%.4f m/s, f2=%.4f (en el punto de funcionamiento)\n', v1pf, f1pf, v2pf, f2pf);
fprintf('eta(Qpf) = %.2f %%\n', eta_pf);

figure(1); clf; hold on; grid on;
plot(Qm*1000, Hb_i, 'b-', 'LineWidth', 2, 'DisplayName', 'Curva de la bomba');
plot(Qm*1000, Hm, 'm-', 'LineWidth', 2, 'DisplayName', 'Curva de la instalacion (kv=5)');
plot(Qpf*1000, Hpf, 'ko', 'MarkerFaceColor', 'y', 'MarkerSize', 8, 'DisplayName', 'Punto de funcionamiento');
xlabel('Q (l/s)'); ylabel('H (m)'); legend('Location', 'best');
title('Ejercicio 4 Parte 2 - Punto de funcionamiento (kv=5)');
print(gcf, 'ej4_parte2.png', '-dpng');

%% ================= PARTE 3: cavitacion =================
fprintf('\n=== PARTE 3 ===\n');
patm_g = 10.33;  % m.c.a.
pvap_g = 0.24;   % m.c.a. (agua ~20 C)

HA_pf = H1 - (f1pf*L1/D1 + k1)*v1pf^2/(2*g);
NPSHdisp = (HA_pf - zA) + patm_g - pvap_g;
NPSHreq = interp1(Qb, NPSHr_t, Qpf, 'pchip');
fprintf('H_A(Qpf) = %.4f m\n', HA_pf);
fprintf('NPSHdisp = %.4f m ; NPSHreq = %.4f m => ', NPSHdisp, NPSHreq);
if NPSHdisp > NPSHreq
  fprintf('NO CAVITA (margen %.3f m)\n', NPSHdisp-NPSHreq);
else
  fprintf('CAVITA\n');
end
