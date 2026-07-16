% Examen HHA 27/02/2025 - Ejercicio 1, Parte 1
% Canal trapezoidal entre el Lago A (hLA=2.0m) y el Lago B (hLB=0.40m).
% Determina Q, clasifica el canal M/S, e integra el perfil de flujo (FGV).
clc; clear; close all;
addpath(pwd);

% ==== DATOS ====
b   = 2.2;    % ancho de fondo [m]
m   = 1.0;    % talud lateral (1V:1H)
n   = 0.013;  % Manning
S0  = 0.01;   % pendiente de fondo
L   = 60;     % longitud del canal [m]
hLA = 2.0;    % nivel Lago A sobre el fondo [m]
hLB = 0.40;   % nivel Lago B sobre el fondo [m]
g   = 9.8;

% ==== Hipotesis: canal tipo S (n~0.01, S0~1%, Teorico 2.5.4) ====
% Se busca (Q,y1) tal que en la seccion 1 (justo aguas debajo del Lago A):
%  - el flujo sea critico:           Q^2 B1 / (g A1^3) = 1
%  - se conserve la energia:         hLA = y1 + Q^2/(2 g A1^2)
sys1 = @(x) [ (x(1)^2 * (b+2*m*x(2))) / (g*( (b+m*x(2))*x(2) )^3) - 1 ; ...
              hLA - ( x(2) + x(1)^2 / (2*g*((b+m*x(2))*x(2))^2) ) ];
sol = fsolve(sys1, [15, 1.3]);
Q  = sol(1);
yc1 = sol(2);   % = yc en la seccion 1 (entrada del canal)

% Verificacion: yn y yc con este Q, y clasificacion del canal
yn = fsolve(@(y) eq_yn(y,Q,n,m,b,S0), 1);
yc = fsolve(@(y) eq_yc(y,Q,m,b), 1);

printf('Q  = %.4f m3/s\n', Q);
printf('yc = %.4f m\n', yc);
printf('yn = %.4f m\n', yn);
if yn < yc
  printf('yn < yc  ==>  CANAL TIPO S (pendiente fuerte)\n');
else
  printf('yn > yc  ==>  CANAL TIPO M (pendiente suave)\n');
end

% ==== Perfil de flujo (curva S2) desde la seccion 1 (y=yc) hacia aguas abajo ====
par = [Q,b,S0,n,0,m];
opts = odeset('Events', @(x,y) critico(x,y,par), 'RelTol',1e-10,'AbsTol',1e-10);
y0 = yc - 1e-6;   % apenas debajo del critico para poder integrar la S2
[x_s2, y_s2] = ode23(@(x,y) rect(x,y,par), [0 L], y0, opts);

y_exit = y_s2(end);
printf('\ny en x=0   (seccion 1, = yc) = %.4f m\n', y_s2(1));
printf('y en x=%dm (fin del canal)   = %.4f m\n', L, y_exit);

if hLB < yn
  printf('\nhLB (%.2f m) < yn (%.3f m)  ==> el nivel del Lago B NO afecta al canal:\n', hLB, yn);
  printf('el canal descarga en CAIDA LIBRE al Lago B (flujo supercritico en todo el tramo).\n');
  printf('No hay resaltos hidraulicos en este perfil.\n');
end

save('-mat', 'part1.mat', 'Q','yc','yn','b','m','n','S0','L','hLA','hLB','x_s2','y_s2');

% ==== Grafico del perfil ====
figure('visible','off');
plot(x_s2, y_s2, 'b-', 'LineWidth', 2); hold on;
yline_ = @(v,col,txt) plot([0 L],[v v],[col '--']);
plot([0 L],[yn yn],'g--');
plot([0 L],[yc yc],'r--');
plot(L, hLB, 'ko', 'MarkerFaceColor','k');
legend('Superficie libre (S2)','y_n','y_c','Nivel Lago B','Location','northeast');
xlabel('x [m] (desde el Lago A)'); ylabel('y [m]');
title('Ejercicio 1 - Perfil de flujo, canal tipo S entre Lago A y Lago B');
grid on;
print('ej1_perfil.png','-dpng','-r150');
