% Ejercicio1_canal_compuerta_rasante.m -- HHA examen 23 julio 2018, Ejercicio 1
% Canal trapezoidal de largo infinito (b=6, m=1, S0=0.0008, n=0.015) con
% Q=10 m3/s fijo. Se coloca una compuerta de fondo ideal de abertura a.
% Parte 1: clasificar el canal (yn vs yc).
% Parte 2: abertura minima "a" para que la tension rasante aguas abajo de
%          la compuerta no supere 65 Pa.
% Parte 3: tirantes de interes del perfil (yn, yc, yA, yB=a) -- ver
%          RESOLUCION.md para la descripcion cualitativa del perfil.
% Parte 4: fuerza sobre la compuerta con la abertura hallada en la parte 2.
clear all; clc;

g = 9.8;
gamma = 9800;

% Datos
Q = 10;
b = 6;
m = 1;
S0 = 0.0008;
n = 0.015;
Tmax = 65;

%% ---------------- PARTE 1: clasificacion del canal ----------------
[yn, yc] = tirantes_yn_yc(Q, n, m, b, S0);
printf("\n--- PARTE 1 ---\n");
printf("yn = %.4f m\n", yn);
printf("yc = %.4f m\n", yc);
if yn > yc
  printf("yn > yc  => canal de pendiente SUAVE (tipo M, subcritico)\n");
else
  printf("yn < yc  => canal de pendiente FUERTE (tipo S, supercritico)\n");
end

%% ---------------- PARTE 2: abertura minima por tension rasante ----------------
% tau(y) = gamma*R*Sf , Sf de Manning para el caudal Q en la seccion de
% tirante y (formula cerrada, igual que rasante_max.m).
tau_fun = @(y) gamma .* (Q.^2 .* n.^2) ./ ...
    ((b.*y + m.*y.^2).^2 .* ...
    ((b.*y + m.*y.^2) ./ (b + 2.*y.*sqrt(1+m.^2))).^(1/3));

a_min = fsolve(@(y) Tmax - tau_fun(y), 0.5);
printf("\n--- PARTE 2 ---\n");
printf("tau(a_min) debe valer Tmax = %.1f Pa\n", Tmax);
printf("a_min = %.4f m\n", a_min);
printf("(a < a_min => tau > 65 Pa ; a >= a_min => tau <= 65 Pa)\n");
printf("Verificacion: tau(a_min) = %.3f Pa\n", tau_fun(a_min));
printf("Comparacion: a_min = %.4f m  vs yc = %.4f m -> ", a_min, yc);
if a_min < yc
  printf("a_min < yc (descarga supercritica, consistente con compuerta)\n");
else
  printf("a_min >= yc (revisar)\n");
end

%% ---------------- PARTE 3: tirante aguas arriba de la compuerta (yA) ----------------
[E_B, yA] = Eesp_trap(a_min, b, Q, m);
printf("\n--- PARTE 3 ---\n");
printf("yB = a_min = %.4f m (supercritico, inmediatamente aguas abajo)\n", a_min);
printf("E(yB) = %.4f m\n", E_B);
printf("yA (alterno subcritico, inmediatamente aguas arriba) = %.4f m\n", yA);
printf("yn (lejos, aguas arriba y aguas abajo) = %.4f m\n", yn);
printf("yc = %.4f m\n", yc);

%% ---------------- PARTE 4: fuerza sobre la compuerta ----------------
[M1, ~] = Mom_trap(yA, b, m, Q);
[M2, ~] = Mom_trap(a_min, b, m, Q);
F = gamma * (M1 - M2);
printf("\n--- PARTE 4 ---\n");
printf("M1 (en yA=%.4f m) = %.4f m3\n", yA, M1);
printf("M2 (en yB=a_min=%.4f m) = %.4f m3\n", a_min, M2);
printf("F = gamma*(M1-M2) = %.1f N = %.3f kN  (sentido: el flujo empuja a la compuerta hacia aguas abajo)\n", F, F/1000);
