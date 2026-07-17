% Ejercicio1_FGV_trapezoidal_relleno.m — Examen HHA 24/jul/2023, Ejercicio 1.
%
% Canal TRAPEZOIDAL (b=1.8 m, m=1, n=0.014) que conecta el Lago A
% (hLA=1.7 m sobre el fondo) con el Lago B (hLB=0.5 m sobre el fondo),
% longitud total L=100 m, pendiente de fondo S0=0.008 en toda su
% longitud (Parte 1).
%
% Parte 2: una obra de relleno cambia la pendiente de fondo a
% S02=0.0015 entre x=40 m y el final del canal (x=100 m); el tramo
% x=[0,40] m conserva S0=0.008.
%
% Requiere, en esta misma carpeta (copia del toolkit canonico
% RESUMEN EXAMEN/Codigos/FGV_trapezoidal): trap_geom.m, eq_yc.m, eq_yn.m,
% froude_trap.m, manning_trap.m, rect.m (=ODE de FGV trapezoidal, pese al
% nombre), critico.m, Mom_trap.m, control_critico_lago_trap.m.
%
% METODO (ver RESUMEN_TEORICO.md paragrafo A4, caso "canal de dos tramos
% con distinta pendiente entre dos lagos"):
% - Parte 1: se prueba la hipotesis "canal STEEP" (yn<yc con el S0 dado):
%   si es consistente, el Lago A descarga el caudal MAXIMO compatible con
%   su energia -> control CRITICO en la entrada (x=0): E(yc)=hLA. En
%   canal trapezoidal esto no tiene forma cerrada (a diferencia del
%   rectangular, E=1.5*yc): se itera Q con fzero para que
%   yc(Q) + Q^2/(2g*A(yc(Q))^2) = hLA.
% - Se integra la curva S2 (supercritica, decreciente hacia yn) desde
%   x=0 (y=yc) hasta el final del canal, y se compara el tirante de
%   salida con hLB: si hLB < y(salida), el Lago B queda por DEBAJO del
%   nivel que trae el canal -> no controla, se comporta como caida
%   libre (sin resalto).
% - Parte 2: como el tramo x=[0,40] no cambia (S0=0.008 igual que la
%   Parte 1), el control critico en la entrada sigue siendo el MISMO Q
%   (el Lago A no "sabe" que aguas abajo cambio la pendiente hasta que
%   el frente de la perturbacion llega, lo cual no ocurre nunca en flujo
%   supercritico: la informacion no viaja hacia aguas arriba). Se
%   reutiliza la curva S2 de la Parte 1 hasta x=40 m.
% - En x=40 cambia la pendiente a S02=0.0015 (mas suave). Se calcula
%   yn2 con S02: si yn2>yc, el tramo 2 es MILD. La curva supercritica
%   que entra en el tramo 2 (y<yc, tipo M3: crece hacia yc) se integra
%   con la ODE de FGV usando S02 hasta que cruza yc o hasta x=100.
% - El control de salida (x=100): hLB=0.5 m < yc -> el Lago B no
%   controla (queda por debajo del critico) -> la salida se comporta
%   como caida libre, y(100)=yc, alimentando una curva M2 (subcritica)
%   que se integra HACIA ATRAS desde x=100 hasta x=40.
% - Como la rama que entra al tramo 2 es supercritica (M3, y<yc) y la
%   rama de salida es subcritica (M2, y>yc), debe haber un RESALTO
%   dentro del tramo 2: se ubica comparando, en la misma malla de x, el
%   CONJUGADO (Mom_trap) de la rama M3 contra el valor real de la rama
%   M2 (RESUMEN_TEORICO.md, S:A3).

clc; clear; close all;
warning('off','all');

%% ==== EDITAR ACA (datos del enunciado) ====
b   = 1.8;    % ancho de fondo (m)
m   = 1;      % talud lateral 1V:mH
n   = 0.014;  % Manning
g   = 9.8;
hLA = 1.7;    % nivel Lago A sobre el fondo del canal (m)
hLB = 0.5;    % nivel Lago B sobre el fondo del canal (m)
L   = 100;    % longitud total del canal (m)
S0  = 0.008;  % pendiente de fondo original (toda la longitud, Parte 1)
opt = optimset('Display','off');
%% ============================================

fprintf('=================== PARTE 1: canal uniforme, S0=%.4f ===================\n', S0);

% --- Control critico en la entrada (Lago A -> canal), iterando Q ---
% yc(Q) resuelve eq_yc; se itera Q para que E(yc)=hLA (ver
% control_critico_lago_trap.m, toolkit canonico).
[Q,yc] = control_critico_lago_trap(hLA,b,m,[1 30]);
[Bc,Ac] = trap_geom(yc,b,m);
Ec = yc + Q^2/(2*g*Ac^2);
fprintf('Control critico en la entrada: E(yc)=yc+Q^2/(2g*A(yc)^2)=hLA (fzero en Q)\n');
fprintf('  Q = %.3f m3/s ; yc = %.4f m ; A(yc) = %.4f m2 ; chequeo E = %.4f m (hLA=%.2f m)\n', Q, yc, Ac, Ec, hLA);

% --- Tirante normal con S0, para clasificar el canal ---
yn = fsolve(@(y) eq_yn(y,Q,n,m,b,S0), 1, opt);
fprintf('Tirante normal (Manning, S0=%.4f): yn = %.4f m\n', S0, yn);
if yn < yc
    fprintf('  yn < yc => CANAL TIPO S (steep) -> control critico en la entrada es CONSISTENTE\n');
else
    error('yn > yc: la hipotesis de canal steep no es consistente; revisar planteo.');
end

% --- Curva S2: integrar desde x=0 (y=yc) hasta x=L=100 m ---
par1 = [Q b S0 n yc m];
xg = linspace(0, L, 4001);
options_ev = odeset('Events', @(x,y) critico(x,y,par1));
[x1, yS2] = ode23(@(x,y) rect(x,y,par1), xg, yc*(1-1e-4), options_ev);
y_100 = yS2(end);
fprintf('Curva S2 (x=0 -> x=%d m): y(0)=%.4f m -> y(%d)=%.4f m (asintotico a yn=%.4f m)\n', L, yS2(1), round(x1(end)), y_100, yn);

% --- Control de salida (Lago B) ---
if hLB < y_100
    fprintf('Control de salida: hLB=%.2f m < y(%d)=%.4f m => el Lago B NO controla (queda por debajo\n', hLB, L, y_100);
    fprintf('  del nivel que trae el canal) -> descarga como CAIDA LIBRE, SIN resalto en todo el canal.\n');
else
    fprintf('Control de salida: hLB=%.2f m > y(%d)=%.4f m => el Lago B SI controla (analizar resalto).\n', hLB, L, y_100);
end

fprintf('\nRESUMEN PARTE 1: Q=%.3f m3/s | yc=%.3f m | yn=%.3f m | canal tipo S | curva S2 pura, sin resalto\n', Q, yc, yn);
Q1 = Q; yc1 = yc; yn1_completo = yn; y_salida_parte1 = y_100;


fprintf('\n=================== PARTE 2: relleno, S02=0.0015 entre x=40 y x=100 m ===================\n');
x_cambio = 40;
S02 = 0.0015;

% El tramo x=[0,40] no cambia (mismo S0=0.008): el control critico en la
% entrada sigue siendo el MISMO Q, yc (informacion no viaja hacia aguas
% arriba en flujo supercritico).
Q = Q1; yc = yc1;
fprintf('Tramo 1 (x=[0,%d] m) sin cambios: reutiliza Q=%.3f m3/s, yc=%.4f m de la Parte 1.\n', x_cambio, Q, yc);

% Tirante normal del tramo 2 (S02)
yn2 = fsolve(@(y) eq_yn(y,Q,n,m,b,S02), 1, opt);
fprintf('Tirante normal tramo 2 (Manning, S02=%.4f): yn2 = %.4f m\n', S02, yn2);
if yn2 > yc
    fprintf('  yn2 > yc => TRAMO 2 TIPO M (mild)\n');
else
    fprintf('  yn2 < yc => TRAMO 2 TIPO S (steep) -- caso no esperado con este enunciado\n');
end

% Curva S2 en tramo 1, evaluada hasta x=40 m (mismo par1, mismo Q y yc)
xg_t1 = linspace(0, x_cambio, 1601);
[xt1, yS2_t1] = ode23(@(x,y) rect(x,y,par1), xg_t1, yc*(1-1e-4), options_ev);
y40 = yS2_t1(end);
fprintf('Curva S2 en tramo 1: y(x=%d)=%.4f m (< yc=%.4f m, sigue supercritica)\n', x_cambio, y40, yc);

% Curva supercritica (tipo M3) que entra al tramo 2 con S02, desde x=40
par2 = [Q b S02 n yc m];
xg_t2 = linspace(x_cambio, L, 2401);
options_ev2 = odeset('Events', @(x,y) critico(x,y,par2));
[xM3, yM3] = ode23(@(x,y) rect(x,y,par2), xg_t2, y40, options_ev2);
fprintf('Curva M3 en tramo 2 (supercritica, creciendo hacia yc): y(x=%d)=%.4f m -> y(x=%.1f)=%.4f m\n', ...
        x_cambio, yM3(1), xM3(end), yM3(end));

% Control de salida (x=100): hLB < yc => Lago B no controla => caida
% libre, y(100)=yc; se integra la curva M2 (subcritica) HACIA ATRAS.
fprintf('Control de salida (x=%d): hLB=%.2f m < yc=%.4f m => Lago B NO controla => caida libre, y(%d)=yc\n', L, hLB, yc, L);
xg_M2 = linspace(L, x_cambio, 2401);
[xM2, yM2] = ode23(@(x,y) rect(x,y,par2), xg_M2, yc*(1+1e-4), options_ev2);
fprintf('Curva M2 en tramo 2 (subcritica, HACIA ATRAS desde x=%d): y(%d)=%.4f m -> y(%d)=%.4f m\n', ...
        L, L, yM2(1), round(xM2(end)), yM2(end));

% --- Ubicacion del resalto: cruce entre el conjugado de la rama M3 y la
%     rama M2, sobre una malla comun de x ---
x_comun = linspace(x_cambio, min(xM3(end), L), 400);
yM3_i = interp1(xM3, yM3, x_comun);
yM2_i = interp1(xM2, yM2, x_comun, 'linear', 'extrap');

conjM3 = zeros(size(x_comun));
for k = 1:numel(x_comun)
    [~, yc_k] = Mom_trap(yM3_i(k), b, m, Q);
    conjM3(k) = yc_k;
end

dif = yM2_i - conjM3;
idx = find(dif(1:end-1).*dif(2:end) < 0, 1, 'first');
if isempty(idx)
    fprintf('*** No se encontro cruce del conjugado dentro de [%d,%.1f] m: revisar rango de integracion ***\n', x_cambio, xM3(end));
    x_resalto = NaN; y1_resalto = NaN; y2_resalto = NaN;
else
    x_resalto  = interp1(dif(idx:idx+1), x_comun(idx:idx+1), 0);
    y1_resalto = interp1(x_comun(idx:idx+1), yM3_i(idx:idx+1), x_resalto);
    y2_resalto = interp1(x_comun(idx:idx+1), yM2_i(idx:idx+1), x_resalto);
    fprintf('RESALTO en x = %.1f m (%.1f m dentro del tramo 2): y = %.4f m -> y = %.4f m\n', ...
            x_resalto, x_resalto - x_cambio, y1_resalto, y2_resalto);
end

fprintf('\nRESUMEN PARTE 2: Q=%.3f m3/s (igual que Parte 1) | Tramo1 [0,%d] S (yc=%.3f m) | Tramo2 [%d,%d] M (yn2=%.3f m)\n', ...
        Q, x_cambio, yc, x_cambio, L, yn2);
fprintf('  Perfil: yc=%.3f en x=0 -> curva S2 hasta y=%.3f en x=%d -> curva M3 hasta y=%.3f en x=%.1f\n', ...
        yc, y40, x_cambio, y1_resalto, x_resalto);
fprintf('  -> RESALTO (%.3f -> %.3f m) -> curva M2 hasta y=yc=%.3f en x=%d (caida libre al Lago B)\n', ...
        y1_resalto, y2_resalto, yc, L);
