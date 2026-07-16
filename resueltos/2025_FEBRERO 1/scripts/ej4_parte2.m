clc; clear; close all;
addpath(pwd);
load('ej4_part1.mat');

eta_pf = interp1(Q, eta, Qpf, 'pchip'); % %

P = rho*g*Qpf*Hpf/(eta_pf/100); % W

printf('=== Parte 2: potencia consumida ===\n');
printf('Eficiencia en Qpf = %.2f %%\n', eta_pf);
printf('P = rho*g*Q*H/eta = %.1f W = %.3f kW\n', P, P/1000);

save('-mat','ej4_part2.mat','eta_pf','P');
