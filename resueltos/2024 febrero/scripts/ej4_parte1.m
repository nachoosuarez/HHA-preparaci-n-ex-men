% ej4_parte1.m -- Examen 2024 febrero, Ejercicio 4, Parte 1
% Punto de funcionamiento (Q,H) de una bomba a partir de las lecturas de
% los dos manometros (entrada pA, salida pB), ambos a la misma cota
% zA=5.5m que la bomba. Como estan al mismo nivel, no hace falta conocer
% las perdidas de la instalacion: Hm(Q) = (pB-pA)/gamma + (Vimp^2-Vsuc^2)/2g
% depende solo del caudal via las velocidades en succion (D1) e
% impulsion (D2). Se interseca con la curva H-Q de catalogo de la bomba
% (interpolada) para hallar el punto de funcionamiento.
clear all; close all; clc;

g = 9.8;
ro = 1000;
gamma = ro*g;

D1 = 0.118;  % succion (m)
D2 = 0.084;  % impulsion (m)
pA = -58.6e3; % Pa
pB = 13.8e3;  % Pa

A1 = pi*D1^2/4;
A2 = pi*D2^2/4;
printf('Asuc = %.5f m2 ; Aimp = %.5f m2\n', A1, A2);

% Curva de la bomba (catalogo)
Qb = [0 3 6 9 12 15 18 21 24 27 30 33]/1000; % m3/s
Hb = [11.0 10.7 10.5 10.2 10.1 9.9 9.6 9.2 8.6 7.9 7.0 6.0];
eta = [0 56 64 74 76 77 75 73 69 64 53 45];
NPSHr = [1.6 1.65 1.7 1.75 1.8 1.85 1.95 2 2.2 3.1 4.2 6];

Qm = linspace(0, 0.033, 3000);
Hb_i = interp1(Qb, Hb, Qm, 'pchip');

Vsuc = Qm/A1;
Vimp = Qm/A2;
Hm = (pB-pA)/gamma + (Vimp.^2 - Vsuc.^2)/(2*g);

[~, idx] = min(abs(Hb_i - Hm));
Qpf = Qm(idx);
Hpf = Hb_i(idx);
eta_pf = interp1(Qb, eta, Qpf, 'pchip')/100;

printf('\nQpf = %.5f m3/s = %.2f l/s\n', Qpf, Qpf*1000);
printf('Hpf = %.3f m\n', Hpf);
printf('eta_pf = %.4f (%.1f%%)\n', eta_pf, eta_pf*100);

Pot = gamma*Qpf*Hpf/eta_pf;
printf('\nPotencia consumida por la bomba Pb = gamma*Q*H/eta = %.0f W = %.2f kW\n', Pot, Pot/1000);

figure('visible','off'); hold on; grid on;
plot(Qm*1000, Hb_i, 'b-', 'LineWidth', 2);
plot(Qm*1000, Hm, 'm-', 'LineWidth', 2);
plot(Qpf*1000, Hpf, 'ko', 'MarkerFaceColor','y', 'MarkerSize', 8);
xlabel('Q (l/s)'); ylabel('H (m)');
legend('Curva de la bomba (catalogo)', 'Hm(Q) = (pB-pA)/\gamma + \Delta(V^2/2g)', 'Punto de funcionamiento', 'Location','best');
title('Ejercicio 4, Parte 1: punto de funcionamiento');
print('ej4_HQ_parte1.png', '-dpng');

save('part1_ej4.mat', 'Qpf','Hpf','eta_pf','Pot','D1','D2','A1','A2','pA','pB','g','ro','gamma','Qb','Hb','eta','NPSHr');
