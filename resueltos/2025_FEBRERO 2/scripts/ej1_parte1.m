%% Ejercicio 1, Parte 1 - Examen HHA 5 de febrero 2025 (2025_FEBRERO 2)
% Canal trapezoidal infinito que termina en caida libre.
% Clasificacion M/S y perfil de la superficie libre.

clear all; close all; clc;

%% Datos
Q  = 15;      % caudal (m3/s)
b  = 5;       % ancho de fondo (m)
m  = 2;       % talud lateral 1V:mH
n  = 0.017;   % Manning
S0 = 0.001;   % pendiente de fondo
g  = 9.8;

%% Tirante critico (Fr=1, Manning con Q dado)
yc0 = (Q^2/(g*b^2))^(1/3);           % estimacion inicial (rectangular)
yc  = fsolve(@(y) eq_yc(y,Q,m,b), yc0);

%% Tirante normal (Manning con S0)
yn0 = (Q*n/(b*sqrt(S0)))^(3/5);      % estimacion inicial (rectangular)
yn  = fsolve(@(y) eq_yn(y,Q,n,m,b,S0), yn0);

fprintf('yc = %.4f m\n', yc);
fprintf('yn = %.4f m\n', yn);

if yc < yn
    fprintf('yc < yn  =>  CANAL TIPO M (pendiente suave)\n');
else
    fprintf('yc > yn  =>  CANAL TIPO S (pendiente fuerte)\n');
end

%% Perfil de flujo: curva M2 desde la caida libre (control aguas abajo)
% x=0 en la caida libre; x negativo = aguas arriba (direccion de avance
% del calculo, contraria al flujo). Condicion de control en caida libre:
% y(x=0) = 1.01*yc (criterio estandar para iniciar la M2 en el borde
% critico sin problemas numericos de pendiente infinita en yc exacto).
y_ini = 1.01*yc;
par = [Q b S0 n yc m];
x_ini = 0; x_end = -700;   % suficientemente largo para ver la asintota a yn

opt = odeset('Events', @(x,y) critico(x,y,par));
[x, y] = ode23(@(x,y) rect(x,y,par), [x_ini x_end], y_ini, opt);

% Ordenar de aguas arriba a aguas abajo
[x, idx] = sort(x);
y = y(idx);

fprintf('\nx (m, 0=caida libre, neg=aguas arriba)   y (m)\n');
for xv = [-700 -600 -500 -400 -300 -200 -100 -50 -20 0]
    yv = interp1(x, y, xv, 'linear');
    fprintf('  x = %6.1f      y = %.4f\n', xv, yv);
end

y_m300 = interp1(x, y, -300, 'linear');
fprintf('\ny en x=-300 m (300 m aguas arriba de la caida): y = %.4f m\n', y_m300);

save('part1.mat', 'Q','b','m','n','S0','g','yc','yn','x','y','y_m300');

%% Grafico del perfil
figure(1); clf; hold on; grid on;
plot(x, y, 'b-', 'LineWidth', 2);
plot([x(1) x(end)], [yc yc], '--r');
plot([x(1) x(end)], [yn yn], '--g');
xlabel('x (m) [0 = caida libre, negativo = aguas arriba]');
ylabel('y (m)');
title('Ejercicio 1 - Perfil M2 (canal tipo M) hacia la caida libre');
legend('Superficie libre (M2)', 'y_c', 'y_n', 'Location', 'best');
print('ej1_perfil_parte1.png', '-dpng', '-r120');
