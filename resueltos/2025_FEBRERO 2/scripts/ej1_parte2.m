%% Ejercicio 1, Parte 2 - Examen HHA 5 de febrero 2025 (2025_FEBRERO 2)
% Altura maxima del escalon (tuberia) a L=300 m aguas arriba de la caida
% libre para que el tirante y1 (inmediatamente aguas arriba del escalon,
% sin alterar) no se vea modificado.

clear all; close all; clc;
load('part1.mat');   % Q,b,m,n,S0,g,yc,yn,x,y,y_m300

%% Tirante y1 sin alterar, a x=-300 m (tomado del perfil M2 de la Parte 1)
y1 = y_m300;   % = 1.1705 m

%% Energia especifica en la seccion 1 (aguas arriba del escalon)
[B1,A1,P1,R1,yG1,D1] = trap_geom(y1,b,m);
U1 = Q/A1;
E1 = y1 + U1^2/(2*g);

%% Energia critica (minima energia especifica compatible con Q)
[Bc,Ac,Pc,Rc,yGc,Dc] = trap_geom(yc,b,m);
Uc = Q/Ac;
Ec = yc + Uc^2/(2*g);

%% Transicion de fondo suave (escalon de altura D, sin perdidas):
% E1 = E2 + D  =>  D = E1 - E2
% El escalon maximo (Dmax) que no altera y1 es aquel para el cual, en la
% cresta del escalon (seccion 2), se alcanza justo el tirante critico
% (E2 = Ec): a partir de ese punto cualquier D mayor obligaria a E1 a
% aumentar (remanso) para poder pasar el caudal por la cresta.
Dmax = E1 - Ec;

fprintf('y1 (x=-300m, sin alterar)   = %.4f m\n', y1);
fprintf('E1 (energia especifica en 1) = %.4f m\n', E1);
fprintf('Ec (energia critica)         = %.4f m\n', Ec);
fprintf('Dmax = E1 - Ec                = %.4f m\n', Dmax);

save('part2.mat', 'y1','E1','Ec','Dmax');
