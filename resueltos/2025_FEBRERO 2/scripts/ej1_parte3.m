%% Ejercicio 1, Parte 3 - Examen HHA 5 de febrero 2025 (2025_FEBRERO 2)
% Tuberia de altura A=0.35 m > Dmax (Parte 2) => se produce remanso.
% Se determina el perfil completo: M1 aguas arriba de la tuberia,
% seccion critica en la cresta, M3 aguas abajo de la tuberia hasta el
% resalto hidraulico, y M2 (sin alterar, de la Parte 1) hasta la caida
% libre.

clear all; close all; clc;
load('part1.mat');   % Q,b,m,n,S0,g,yc,yn,x,y (perfil M2 sin alterar), y_m300
load('part2.mat');   % y1(=1.1705, sin alterar), E1, Ec, Dmax

A_tub = 0.35;   % altura de la tuberia (m)

%% Nueva energia especifica aguas arriba de la tuberia (seccion 1)
% En la cresta (seccion 2) el flujo pasa por critico (A_tub > Dmax):
% E1_new = Ec + A_tub
E1_new = Ec + A_tub;
fprintf('E1_new = Ec + A = %.4f m\n', E1_new);

%% Tirante y1_new (subcritico, rama y>yc) con esa energia especifica
[yalt1, yalt2] = alternos_trap(b, m, Q, E1_new);
% alternos_trap devuelve un tirante y su alterno; identificar cual es
% subcritico (>yc) y cual supercritico (<yc)
if yalt1 > yc
    y1_new = yalt1; y3_new = yalt2;
else
    y1_new = yalt2; y3_new = yalt1;
end

fprintf('y1_new (subcritico, aguas arriba tuberia) = %.4f m\n', y1_new);
fprintf('y3_new (supercritico, alterno = aguas abajo tuberia) = %.4f m\n', y3_new);

%% Verificacion: hay remanso (y1_new > y1 sin alterar de la Parte 1)
fprintf('\nComo A=%.2fm > Dmax=%.4fm => y1_new=%.4f m > y1 sin alterar=%.4f m => HAY REMANSO\n',...
    A_tub, Dmax, y1_new, y1);

%% Curva M3 aguas abajo de la tuberia (x=-300 m) hasta el resalto
% Se integra desde x=-300 (y=y3_new, supercritico) en direccion aguas
% abajo (x creciente) hasta cortar el conjugado de la curva M2 (Parte 1).
par3 = [Q b S0 n yc m];
opt3 = odeset('Events', @(x,yy) critico(x,yy,par3));
[x3, y3] = ode23(@(x,yy) rect(x,yy,par3), [-300 0], y3_new, opt3);
[x3, idx3] = sort(x3); y3 = y3(idx3);

fprintf('\nCurva M3: desde x=-300m (y=%.4f m) hasta x=%.2fm (y=%.4f m)\n', ...
    y3_new, x3(end), y3(end));

%% Conjugado de la curva M3 en cada punto, y comparacion con la curva M2
yconj3 = NaN(size(x3));
for i = 1:length(x3)
    [~, A3i] = trap_geom(y3(i), b, m);
    Fr2 = Q^2*( (b+2*m*y3(i)) )/(g*A3i^3);
    if Fr2 > 1   % solo tiene sentido calcular conjugado en zona supercritica
        [~, yc_i] = Mom_trap(y3(i), b, m, Q);
        yconj3(i) = yc_i;
    end
end

y2_M2_en_x3 = interp1(x, y, x3, 'linear');  % perfil M2 (Parte 1) evaluado en x3

diffy = yconj3 - y2_M2_en_x3;
mask = ~isnan(diffy);
xm = x3(mask); dm = diffy(mask);
signchange = find(dm(1:end-1).*dm(2:end) <= 0);

if isempty(signchange)
    error('No se encontro interseccion entre el conjugado de M3 y la curva M2');
end
k = signchange(1);
xA = xm(k); xB = xm(k+1); fA = dm(k); fB = dm(k+1);
x_res = xA - fA*(xB-xA)/(fB-fA);
y_res_M3 = interp1(x3, y3, x_res, 'linear');
[~, y_res_conj] = Mom_trap(y_res_M3, b, m, Q);

fprintf('\nRESALTO HIDRAULICO:\n');
fprintf('  x_resalto = %.2f m (medido desde la caida libre)\n', x_res);
fprintf('  Distancia desde la tuberia (x=-300m) hasta el resalto = %.2f m\n', x_res-(-300));
fprintf('  y antes del resalto (rama M3) = %.4f m\n', y_res_M3);
fprintf('  y despues del resalto (conjugado, sobre curva M2) = %.4f m\n', y_res_conj);

%% Perfil completo aguas arriba de la tuberia (curva M1, remanso)
% Se integra desde x=-300 (y=y1_new) hacia aguas arriba (x decreciente)
par1u = [Q b S0 n yc m];
opt1u = odeset('Events', @(x,yy) critico(x,yy,par1u));
[x1u, y1u] = ode23(@(x,yy) rect(x,yy,par1u), [-300 -1000], y1_new, opt1u);
[x1u, idx1u] = sort(x1u); y1u = y1u(idx1u);

save('part3.mat','A_tub','E1_new','y1_new','y3_new','x3','y3','x_res','y_res_M3','y_res_conj','x1u','y1u');

%% Grafico del perfil completo con la tuberia
figure(1); clf; hold on; grid on;
% M1 aguas arriba de la tuberia
plot(x1u, y1u, 'b-', 'LineWidth', 2);
% escalon (tuberia) - salto vertical en x=-300 (esquematico, longitud despreciable)
plot([-300 -300], [y1_new y3_new], 'k:', 'LineWidth', 1.5);
% M3 aguas abajo de la tuberia hasta el resalto
m3plot = x3 <= x_res;
plot(x3(m3plot), y3(m3plot), 'r-', 'LineWidth', 2);
% resalto (linea vertical esquematica)
plot([x_res x_res], [y_res_M3 y_res_conj], 'k--', 'LineWidth', 1.5);
% M2 desde el resalto hasta la caida libre (perfil de la Parte 1, sin alterar)
m2plot = x >= x_res;
plot(x(m2plot), y(m2plot), 'm-', 'LineWidth', 2);
plot([-1000 0],[yc yc],'--r'); plot([-1000 0],[yn yn],'--g');
xlabel('x (m) [0 = caida libre]'); ylabel('y (m)');
title('Ejercicio 1 Parte 3 - Perfil con tuberia A=0.35m (remanso + resalto)');
legend('M1 (remanso)','escalon','M3','resalto','M2 (a la caida libre)','y_c','y_n','Location','best');
print('ej1_perfil_parte3.png', '-dpng', '-r120');
