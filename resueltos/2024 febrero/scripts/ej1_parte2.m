% ej1_parte2.m — Examen 2024 febrero, Ejercicio 1, Parte 2
% Escalon de altura Zesc=0.50m en x=700m (bache/hump de longitud
% despreciable: el fondo sube y vuelve a bajar al nivel original en el
% mismo punto, tipico de una tuberia cruzando el canal). Se evalua si
% el escalon "ahoga" la seccion (obliga a un maximo de energia
% especifica = minima, es decir flujo critico en la cresta) y, si asi
% es, se calcula el nuevo perfil completo (remanso M1' aguas arriba del
% escalon, curva M3 supercritica aguas abajo, resalto hidraulico que
% reconecta con el perfil M1 original de la Parte 1 antes de llegar al
% Lago B).
clear all; close all; clc;
load('part1.mat');  % Q, yn, yc, b, m, n, S0, L, hLA, hLB, xp, yp (perfil sin escalon)

g = 9.8;
xesc = 700;
Zesc = 0.50;

%% 1) Condicion sin escalon en x=xesc (de la Parte 1: ya vimos que y=yn ahi)
y1_sin = interp1(xp, yp, xesc);
[~,A1,~,~,~,D1] = trap_geom(y1_sin, b, m);
U1_sin = Q/A1;
E1_sin = y1_sin + U1_sin^2/(2*g);

[~,Ac,~,~,~,Dc] = trap_geom(yc, b, m);
Uc = Q/Ac;
Ec = yc + Uc^2/(2*g);

Zmax = E1_sin - Ec;
printf('y(x=700, sin escalon) = %.4f m (~= yn)\n', y1_sin);
printf('E1_sin = %.4f m ; Ec = %.4f m\n', E1_sin, Ec);
printf('Zmax (maxima altura de escalon que NO altera el flujo) = %.4f m\n', Zmax);

if Zesc > Zmax
  printf('Zesc=%.2f m > Zmax=%.4f m => el escalon AHOGA la seccion => hay REMANSO\n', Zesc, Zmax);
else
  printf('Zesc=%.2f m <= Zmax=%.4f m => el escalon NO altera el flujo\n', Zesc, Zmax);
end

%% 2) Nueva energia aguas arriba del escalon (flujo critico en la cresta)
EA = Ec + Zesc;
[y1_new, y3_new] = alternos_trap(b, m, Q, EA);
printf('\nEA = Ec + Zesc = %.4f m\n', EA);
printf('y1_new (subcritico, aguas arriba del escalon)  = %.4f m\n', y1_new);
printf('y3_new (supercritico, aguas abajo del escalon)  = %.4f m\n', y3_new);

%% 3) Curva M3 aguas abajo del escalon (supercritica, x creciente) hasta
%    encontrar el resalto con el perfil M1 original (Parte 1, sin
%    escalon), que sigue vigente lejos del escalon porque el Lago B
%    sigue siendo el control aguas abajo.
par3 = [Q, b, S0, n, yc, m];
opt3 = odeset('Events', @(x,y) critico(x,y,par3));
[xM3, yM3] = ode23(@(x,y) rect(x,y,par3), [xesc L], y3_new, opt3);
[xM3, idx] = sort(xM3); yM3 = yM3(idx);

% conjugado de cada punto de la curva M3
yconjM3 = NaN(size(yM3));
for i = 1:length(yM3)
  [~,Ai] = trap_geom(yM3(i), b, m);
  Fr2i = (Q^2)*(b+2*m*yM3(i))/(g*Ai^3);
  if Fr2i > 1
    [~, yc_i] = Mom_trap(yM3(i), b, m, Q);
    yconjM3(i) = yc_i;
  end
end
mask = ~isnan(yconjM3) & xM3 <= max(xp);
xM3v = xM3(mask); yconjM3v = yconjM3(mask);

% perfil M1 original interpolado en ese rango de x
yM1_int = interp1(xp, yp, xM3v, 'linear');
diffy = yconjM3v - yM1_int;
idxcross = find(diffy(1:end-1).*diffy(2:end) <= 0);

if isempty(idxcross)
  printf('\nNo se encontro interseccion (resalto) en el rango integrado.\n');
  x_resalto = NaN; y_antes = NaN; y_despues = NaN;
else
  i = idxcross(1);
  xA_ = xM3v(i); xB_ = xM3v(i+1);
  fA_ = diffy(i); fB_ = diffy(i+1);
  x_resalto = xA_ - fA_*(xB_-xA_)/(fB_-fA_);
  y_antes = interp1(xM3, yM3, x_resalto);
  y_despues = interp1(xM3v, yconjM3v, x_resalto);
  printf('\nRESALTO HIDRAULICO:\n');
  printf('  x_resalto = %.2f m (desde el inicio del canal, Lago A)\n', x_resalto);
  printf('  distancia desde el escalon (x=700m) = %.2f m\n', x_resalto - xesc);
  printf('  y antes del resalto (curva M3, supercritico)  = %.4f m\n', y_antes);
  printf('  y despues del resalto (conjugado, sobre M1)   = %.4f m\n', y_despues);
end

figure('visible','off'); hold on; grid on;
plot(xp, yp, 'g-', 'LineWidth', 2);              % M1 original (Parte 1)
plot(xM3, yM3, 'b-', 'LineWidth', 2);             % M3 aguas abajo del escalon
plot(xM3v, yconjM3v, 'r--', 'LineWidth', 1.5);    % conjugado de M3
plot([0 L],[yn yn],'--m'); plot([0 L],[yc yc],'--k');
plot([xesc xesc],[y1_new y1_new-Zesc],'k-','LineWidth',3); % escalon (simbolico)
if ~isnan(x_resalto)
  plot(x_resalto, y_antes, 'ko', 'MarkerFaceColor','y','MarkerSize',8);
end
xlabel('x (m) [0=Lago A, 1500=Lago B]'); ylabel('y (m)');
legend('perfil sin escalon (M1)', 'curva M3 (aguas abajo escalon)', ...
       'conjugado M3', 'y_n', 'y_c', 'escalon', 'resalto', 'Location','best');
title('Ejercicio 1, Parte 2: perfil con escalon en x=700m');
print('ej1_perfil_parte2.png', '-dpng');

save('part2.mat', 'Q','b','m','n','S0','L','yn','yc','xp','yp', ...
     'xesc','Zesc','y1_sin','E1_sin','Ec','Zmax','EA','y1_new','y3_new', ...
     'x_resalto','y_antes','y_despues');
