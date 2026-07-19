% Ejercicio1_FGV_trapezoidal_compuerta.m
% HHA 22/12/2020 - Ejercicio 1 (variante "A": Q=22 m3/s, a=0.85 m, GH 85/15)
%
% Canal trapezoidal semi-infinito (b=2.4 m, m=2H:1V, S0=0.0005, n=0.016,
% Q=22 m3/s) que termina en caida libre. Se pide:
%  1) Clasificar el canal M/S y describir el perfil sin compuerta.
%  2) Con una compuerta de fondo ideal (a=0.85 m) ubicada 500 m aguas
%     arriba de la caida libre: perfil completo, tirantes y resalto.
%  3) Fuerza sobre la compuerta y potencia disipada en el resalto.
%  4) Maxima apertura a para la cual la compuerta descarga libre.
%
% Requiere en el mismo directorio: trap_geom.m, eq_yc.m, eq_yn.m,
% froude_trap.m, manning_trap.m, critico.m, rect.m, Mom_trap.m,
% Eesp_trap.m.

clear all; close all; clc;
addpath(pwd);
warning('off','all');  % silencia warnings de encoding (comentarios con tildes) del toolkit

%% ==== DATOS DE ENTRADA ====
Q  = 22;      % caudal (m3/s)
b  = 2.4;     % ancho de fondo (m)
m  = 2;       % talud lateral 1V:mH
S0 = 0.0005;  % pendiente de fondo
n  = 0.016;   % Manning
a  = 0.85;    % apertura de la compuerta (m)
Lg = 500;     % distancia de la compuerta a la caida libre (m)
g  = 9.81;

%% ==== PARTE 1: yc, yn, clasificacion ====
yc = fsolve(@(y) froude_trap(y,[Q b m]), (Q^2/(g*b^2))^(1/3));
yn = fsolve(@(y) manning_trap(y,[Q b S0 n m]), (Q*n/(b*sqrt(S0)))^(3/5));

fprintf('\n=== PARTE 1 ===\n');
fprintf('yc = %.4f m\n', yc);
fprintf('yn = %.4f m\n', yn);
if yn > yc
  fprintf('yn > yc  => CANAL TIPO M (pendiente suave)\n');
else
  fprintf('yn < yc  => CANAL TIPO S (pendiente fuerte)\n');
end
fprintf('Sin compuerta: caida libre en la salida (y=yc), curva M2 creciendo\n');
fprintf('hacia yn aguas arriba.\n');

%% ==== PARTE 2: aguas arriba de la compuerta (energia, gate ideal) ====
% Compuerta ideal: se conserva energia entre la seccion justo aguas
% arriba (y1) y la vena contraida aguas abajo (y=a). y1 = alterno de a.
[Ea, y1] = Eesp_trap(a, b, Q, m);
fprintf('\n=== PARTE 2 ===\n');
fprintf('E(a=%.2f) = %.4f m\n', a, Ea);
fprintf('y1 (aguas arriba de la compuerta, alterno de a) = %.4f m\n', y1);

% Chequeo libre/ahogada: conjugado de a (momento) vs. tirante que traeria
% la curva M2 de aguas abajo (backwater desde la caida libre) en x=0
par2 = [Q b S0 n yc m];
opt2 = odeset('Events', @(x,y) critico(x,y,par2));
[x2, y2] = ode23(@(x,y) rect(x,y,par2), [Lg 0], yc+1e-4, opt2);
[x2, idx2] = sort(x2); y2 = y2(idx2);
y_tw_gate = interp1(x2, y2, 0, 'linear');   % tirante "M2" en x=0 (gate) si no hubiera resalto antes

[~, a_conj] = Mom_trap(a, b, m, Q);
fprintf('Conjugado de a (Mom_trap) = %.4f m\n', a_conj);
fprintf('Tirante M2 (sin resalto) en la compuerta = %.4f m\n', y_tw_gate);
if a_conj > y_tw_gate
  fprintf('=> a_conj > y_M2(gate): DESCARGA LIBRE (el resalto se forma aguas abajo,\n');
  fprintf('   donde el conjugado de la curva M3 iguala a la curva M2)\n');
