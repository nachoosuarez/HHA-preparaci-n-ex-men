% Ejercicio1_FGV_doslagos.m — Examen HHA diciembre 2022, Ejercicio 1.
% Canal RECTANGULAR (b=1.5m, n=0.011, S0=0.009, L=35m) entre Lago 1
% (aguas arriba) y Lago 2 (aguas abajo). Resuelve:
%  1) hL1=1.35m, hL2=-0.5m: Q, clasificación M/S, perfil y tirantes.
%  2) Rango de hL2 (hL2min, hL2max) para que exista resalto en el canal.
%  3) hL1=1.35m, hL2=1.5m: Q, y1, y2 (Lago 2 controla, canal ahogado).
%
% Idea física (ver RESUMEN_TEORICO.md, A4):
%  - Entrada (Lago1 -> canal): transición con CONTRACCIÓN, se conserva
%    energía: E(y_entrada) = hL1 (sin pérdidas).
%  - Salida (canal -> Lago2): transición con EXPANSIÓN brusca hacia el
%    lago, se disipa la energía cinética: y_salida = hL2 DIRECTAMENTE
%    (el nivel del lago es igual al tirante en la última sección, sin
%    sumar el término V²/2g).
%  - Mientras el canal sea tipo S y la entrada se mantenga crítica
%    (yc en x=0), Q sólo depende de hL1 (lago 2 no controla la entrada,
%    salvo que su remanso llegue a "ahogarla": ver Parte 2 y 3).
%
% Requiere (mismo directorio): rect_geom.m, rect.m, critico.m,
% froude_rect.m, manning_rect.m, Mom_rect.m, Eesp_rect.m.

%% Datos de entrada
b  = 1.5;    % ancho de fondo (m)
n  = 0.011;  % n de Manning
S0 = 0.009;  % pendiente de fondo
L  = 35;     % longitud del canal (m)
g  = 9.8;

opts = odeset('RelTol',1e-10,'AbsTol',1e-12); % tolerancia fina: cerca de
% yc la EDO es casi singular y con tolerancia por defecto el resultado
% de y2 se aparta notoriamente del valor correcto (ver RESOLUCION.md).

%% ---------------- PARTE 1: hL1=1.35, hL2=-0.5 ----------------
hL1 = 1.35;

% Control crítico en la entrada (se verifica canal tipo S a posteriori):
% E(yc) = 1.5*yc = hL1  (cerrado, sección rectangular)
yc = hL1/1.5;
Q  = b*sqrt(g*yc^3);

% Tirante normal (Manning, fsolve)
yn0 = (Q*n/(b*S0^0.5))^(3/5);
yn  = fsolve(@(y) manning_rect(y,[Q b S0 n]), yn0);

tipo = 'S'; if yn >= yc, tipo = 'M'; end
printf('PARTE 1: yc=%.4f m | Q=%.4f m3/s | yn=%.4f m | canal tipo %s (yn %s yc)\n', ...
       yc, Q, yn, tipo, merge(yn<yc,'<','>='));

% Perfil (curva S2, decrece desde yc en x=0 hacia yn): integrar dy/dx
[xs1, ys1] = ode45(@(x,y) rect(x,y,[Q b S0 n]), [0 L], yc - 1e-6, opts);
y2_libre = ys1(end);
printf('  y(x=0)=yc=%.4f m (control) -> y(x=%d m)=%.4f m  [hL2=-0.5 no controla, descarga libre]\n', ...
       yc, L, y2_libre);

%% ---------------- PARTE 2: rango de hL2 para resalto ----------------
% hL2min: resalto justo en la SALIDA (x=L). Post-salto = conjugado del
% tirante libre y2_libre (Mom_rect), y por la regla de la salida ese
% conjugado ES directamente hL2min (sin V^2/2g).
[~, y2_conj] = Mom_rect(y2_libre, b, Q);
hL2min = y2_conj;

% hL2max: resalto justo en la ENTRADA (x=0), es decir el canal entero
% queda subcrítico (curva creciendo desde yc). Se integra la rama
% subcrítica desde x=0 (y=yc+eps) hasta x=L; hL2max = y(x=L) directo.
[xs2, ys2] = ode45(@(x,y) rect(x,y,[Q b S0 n]), [0 L], yc + 1e-6, opts);
hL2max = ys2(end);

printf('PARTE 2: hL2min=%.4f m  <  hL2  <  hL2max=%.4f m  (para que exista resalto)\n', hL2min, hL2max);

%% ---------------- PARTE 3: hL1=1.35, hL2=1.5 ----------------
hL2_3 = 1.5;

% hL2_3 > hL2max => el Lago 2 "ahoga" toda la entrada: ya no hay control
% crítico en x=0. Q disminuye y se itera (fzero) para que, integrando la
% rama subcrítica hacia atrás desde (x=L, y=hL2_3), la energía en la
% entrada cierre con hL1 (contracción sin pérdidas: E(y0)=hL1).
resid = @(Qtry) residuo_entrada_lago(Qtry, b, S0, n, g, L, hL2_3, opts) - hL1;
Q3 = fzero(resid, [1 6]);
[xs3, ys3] = ode45(@(x,y) rect(x,y,[Q3 b S0 n]), [L 0], hL2_3, opts);
y1_3 = ys3(end);

printf('PARTE 3: Q=%.4f m3/s | y1(x=0)=%.4f m | y2=hL2=%.4f m (Lago 2 controla, canal ahogado, sin resalto)\n', ...
       Q3, y1_3, hL2_3);
