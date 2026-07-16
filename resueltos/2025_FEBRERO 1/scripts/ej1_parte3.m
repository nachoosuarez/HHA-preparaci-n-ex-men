% Examen HHA 27/02/2025 - Ejercicio 1, Parte 3
% Minimo nivel del Lago B (hLB) para que en la zona peligrosa de la Parte 2
% (x=48.34 a 60 m) no se supere tau_max=42 Pa.
%
% Idea: el caudal Q sigue fijado por el control critico aguas arriba (canal
% tipo S, Teorico Sec. 2.5.4), independiente de hLB, mientras el resalto no
% llegue hasta la seccion 1. Si hLB supera cierto umbral (yL2sup, el
% conjugado del tirante de salida en descarga libre), el resalto que separa
% la curva S2 (que llega desde el Lago A) de la curva S1 (que llega desde el
% Lago B) se mete DENTRO del canal. Aguas abajo del resalto el flujo es
% subcritico con y > yc, por lo que tau cae muy por debajo de tau_max (en
% yc ya tau=18 Pa, muy por debajo de 42 Pa). Se busca el hLB tal que el
% resalto quede justo en x=48.34 m (borde de la zona peligrosa): para
% cualquier hLB mayor, toda la zona peligrosa queda cubierta por la curva S1
% (segura), y para hLB menor, parte de esa zona seguiria en la curva S2
% (insegura).
clc; clear; close all;
addpath(pwd);
load('part1.mat'); % Q, b, m, n, S0, L, x_s2, y_s2, yc, yn
load('part2.mat'); % x_cross (= 48.34 m, limite de la zona peligrosa)

par = [Q,b,S0,n,0,m];

% Conjugado (rama subcritica) de la curva S2 en cada punto: si el resalto
% ocurriera en x, el tirante subcritico que sigue tendria que valer esto.
yconjS2 = zeros(size(y_s2));
for i=1:length(y_s2)
  [~, ycc] = Mom_trap(y_s2(i), b, m, Q);
  yconjS2(i) = ycc;
end

function xr = jump_position(hLB, x_s2, yconjS2, par, L)
  % Integra la curva S1 desde x=L (y=hLB) hacia aguas arriba, y encuentra
  % donde se cruza con el conjugado de la curva S2 (= posicion del resalto).
  opts2 = odeset('RelTol',1e-11,'AbsTol',1e-11,'MaxStep',0.5);
  f = @(u,y) -rect(L-u, y, par); % u = L-x, integra "hacia adelante" en u
  [u,y] = ode23(f, [0 L*0.999], hLB, opts2);
  xs1 = L - u; ys1 = y;
  [xs1,ord] = sort(xs1); ys1 = ys1(ord);
  yconjS2_i = interp1(x_s2, yconjS2, xs1, 'linear','extrap');
  dif = ys1 - yconjS2_i;
  idx = find(diff(sign(dif))~=0, 1, 'last');
  if isempty(idx)
    xr = NaN;
  else
    xr = interp1(dif(idx:idx+1), xs1(idx:idx+1), 0);
  end
end

% yL2sup: nivel del Lago B para el cual el resalto se da justo en x=L
% (conjugado del tirante de salida en descarga libre, Parte 1)
[~, yL2sup] = Mom_trap(y_s2(end), b, m, Q);
printf('yL2sup (resalto justo en la salida, x=%dm) = %.4f m\n', L, yL2sup);

hLB_min = fzero(@(hLB) jump_position(hLB,x_s2,yconjS2,par,L) - x_cross, [yL2sup, yL2sup+0.5]);
xr_check = jump_position(hLB_min, x_s2, yconjS2, par, L);

printf('\nhLB minimo requerido = %.4f m\n', hLB_min);
printf('Verificacion: con ese hLB el resalto se ubica en x = %.2f m (target %.2f m)\n', xr_check, x_cross);

% Perfil completo para graficar: S2 hasta el resalto, S1 desde el resalto
idxS2 = x_s2 <= xr_check;
opts2 = odeset('RelTol',1e-11,'AbsTol',1e-11,'MaxStep',0.5);
f = @(u,y) -rect(L-u, y, par);
[u,y] = ode23(f, [0 L-xr_check], hLB_min, opts2);
xs1 = L - u; ys1 = y;
[xs1,ord] = sort(xs1); ys1 = ys1(ord);

figure('visible','off');
plot(x_s2(idxS2), y_s2(idxS2), 'b-','LineWidth',2); hold on;
plot(xs1, ys1, 'm-','LineWidth',2);
plot([xr_check xr_check],[y_s2(find(idxS2,1,'last')) ys1(1)],'k-','LineWidth',2);
plot([0 L],[yc yc],'r--');
legend('S2 (supercritica, desde Lago A)','S1 (subcritica, desde Lago B)','Resalto','y_c','Location','southeast');
xlabel('x [m]'); ylabel('y [m]');
title(sprintf('Ejercicio 1 Parte 3 - hLB=%.2fm, resalto en x=%.1fm', hLB_min, xr_check));
grid on;
print('ej1_perfil_parte3.png','-dpng','-r150');
