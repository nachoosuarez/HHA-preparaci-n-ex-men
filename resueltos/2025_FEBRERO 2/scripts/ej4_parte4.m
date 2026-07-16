%% Ejercicio 4, Parte 4 - Examen HHA 5 de febrero 2025 (2025_FEBRERO 2)
% Riesgo de cavitacion en invierno (agua a 10C) vs verano (agua a 30C).
% Se desprecian cambios de viscosidad/densidad con la temperatura (dato
% del enunciado) => el punto de funcionamiento (Qpf, Hpf, HA) NO cambia;
% solo cambia pv/gamma con la temperatura.
clc; clear;
load('ej4_part1.mat');
load('ej4_part3.mat');   % HA_pf, patm_gamma

pv_gamma_10 = 0.13;   % m (dato de la tabla del enunciado)
pv_gamma_30 = 0.43;   % m (dato de la tabla del enunciado)

NPSHd_10 = patm_gamma - pv_gamma_10 + (HA_pf - zB);
NPSHd_20 = NPSHd;                                        % de la Parte 3 (cargado desde part3.mat)
NPSHd_30 = patm_gamma - pv_gamma_30 + (HA_pf - zB);

fprintf('NPSHd (10 C, invierno) = %.3f m\n', NPSHd_10);
fprintf('NPSHd (20 C, diseño)   = %.3f m\n', NPSHd_20);
fprintf('NPSHd (30 C, verano)   = %.3f m\n', NPSHd_30);

fprintf('\nA mayor temperatura, mayor presion de vapor pv/gamma => menor NPSHd\n');
fprintf('=> la condicion mas riesgosa para la cavitacion es el VERANO (agua a 30 C)\n');

NPSHr1_pf = interp1(Q1, NPSHr1, Q1_pf, "pchip");
NPSHr2_pf = interp1(Q2, NPSHr2, Q2_pf, "pchip");

fprintf('\n--- Verificacion en la condicion mas riesgosa (30 C) ---\n');
fprintf('NPSHd(30C) = %.3f m\n', NPSHd_30);
fprintf('NPSHr Bomba 1 = %.3f m\n', NPSHr1_pf);
fprintf('NPSHr Bomba 2 = %.3f m\n', NPSHr2_pf);

if NPSHd_30 > NPSHr1_pf
    fprintf('=> Bomba 1: NO CAVITA\n');
else
    fprintf('=> Bomba 1: CAVITA\n');
end
if NPSHd_30 > NPSHr2_pf
    fprintf('=> Bomba 2: NO CAVITA\n');
else
    fprintf('=> Bomba 2: CAVITA\n');
end
