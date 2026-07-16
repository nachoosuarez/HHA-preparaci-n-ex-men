%% Ejercicio 4, Parte 2 - Examen HHA 5 de febrero 2025 (2025_FEBRERO 2)
% Potencia consumida por el sistema de bombeo en el punto de funcionamiento.
clc; clear;
load('ej4_part1.mat');

eta1_pf = interp1(Q1, eta1, Q1_pf, "pchip");
eta2_pf = interp1(Q2, eta2, Q2_pf, "pchip");

% Pot = rho*g*Q*H / eta   (para cada bomba, con su propio Q y su propio eta,
% ambas bombas entregan la misma H=Hpf por estar acopladas en paralelo)
P1 = (rho*g*Q1_pf*Hpf) / (eta1_pf/100);
P2 = (rho*g*Q2_pf*Hpf) / (eta2_pf/100);
Ptotal = P1 + P2;

fprintf('Eficiencia Bomba 1 en Q1_pf = %.2f %%\n', eta1_pf);
fprintf('Eficiencia Bomba 2 en Q2_pf = %.2f %%\n', eta2_pf);
fprintf('\nPotencia Bomba 1 = %.3f kW\n', P1/1000);
fprintf('Potencia Bomba 2 = %.3f kW\n', P2/1000);
fprintf('Potencia Total   = %.3f kW\n', Ptotal/1000);

save('ej4_part2.mat','eta1_pf','eta2_pf','P1','P2','Ptotal');
