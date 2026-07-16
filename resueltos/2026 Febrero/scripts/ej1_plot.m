%% Grafico de la superficie libre - Ejercicio 1 (Partes 1 y 2)
clear all
graphics_toolkit('gnuplot')
load('part1.mat');   % x,y : perfil M2 sin compuerta
load('part2.mat');   % xg,a,yA,xd,yd,x_resalto,...

par = [Q b S0 n yc m];

% Perfil aguas arriba de la compuerta (M1) x=0..xg
[xu, yu] = ode23(@(x,y) rect(x,y,par), [0, xg], y_lago);

fh = figure('visible','off');

subplot(2,1,1)
zb = -x*S0; zw = y - x*S0;
plot(x, zb, 'k-', 'LineWidth', 2); hold on
plot(x, zw, 'b-', 'LineWidth', 2)
plot([0 L],[yc-0*S0 yc-L*S0],'r--')
plot([0 L],[yn-0*S0 yn-L*S0],'g--')
xlabel('x (m)'); ylabel('cota (m)')
title('Ejercicio 1 - Parte 1: perfil sin compuerta (canal M, curva M2 hacia la caida)')
legend('fondo','superficie libre','yc','yn','Location','southwest')
grid on

subplot(2,1,2)
zb2 = -x*S0;
plot(x, zb2, 'k-', 'LineWidth', 2); hold on
zwu = yu - xu*S0;
plot(xu, zwu, 'b-', 'LineWidth', 2)
zwd = yd - xd*S0;
plot(xd, zwd, 'm-', 'LineWidth', 2)
plot([xg xg],[a-xg*S0, yA-xg*S0],'k:')
plot(x_resalto, y_M2_resalto - x_resalto*S0, 'ro','MarkerFaceColor','r')
plot([0 L],[yc-0*S0 yc-L*S0],'r--')
plot([0 L],[yn-0*S0 yn-L*S0],'g--')
xlabel('x (m)'); ylabel('cota (m)')
title('Ejercicio 1 - Parte 2: perfil con compuerta en x=3200 m (M1 - salto - M3)')
legend('fondo','M1 (aguas arriba)','M3 (aguas abajo)','compuerta','resalto','yc','yn','Location','southwest')
grid on

print(fh, 'ej1_perfil.png', '-dpng', '-r120')
disp('Grafico guardado: ej1_perfil.png')
