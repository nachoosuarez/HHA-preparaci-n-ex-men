% Ejercicio1_FGV_trapezoidal_3tramos.m — Examen HHA 25/jul/2022, Ejercicio 1.
% Lago A -> canal trapezoidal de TRES tramos (S=0.03 muy largo / S=0
% horizontal, 100m / S=0.0015, 70m) -> Lago B.
% b=1.3m, m=2 (talud 1V:2H), n=0.017.
%
% Parte 1: caudal de descarga del Lago A (hLA=1.43m) -> control critico
%          en la entrada del tramo I (canal muy largo y steep).
% Parte 2: con hLB=0.8m, clasificar tramos I y III (M o S) y ubicar el
%          resalto hidraulico en el perfil completo.
% Parte 3: hallar el hLB umbral a partir del cual el resalto pasa del
%          tramo II al tramo I.
%
% Requiere (mismo directorio "RESUMEN EXAMEN/Codigos/FGV_trapezoidal"):
% trap_geom.m, eq_yc.m, eq_yn.m, control_critico_lago_trap.m, rect.m,
% critico.m, Mom_trap.m.
%
% Convencion de coordenadas: x=0 en el Lago A (entrada tramo I), x
% creciente en el sentido del flujo. Union tramo I/II en x=xI (variable,
% tramo I es "muy largo"); tramo II ocupa 100 m; tramo III ocupa 70 m
% hasta el Lago B. Para integrar cada tramo se usa una coordenada local
% con origen en su propia union aguas abajo (ver comentarios en cada
% bloque).

clear; clc;
addpath(fileparts(mfilename('fullpath')));
addpath([fileparts(mfilename('fullpath')) filesep '..' filesep '..' filesep '..' filesep ...
         'RESUMEN EXAMEN' filesep 'Codigos' filesep 'FGV_trapezoidal']);

g = 9.8;
b = 1.3; m_talud = 2; n = 0.017;
hLA = 1.43;
hLB = 0.8;
LII  = 100;   % tramo II (horizontal)
LIII = 70;    % tramo III (S=0.0015)
SI   = 0.03;
SII  = 0;
SIII = 0.0015;

opt = optimset('Display','off');

%% ---------- PARTE 1: caudal de descarga del Lago A ----------
% Tramo I es "de gran longitud (infinita)": el lago descarga su caudal
% maximo compatible con su energia -> control critico en la entrada
% (x=0), sin importar lo que pase aguas abajo (A4 del resumen teorico).
[Q, yc] = control_critico_lago_trap(hLA, b, m_talud);

yn_I   = fsolve(@(y) eq_yn(y,Q,n,m_talud,b,SI),   1, opt);
yn_III = fsolve(@(y) eq_yn(y,Q,n,m_talud,b,SIII), 1, opt);

fprintf('===== PARTE 1 =====\n');
fprintf('Q  = %.4f m3/s\n', Q);
fprintf('yc = %.4f m\n', yc);
fprintf('yn_I   (S=%.4f) = %.4f m  -> yn_I < yc  => tramo I  STEEP (S)\n', SI, yn_I);
fprintf('yn_III (S=%.4f) = %.4f m  -> yn_III > yc => tramo III MILD (M)\n', SIII, yn_III);

%% ---------- PARTE 2: perfil completo para hLB=0.8m ----------
% hLB < yc => el Lago B no puede ahogar la salida del tramo III (M):
% control critico en la salida (x=LIII, coordenada local del tramo III).
par3 = [Q b SIII n yc m_talud];
[~, y3] = ode23(@(x,y) rect(x,y,par3), [LIII, 0], yc*1.0005, ...
                odeset('RelTol',1e-9,'AbsTol',1e-9));
y_B = y3(end);   % tirante en la union II/III (curva M2 de tramo III)

