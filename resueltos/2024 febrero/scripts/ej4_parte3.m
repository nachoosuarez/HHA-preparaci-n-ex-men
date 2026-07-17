% ej4_parte3.m -- Examen 2024 febrero, Ejercicio 4, Parte 3
% Coeficiente global de perdidas localizadas ks de la tuberia de
% succion (tanque -> brida de entrada de la bomba, punto A), a partir
% del caudal de funcionamiento Qpf ya hallado (Parte 1).
% Ecuacion de energia entre el tanque (1, superficie libre, V=0,
% p=0 gauge) y el punto A (brida de succion, cota zA, presion pA
% medida): H1 = HA + dHsucc, con dHsucc = (f*L1/D1 + ks)*Vsuc^2/2g.
clear all; close all; clc;
load('part1_ej4.mat');

z1 = 1.4;   % m, superficie libre del tanque
zA = 5.5;   % m, cota de la bomba/manometros
L1 = 9;     % m, longitud tuberia de succion
eps1 = 0.006e-3; % m, rugosidad absoluta
nu = 1e-6;  % m2/s

Vsuc = Qpf/A1;
H1 = z1;
HA = zA + pA/gamma + Vsuc^2/(2*g);
dHsucc = H1 - HA;

Re = Vsuc*D1/nu;
f = colebrook(Re, eps1/D1);

printf('Vsuc(Qpf) = %.4f m/s\n', Vsuc);
printf('H1 = z1 = %.4f m\n', H1);
printf('HA = zA + pA/gamma + Vsuc^2/2g = %.4f m\n', HA);
printf('dHsucc = H1 - HA = %.4f m\n', dHsucc);
printf('\nRe = %.0f ; eps1/D1 = %.6f ; f (Colebrook) = %.5f\n', Re, eps1/D1, f);

ks = dHsucc/(Vsuc^2/(2*g)) - f*L1/D1;
printf('\nks = dHsucc/(Vsuc^2/2g) - f*L1/D1 = %.3f\n', ks);