else
  fprintf('=> a_conj < y_M2(gate): DESCARGA AHOGADA (resalto sumergido contra la compuerta)\n');
end

%% Rama supercritica aguas abajo de la compuerta (M3), x=0 en la compuerta
par1 = [Q b S0 n yc m];
opt1 = odeset('Events', @(x,y) critico(x,y,par1));
[x1, y1s] = ode23(@(x,y) rect(x,y,par1), [0 Lg], a, opt1);

%% Conjugado de la rama supercritica
y_s1 = NaN(size(y1s));
for i = 1:length(y1s)
  [~,A,~,~,~,D] = trap_geom(y1s(i), b, m);
  Fr = (Q/A)/sqrt(g*D);
  if Fr > 1
    [~, yc_i] = Mom_trap(y1s(i), b, m, Q);
    y_s1(i) = yc_i;
  end
end
mask = ~isnan(y_s1);
x_s1v = x1(mask); y_s1v = y_s1(mask);

%% Interseccion conjugado(M3) con M2 (=> resalto)
y2_int = interp1(x2, y2, x_s1v, 'linear');
diffy = y_s1v - y2_int;
idxc = find(diffy(1:end-1).*diffy(2:end) <= 0, 1);
xA = x_s1v(idxc); xB = x_s1v(idxc+1);
fA = diffy(idxc); fB = diffy(idxc+1);
x_resalto = xA - fA*(xB-xA)/(fB-fA);
y_antes = interp1(x_s1v, y_s1v(:), x_resalto, 'linear'); % conjugado interpolado
y1_antes_real = interp1(x1, y1s, x_resalto, 'linear');   % tirante supercritico real (antes del resalto)
y_despues = interp1(x2, y2, x_resalto, 'linear');        % tirante subcritico (M2) en ese x

fprintf('\nResalto ubicado a x = %.2f m de la compuerta (%.2f m antes de la caida libre)\n', x_resalto, Lg-x_resalto);
fprintf('y (antes del resalto, supercritico) = %.4f m\n', y1_antes_real);
fprintf('y (despues del resalto, subcritico) = %.4f m\n', y_despues);

% Tirante en la caida libre y en la union con la M2 (extremos)
y_en_caida = interp1(x2, y2, Lg, 'linear');
fprintf('Tirante que llega a la caida libre = %.4f m (~yc=%.4f)\n', y_en_caida, yc);

%% ==== PARTE 3a: fuerza sobre la compuerta ====
[M1,~] = Mom_trap(y1, b, m, Q);   % momento aguas arriba de la compuerta
[Ma,~] = Mom_trap(a,  b, m, Q);   % momento en la vena contraida (aguas abajo)
F_compuerta = 1000*g*(M1 - Ma);
fprintf('\n=== PARTE 3 ===\n');
fprintf('M(y1=%.4f) = %.4f m3\n', y1, M1);
fprintf('M(a=%.4f)  = %.4f m3\n', a, Ma);
fprintf('Fuerza sobre la compuerta F = rho*g*(M1-Ma) = %.2f kN\n', F_compuerta/1000);

%% ==== PARTE 3b: potencia disipada en el resalto ====
[E_antes, ~] = Eesp_trap(y1_antes_real, b, Q, m);
[E_despues, ~] = Eesp_trap(y_despues, b, Q, m);
P_dis = 1000*g*Q*(E_antes - E_despues);
fprintf('E antes del resalto  = %.4f m\n', E_antes);
fprintf('E despues del resalto = %.4f m\n', E_despues);
fprintf('Potencia disipada en el resalto P = rho*g*Q*(E1-E2) = %.2f kW\n', P_dis/1000);

%% ==== PARTE 4: apertura maxima para descarga libre ====
% Umbral: conjugado(a_max) = tirante M2 (sin resalto) en la compuerta (x=0)
a_max = fsolve(@(aa) conjugado_de_a(aa,b,m,Q) - y_tw_gate, 0.9);
fprintf('\n=== PARTE 4 ===\n');
fprintf('Tirante M2 en la compuerta (independiente de a) = %.4f m\n', y_tw_gate);
fprintf('a_max (descarga libre <=> conjugado(a) >= y_M2(gate)) = %.4f m\n', a_max);
