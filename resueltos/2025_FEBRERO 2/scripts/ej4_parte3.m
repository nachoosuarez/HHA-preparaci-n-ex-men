%% Ejercicio 4, Parte 3 - Examen HHA 5 de febrero 2025 (2025_FEBRERO 2)
% Verificacion de cavitacion (NPSHdisponible vs NPSHrequerido) en la
% condicion de diseño: presion atmosferica estandar, agua a 20 grados C.
clc; clear;
load('ej4_part1.mat');
load('ej4_part2.mat');

patm_gamma = 10.33;   % m, presion atmosferica estandar (a nivel del mar) / gamma
pv_gamma_20 = 0.24;   % m, presion de vapor del agua a 20 C / gamma (valor de tabla estandar)

% Carga en la seccion de succion en el punto de funcionamiento (HA, igual
% para ambas bombas por estar acopladas en paralelo con la misma succion)
v_pf = Qpf/A;
Re_pf = v_pf*D/nu;
f_pf2 = colebrook(Re_pf, eps/D);
dHs_pf = (ks + f_pf2*Ls/D) * v_pf^2/(2*g);
HA_pf = zs + p1/(rho*g) - dHs_pf;

% NPSH disponible = patm/gamma - pv/gamma + (HA - zA)
NPSHd = patm_gamma - pv_gamma_20 + (HA_pf - zB);

NPSHr1_pf = interp1(Q1, NPSHr1, Q1_pf, "pchip");
NPSHr2_pf = interp1(Q2, NPSHr2, Q2_pf, "pchip");

fprintf('HA (carga de succion en el PF) = %.4f m\n', HA_pf);
fprintf('NPSHd = patm/g - pv/g(20C) + (HA - zA) = %.3f - %.3f + (%.4f) = %.3f m\n', ...
        patm_gamma, pv_gamma_20, HA_pf-zB, NPSHd);
fprintf('\nNPSHr Bomba 1 en Q1_pf = %.3f m\n', NPSHr1_pf);
fprintf('NPSHr Bomba 2 en Q2_pf = %.3f m\n', NPSHr2_pf);

if NPSHd > NPSHr1_pf
    fprintf('=> Bomba 1: NPSHd > NPSHr => NO CAVITA\n');
else
    fprintf('=> Bomba 1: NPSHd < NPSHr => CAVITA\n');
end
if NPSHd > NPSHr2_pf
    fprintf('=> Bomba 2: NPSHd > NPSHr => NO CAVITA\n');
else
    fprintf('=> Bomba 2: NPSHd < NPSHr => CAVITA\n');
end

save('ej4_part3.mat','HA_pf','NPSHd','NPSHr1_pf','NPSHr2_pf','patm_gamma','pv_gamma_20');
