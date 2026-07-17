% ej1_parte3.m — Examen 2024 febrero, Ejercicio 1, Parte 3
% Fuerza que ejerce el fluido sobre el escalon (tuberia) instalado en
% x=700m. Se aplica cantidad de movimiento entre la seccion justo aguas
% arriba del escalon (fondo a nivel original, y1_new=1.5078m,
% subcritico) y la seccion justo aguas abajo (fondo vuelto al nivel
% original tras el escalon, y3_new=0.4349m, supercritico): como ambas
% secciones estan al mismo nivel de fondo, el peso del agua no aporta
% componente horizontal y toda la fuerza horizontal neta que el
% obstaculo ejerce sobre el fluido es R=gamma*(M1-M3). Por reaccion
% (Newton), el fluido ejerce sobre el escalon una fuerza igual y
% opuesta, F=gamma*(M1-M3) en el sentido del flujo (empuja al escalon
% aguas abajo).
clear all; close all; clc;
load('part2.mat');  % Q,b,m,y1_new,y3_new,...

gamma = 9800; % N/m3 (peso especifico del agua, 1000 kg/m3 * 9.8 m/s2)

[M1, ~] = Mom_trap(y1_new, b, m, Q);
[M3, ~] = Mom_trap(y3_new, b, m, Q);

printf('Momento (funcion cantidad de movimiento) M1 (y=%.4f m, aguas arriba) = %.4f m3\n', y1_new, M1);
printf('Momento (funcion cantidad de movimiento) M3 (y=%.4f m, aguas abajo) = %.4f m3\n', y3_new, M3);

F = gamma * (M1 - M3);
printf('\nF = gamma*(M1 - M3) = %.0f * (%.4f - %.4f) = %.0f N\n', gamma, M1, M3, F);
printf('F (sobre el escalon, en el sentido del flujo) = %.1f kN\n', F/1000);