% Tramo II horizontal: continua la rama subcritica (curva H2) desde la
% union con III (y=y_B) hacia aguas arriba hasta la union con I.
par2 = [Q b SII n yc m_talud];
[xH2, yH2] = ode23(@(x,y) rect(x,y,par2), [0, -LII], y_B, ...
                    odeset('RelTol',1e-10,'AbsTol',1e-10));
[xH2, ord] = sort(xH2); yH2 = yH2(ord);
y_A = yH2(1);  % tirante subcritico en la union I/II (x=-LII, primer punto tras ordenar)

% Tramo I es muy largo -> la rama supercritica (S2) ya convergio a yn_I
% mucho antes de llegar a la union con II: entra a tramo II con y=yn_I.
% OJO: dentro de tramo II esa rama supercritica NO se queda constante en
% yn_I -- al cambiar la pendiente de fondo a S=0 evoluciona segun su
% propia EDO (curva H3) hasta cruzar (o no) la rama subcritica H2.
[xH3, yH3] = ode23(@(x,y) rect(x,y,par2), [-LII, 0], yn_I, ...
                    odeset('RelTol',1e-10,'AbsTol',1e-10));
[xH3, ord] = sort(xH3); yH3 = yH3(ord);

% Conjugado punto a punto de la rama H3 (supercritica) y comparacion
% con la rama H2 (subcritica) en la MISMA x: el resalto esta donde cruzan.
yconjH3 = zeros(size(yH3));
for i = 1:numel(yH3)
  [~, yconjH3(i)] = Mom_trap(yH3(i), b, m_talud, Q);
end
yH2_i   = interp1(xH2, yH2, xH3, 'linear','extrap');
diffc   = yconjH3 - yH2_i;
k = find(diffc(1:end-1).*diffc(2:end) < 0, 1);
x_res = interp1(diffc(k:k+1), xH3(k:k+1), 0);
y1_res = interp1(xH3, yH3, x_res);   % tirante antes del resalto (supercritico)
y2_res = interp1(xH2, yH2, x_res);   % tirante despues del resalto (subcritico)
dist_res_A = x_res - (-LII);          % distancia medida desde la union I/II

fprintf('\n===== PARTE 2 (hLB = %.2f m) =====\n', hLB);
fprintf('y en salida a Lago B (control critico, x=%d)     = %.4f m\n', LIII, y3(1));
fprintf('y en union II/III (curva M2 de tramo III)         = %.4f m\n', y_B);
fprintf('y en union I/II   (curva H2 de tramo II)          = %.4f m\n', y_A);
fprintf('yn_I entrando a tramo II (curva S2 de tramo I)    = %.4f m\n', yn_I);
fprintf('RESALTO dentro de tramo II, a %.2f m de la union I/II:\n', dist_res_A);
fprintf('   y1 (antes, supercritico) = %.4f m\n', y1_res);
fprintf('   y2 (despues, subcritico) = %.4f m\n', y2_res);

%% ---------- PARTE 3: hLB umbral para que el resalto pase a tramo I ----------
% El resalto llega justo a la union I/II (x=-LII) cuando la rama H2
% (subcritica, propagada desde el Lago B) vale ahi exactamente el
% conjugado de yn_I (con yn_I aun sin evolucionar, recien entrando).
[~, yconj_I] = Mom_trap(yn_I, b, m_talud, Q);

perfil_union = @(hLB) perfil_union_fn(hLB,Q,b,m_talud,n,yc,SIII,SII,LII,LIII);
hLB_star = fzero(@(h) perfil_union(h) - yconj_I, [yc+1e-3, 5], opt);

fprintf('\n===== PARTE 3 =====\n');
fprintf('Conjugado de yn_I (objetivo en la union I/II) = %.4f m\n', yconj_I);
fprintf('hLB umbral = %.4f m\n', hLB_star);
fprintf('  hLB < %.2f m -> resalto dentro de tramo II (como en la Parte 2)\n', hLB_star);
fprintf('  hLB > %.2f m -> el resalto se corre al tramo I\n', hLB_star);

