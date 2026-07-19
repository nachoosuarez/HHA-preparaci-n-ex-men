% ej1_plot.m -- grafico de los perfiles de la superficie libre del
% Ejercicio 1 (Examen HHA 7/jul/2020): Parte 1 (sin caneria) y Parte 3
% (con caneria D=0.6m en x=3000m, con resalto hidraulico).
clear all
addpath('.');
load('part1.mat');
load('part3.mat');

S = S0;
figure(1); clf
hold on

% --- Sin caneria (Parte 1) ---
zb = -xprof*S;
zw1 = yprof - xprof*S;
plot(xprof, zw1, '-b', 'LineWidth', 2);

% --- Con caneria (Parte 3): aguas arriba (M1), escalon, aguas abajo M3 + resalto + M1/M2 desde B ---
zw_up = yup - xup*S;
plot(xup, zw_up, '-r', 'LineWidth', 2);

% transicion local sobre la caneria (no resuelta por la EDO de FGV: es
% una transicion corta, ver Teorico HHA S2.2.5): union grafica entre el
% tirante justo antes (y1) y justo despues (y3) de la caneria
plot([xpipe xpipe], [yup(end)-xpipe*S, y3-xpipe*S], ':r', 'LineWidth', 1.5);

% tramo M3 (supercritico) aguas abajo de la caneria, hasta el resalto
idx_m3 = xdn <= x_resalto;
zw_dn = ydn(idx_m3) - xdn(idx_m3)*S;
plot(xdn(idx_m3), zw_dn, '-r', 'LineWidth', 2);

% resalto (linea vertical)
plot([x_resalto x_resalto], [y1_resalto-x_resalto*S, y2_resalto-x_resalto*S], '-r', 'LineWidth', 2.5);

% tramo subcritico aguas abajo del resalto, llegando al Lago B
idx_B = xB >= x_resalto;
zw_B = yB(idx_B) - xB(idx_B)*S;
plot(xB(idx_B), zw_B, '-r', 'LineWidth', 2);

% fondo del canal (con el escalon dibujado como referencia, no a escala)
plot([0 L], [0 -L*S], '-k', 'LineWidth', 3);
plot([xpipe xpipe], [-xpipe*S, -xpipe*S+D], '-k', 'LineWidth', 3);

% niveles de los lagos
plot([0 0],[hLA -0.05],'-','Color',[0 0.6 0]);
plot([L L],[hLB-L*S -0.05-L*S],'-','Color',[0 0.6 0]);

xlabel('x (m)'); ylabel('z (m), referido al fondo en x=0');
legend('Superficie libre sin caneria (Parte 1)', ...
       'Superficie libre con caneria D=0.6m (Parte 3)', ...
       'Location','SouthWest');
title('Ejercicio 1 -- Examen HHA 7/jul/2020: perfil del canal entre los Lagos A y B');
grid on
print('ej1_perfil.png','-dpng','-r120');
printf('Grafico guardado en ej1_perfil.png\n');

% --- Zoom de la zona de la caneria (x en [2900,3100]) ---
figure(2); clf
hold on
plot(xup, zw_up, '-r', 'LineWidth', 2);
plot([xpipe xpipe], [yup(end)-xpipe*S, y3-xpipe*S], ':r', 'LineWidth', 1.5);
plot(xdn(idx_m3), zw_dn, '-r', 'LineWidth', 2);
plot([x_resalto x_resalto], [y1_resalto-x_resalto*S, y2_resalto-x_resalto*S], '-r', 'LineWidth', 2.5);
plot(xB(idx_B), zw_B, '-r', 'LineWidth', 2);
plot([0 L], [0 -L*S], '-k', 'LineWidth', 1);
plot([xpipe xpipe], [-xpipe*S, -xpipe*S+D], '-k', 'LineWidth', 3);
xlim([2900 3120]);
ylim([-2.2 -0.2]);
xlabel('x (m)'); ylabel('z (m)');
title('Zoom: caneria en x=3000m (D=0.6m) y resalto en x=3025.9m');
grid on
print('ej1_perfil_zoom.png','-dpng','-r120');
printf('Grafico guardado en ej1_perfil_zoom.png\n');
