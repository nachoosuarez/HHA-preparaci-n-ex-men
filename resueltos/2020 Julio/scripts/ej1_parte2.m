% ej1_parte2.m -- Examen HHA 7/jul/2020, Ejercicio 1, Parte 2
% Altura maxima D de una caneria que atraviesa el fondo del canal en
% x=3000 m (escalon de fondo, Teorico HHA S2.2.5) para que el flujo NO
% se vea afectado (ni aguas arriba ni aguas abajo).
clear all
addpath('.');
load('part1.mat'); % Q, yn, yc, xprof, yprof, b, m, n, S0, L, hLA, hLB

g = 9.8;
xpipe = 3000;

% Tirante y energia especifica INMEDIATAMENTE ANTES del escalon (sin
% caneria), tomados del perfil de la Parte 1 (curva M1, practicamente
% igual a yn en x=3000 porque el canal es muy largo frente al desarrollo
% de la M1)
y_approach = interp1(xprof,yprof,xpipe);
[~,A_approach] = trap_geom(y_approach,b,m);
E_approach = y_approach + Q^2/(2*g*A_approach^2);

[~,Ac] = trap_geom(yc,b,m);
Ec = yc + Q^2/(2*g*Ac^2);

Dmax = E_approach - Ec;

printf('--- Ejercicio 1, Parte 2 ---\n');
printf('Q (de la Parte 1)      = %.4f m3/s\n', Q);
printf('y(x=3000) sin canieria = %.4f m  (yn=%.4f m)\n', y_approach, yn);
printf('E(x=3000) = E_aprox    = %.4f m\n', E_approach);
printf('yc                     = %.4f m\n', yc);
printf('Ec = yc+Q^2/(2gAc^2)   = %.4f m\n', Ec);
printf('Dmax = E_aprox - Ec    = %.4f m\n', Dmax);
