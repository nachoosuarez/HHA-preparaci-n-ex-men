%% EJERCICIO 1 - PARTE 1 (Examen HHA diciembre 2024)
% Lago A descarga a canal trapezoidal (2 tramos) que descarga a Lago B.
% h_LB = -0.50 m (por debajo del fondo del canal -> descarga libre / caida)
%
% Requiere en la misma carpeta: trap_geom.m, eq_yc.m, eq_yn.m, froude_trap.m,
% manning_trap.m, critico.m, rect.m, tirantes_yn_yc.m, Mom_trap.m
clear all; close all; clc;
g = 9.8;

%% Datos del enunciado
b    = 1.2;   % ancho de fondo (m), igual en ambos tramos
m1   = 1;     % talud tramo 1
m2   = 0.5;   % talud tramo 2 (reduccion de talud)
n    = 0.012; % Manning
S0   = 0.01;  % pendiente de fondo
L1   = 300;   % long. tramo 1 (m)
L2   = 300;   % long. tramo 2 (m)
hLA  = 1.80;  % nivel Lago A sobre el fondo del canal (m)
hLB  = -0.50; % nivel Lago B respecto al fondo del canal (m) -> descarga libre

%% 1) Caudal de descarga: control critico en la entrada (lago -> canal)
% Energia del lago (velocidad ~0) igual a la energia especifica en yc de
% la seccion de entrada (tramo 1): hLA = yc + Q^2/(2 g Ac^2), con Fr(yc)=1
function e = sistema1(x,b,m,hLA,g)
  Q = x(1); yc = x(2);
  [B,A] = trap_geom(yc,b,m);
  e(1) = (Q^2*B)/(g*A^3) - 1;
  e(2) = hLA - yc - Q^2/(2*g*A^2);
endfunction
sol = fsolve(@(x) sistema1(x,b,m1,hLA,g), [10; 1.3]);
Q   = sol(1)          % caudal de descarga (m3/s)
yc1 = sol(2)          % tirante critico en tramo 1 (m)

%% 2) Tirantes normales y criticos de cada tramo, clasificacion M/S
[yn1, yc1_chk] = tirantes_yn_yc(Q,n,m1,b,S0);
[yn2, yc2]     = tirantes_yn_yc(Q,n,m2,b,S0);
if yn1<yc1, tipo1='Canal tipo S (pendiente fuerte)'; else tipo1='Canal tipo M (pendiente suave)'; end
if yn2<yc2, tipo2='Canal tipo S (pendiente fuerte)'; else tipo2='Canal tipo M (pendiente suave)'; end
printf('--- Tramo 1 (m=%.1f) ---\n', m1);
printf('yn1 = %.4f m ; yc1 = %.4f m -> %s\n', yn1, yc1, tipo1);
printf('--- Tramo 2 (m=%.1f) ---\n', m2);
printf('yn2 = %.4f m ; yc2 = %.4f m -> %s\n', yn2, yc2, tipo2);

%% 3) Perfil S2 en tramo 1: desde yc1 (x=0, entrada) hacia aguas abajo (x=300)
par1 = [Q b S0 n yc1 m1];
opt1 = odeset('Events', @(x,y) critico(x,y,par1));
[x1,y1] = ode23(@(x,y) rect(x,y,par1), [0 L1], yc1-0.001, opt1);
yend1 = y1(end);
printf('\nFin tramo 1 (x=300 m): y = %.4f m (~yn1)\n', yend1);

%% 4) Transicion suave entre tramos (conservacion de energia especifica)
[~,A1e] = trap_geom(yend1,b,m1);
E1 = yend1 + Q^2/(2*g*A1e^2);
function e = eq_energia(y,b,m,Q,E,g)
  [~,A] = trap_geom(y,b,m);
  e = y + Q^2/(2*g*A^2) - E;
endfunction
y2_ini = fsolve(@(y) eq_energia(y,b,m2,Q,E1,g), 1.2);
printf('Tirante al inicio de tramo 2 (misma energia especifica): y = %.4f m\n', y2_ini);

%% 5) Perfil S2 en tramo 2: desde y2_ini (x=0 local) hasta x=300 (descarga a Lago B)
par2 = [Q b S0 n yc2 m2];
opt2 = odeset('Events', @(x,y) critico(x,y,par2));
[x2,y2] = ode23(@(x,y) rect(x,y,par2), [0 L2], y2_ini, opt2);
yend2 = y2(end);
printf('Fin tramo 2 / descarga a Lago B (x=600 m): y = %.4f m (~yn2=%.4f)\n', yend2, yn2);
printf('=> Como h_LB=%.2f m esta por debajo del fondo del canal, el nivel del Lago B\n', hLB);
printf('   no controla el flujo: el canal descarga con caida libre a yn2.\n');

%% Grafico del perfil (fondo, superficie libre, yc y yn de cada tramo)
xg1 = x1; zb1 = -xg1*S0; zw1 = y1 - xg1*S0;
xg2 = x2 + L1; zb2 = -xg2*S0; zw2 = y2 - xg2*S0;

figure(1); clf; hold on; grid on;
plot([0 L1+L2], [0 -(L1+L2)*S0], 'k-', 'LineWidth',2);
plot(xg1, zw1, 'b-', 'LineWidth',2);
plot(xg2, zw2, 'b-', 'LineWidth',2);
plot([0 L1],[yc1 yc1-L1*S0], 'r--','LineWidth',1);
plot([0 L1],[yn1 yn1-L1*S0], 'g--','LineWidth',1);
plot([L1 L1+L2],[yc2-L1*S0 yc2-(L1+L2)*S0], 'r-.','LineWidth',1);
plot([L1 L1+L2],[yn2-L1*S0 yn2-(L1+L2)*S0], 'g-.','LineWidth',1);
plot([L1 L1],[-L1*S0, y2_ini-L1*S0],'k:','LineWidth',1);
xlabel('x (m) - distancia desde Lago A'); ylabel('cota (m) respecto al fondo en x=0');
title('Ej.1 Parte 1: Perfil S_2-S_2, h_{LB}=-0.50 m (descarga libre)');
legend('Fondo canal','Sup. libre tramo1','Sup. libre tramo2','y_c tramo1','y_n tramo1', ...
       'y_c tramo2','y_n tramo2','Location','best');
saveas(gcf, 'ej1_perfil_parte1.png');

printf('\n================= RESUMEN PARTE 1 =================\n');
printf('Q = %.3f m3/s\n', Q);
printf('Tramo 1: yc1=%.3f m, yn1=%.3f m -> tipo S\n', yc1, yn1);
printf('Tramo 2: yc2=%.3f m, yn2=%.3f m -> tipo S\n', yc2, yn2);
printf('Perfil: S2 en tramo1 (yc1->%.3f), transicion a y=%.3f, S2 en tramo2 hasta yn2=%.3f\n', yend1, y2_ini, yn2);
printf('No hay resalto (todo el flujo permanece supercritico).\n');
printf('=====================================================\n');
