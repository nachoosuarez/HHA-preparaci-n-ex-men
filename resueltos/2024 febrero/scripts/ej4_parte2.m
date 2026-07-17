% ej4_parte2.m -- Examen 2024 febrero, Ejercicio 4, Parte 2
% Evaluar si la bomba cavita en el punto de funcionamiento hallado en la
% Parte 1: NPSH disponible (a partir de la presion ABSOLUTA en la brida
% de succion, leida en el manometro pA) vs. NPSH requerido (curva de
% catalogo, interpolada en Qpf).
clear all; close all; clc;
load('part1_ej4.mat');

Patm = 101300; % Pa
Pvap = 2340;   % Pa (agua a ~20 C)

Vsuc_pf = Qpf/A1;
NPSHdisp = (Patm + pA - Pvap)/gamma + Vsuc_pf^2/(2*g);
NPSHreq  = interp1(Qb, NPSHr, Qpf, 'pchip');

printf('Vsuc en Qpf = %.4f m/s\n', Vsuc_pf);
printf('NPSHdisp = (Patm+pA-Pvap)/gamma + Vsuc^2/2g = %.3f m\n', NPSHdisp);
printf('NPSHreq (interpolado en Qpf=%.2f l/s) = %.3f m\n', Qpf*1000, NPSHreq);

if NPSHdisp > NPSHreq
  printf('\nNPSHdisp > NPSHreq => la bomba NO cavita (margen = %.3f m)\n', NPSHdisp-NPSHreq);
else
  printf('\nNPSHdisp < NPSHreq => la bomba CAVITA\n');
end

Qm = linspace(0.001, 0.033, 300);
Vsuc_m = Qm/A1;
NPSHdisp_m = (Patm + pA - Pvap)/gamma + Vsuc_m.^2/(2*g); % aprox: pA se toma constante (dato puntual del manometro en Qpf); ver nota en RESOLUCION.md
NPSHreq_m = interp1(Qb, NPSHr, Qm, 'pchip');

figure('visible','off'); hold on; grid on;
plot(Qm*1000, NPSHreq_m, 'r-', 'LineWidth', 2);
plot(Qpf*1000, NPSHdisp, 'bo', 'MarkerFaceColor','b', 'MarkerSize', 9);
plot(Qpf*1000, NPSHreq, 'rs', 'MarkerFaceColor','r', 'MarkerSize', 9);
xlabel('Q (l/s)'); ylabel('NPSH (m)');
legend('NPSH requerido (catalogo)', 'NPSH disponible (en Qpf)', 'NPSH requerido (en Qpf)', 'Location','best');
title('Ejercicio 4, Parte 2: NPSH-Q y condicion de operacion');
print('ej4_NPSH_parte2.png', '-dpng');
