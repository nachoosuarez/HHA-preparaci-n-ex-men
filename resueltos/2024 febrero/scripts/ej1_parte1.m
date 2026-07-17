% ej1_parte1.m — Examen 2024 febrero, Ejercicio 1, Parte 1
% Canal trapezoidal entre dos lagos (Lago A aguas arriba, Lago B aguas
% abajo). Se pide: caudal de descarga, clasificacion M/S, perfil de la
% superficie libre.
clear all; close all; clc;

%% Datos
b  = 5;      % ancho de fondo (m)
m  = 2;      % talud 1V:2H
n  = 0.018;  % Manning
S0 = 0.002;  % pendiente de fondo
L  = 1500;   % longitud del canal (m)
hLA = 1.10;  % tirante del Lago A sobre el fondo del canal, en x=0 (m)
hLB = 1.49;  % tirante del Lago B sobre el fondo del canal, en x=L (m)

%% 1) Caudal: canal largo alimentado por un lago (Lago A) -> se asume
%   y(x=0+) = yn (flujo normal ya establecido cerca de la entrada,
%   perdida de entrada = diferencia de energia cinetica), y se resuelve
%   Q con caudal_M_ini.m (valido si el canal resulta tipo M, que se
%   verifica despues).
[Q, yn, yc] = caudal_M_ini(n, m, b, S0, hLA);
printf('Q  = %.4f m3/s\n', Q);
printf('yn = %.4f m\n', yn);
printf('yc = %.4f m\n', yc);

if yn > yc
  printf('yn > yc => CANAL TIPO M (pendiente suave)\n');
else
  printf('yn < yc => CANAL TIPO S (pendiente fuerte)\n');
end

if hLB > yn
  printf('hLB=%.4f > yn=%.4f => curva de remanso M1 en todo el canal\n', hLB, yn);
end

%% 2) Perfil FGV: integrar M1 desde el Lago B (control aguas abajo, x=L,
%    y=hLB) hacia aguas arriba (x=0), verificando que se acerca a yn
par = [Q, b, S0, n, yc, m];
opt = odeset('Events', @(x,y) critico(x,y,par));
[xp, yp] = ode23(@(x,y) rect(x,y,par), [L 0], hLB, opt);
[xp, idx] = sort(xp); yp = yp(idx);

printf('\nPerfil M1 (x desde el inicio del canal, Lago A):\n');
printf('x=%.0f m (Lago B): y=%.4f m\n', xp(end), yp(end));
[~, i0] = min(abs(xp-0));
printf('x=%.0f m (Lago A): y=%.4f m  (yn=%.4f)\n', xp(i0), yp(i0), yn);

figure('visible','off');
plot(xp, yp, 'b-', 'LineWidth', 2); hold on; grid on;
plot([0 L], [yn yn], '--m');
plot([0 L], [yc yc], '--k');
legend('perfil M1', 'y_n', 'y_c', 'Location', 'best');
xlabel('x (m) [0 = Lago A, 1500 = Lago B]');
ylabel('y (m)');
title('Ejercicio 1, Parte 1: perfil M1 sin escalon');
print('ej1_perfil_parte1.png', '-dpng');

save('part1.mat', 'Q', 'yn', 'yc', 'b', 'm', 'n', 'S0', 'L', 'hLA', 'hLB', 'xp', 'yp');
