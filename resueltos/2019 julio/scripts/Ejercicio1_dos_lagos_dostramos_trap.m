% Ejercicio1_dos_lagos_dostramos_trap.m — Examen HHA 22/jul/2019, Ejercicio 1.
%
% Canal TRAPEZOIDAL (b=3.8 m, m=1H:1V) que conecta el Lago A (hLA=2.0 m
% sobre el fondo, en x=0) con el Lago B (hLB variable, en x=L1+L2), en
% DOS TRAMOS con distinta pendiente Y distinta rugosidad:
%   Tramo 1: L1=35 m,   S01=0.018,  n1=0.017   (corto y empinado)
%   Tramo 2: L2=1000 m, S02=0.0006, n2=0.01    (largo y suave)
%
% Parte 1) hLB=2.6 m (dato). Se pide Q, clasificar M/S cada tramo y
%          dibujar la superficie libre con resaltos si los hay.
% Parte 2) hLB variable: rango de niveles del Lago B para el cual hay
%          resalto en el TRAMO 2.
%
% MÉTODO (ver RESUMEN_TEORICO.md §A4, "Canal de dos tramos con distinta
% PENDIENTE"; acá además difiere n, pero el razonamiento es el mismo):
% - Se prueba primero la hipótesis más simple: TRAMO 1 steep -> control
%   crítico en la entrada (x=0): y(0)=yc(Q), con energía
%   E(yc)=yc+Q^2/(2g A(yc)^2)=hLA. En sección trapezoidal yc(Q) no tiene
%   forma cerrada -> se anida fsolve(yc | Q) dentro de un fzero externo
%   en Q (mismo patrón que 2023 jul, Ej.1).
% - Se verifica autoconsistencia: yn1(Q) < yc(Q) => tramo 1 es
%   efectivamente steep (S) -> el lago A descarga su caudal máximo
%   SIN que importe lo que pase aguas abajo (mientras no lo ahogue).
% - Tramo 2: yn2(Q) vs yc(Q) clasifica el tramo 2 (aquí sale M/mild).
% - Se integra la curva S2 en el tramo 1 (supercrítica, desde yc en
%   x=0 hacia yn1) y se calcula su conjugado punto a punto (Mom_trap).
% - Se integra la curva de control de salida en el tramo 2 hacia atrás
%   desde el lago B (M1 si hLB>yn2, M2 si yn2>hLB>yc, crítico si
%   hLB<=yc) hasta la unión de tramos (x=L1).
% - Si el valor de esa curva subcrítica en x=L1 es MAYOR que el
%   conjugado de la curva S2 en x=L1: el resalto está dentro del TRAMO
%   1 -> se extiende la curva subcrítica hacia atrás usando la
%   pendiente/rugosidad del TRAMO 1 (S01,n1) y se busca su cruce con el
%   conjugado de la curva S2 (ambas ramas evaluadas con los mismos
%   S01,n1 en el tramo 1).
% - Si es MENOR: el resalto está dentro del TRAMO 2 (se hace el mismo
%   cruce pero con S02,n2).
%
% Requiere (mismo directorio, toolkit trapezoidal canónico):
% trap_geom.m, eq_yc.m, eq_yn.m, tirantes_yn_yc.m, Mom_trap.m, rect.m,
% critico.m, control_critico_lago_trap.m.

clc; clear; close all;
warning('off','all');

%% ==== EDITAR ACÁ (datos del enunciado) ====
b   = 3.8;     % ancho de fondo (m)
m   = 1.0;     % talud lateral 1V:mH
g   = 9.8;
hLA = 2.0;     % nivel Lago A sobre el fondo del canal, x=0 (m)
L1  = 35;      % longitud tramo 1 (m)
S01 = 0.018;   % pendiente de fondo tramo 1
n1  = 0.017;   % Manning tramo 1
L2  = 1000;    % longitud tramo 2 (m)
S02 = 0.0006;  % pendiente de fondo tramo 2
n2  = 0.01;    % Manning tramo 2
%% ============================================

opt = optimset('Display','off');

%% ============ PARTE 1: hLB = 2.6 m ============
hLB = 2.6;
fprintf('=================== PARTE 1: hLB = %.2f m ===================\n', hLB);

% --- Control crítico en la entrada (lago A -> tramo 1), sección trapezoidal ---
% control_critico_lago_trap.m ya resuelve el fzero(Q) + fsolve(yc) anidados.
[Q,yc] = control_critico_lago_trap(hLA,b,m,[1 60]);
fprintf('Control critico en la entrada (control_critico_lago_trap.m):\n');
fprintf('  Q = %.2f m3/s ; yc = %.3f m\n', Q, yc);

% --- Tirantes normales de cada tramo con este Q ---
yn1 = fsolve(@(y) eq_yn(y,Q,n1,m,b,S01), 1, opt);
yn2 = fsolve(@(y) eq_yn(y,Q,n2,m,b,S02), 1, opt);
fprintf('  yn1 (tramo1, S01=%.3f,n1=%.3f) = %.3f m ; yn2 (tramo2, S02=%.4f,n2=%.3f) = %.3f m\n', ...
        S01, n1, yn1, S02, n2, yn2);

if yn1 < yc
    fprintf('  yn1 < yc => TRAMO 1 TIPO S (steep) -> control critico en la entrada es CONSISTENTE\n');
else
    error('yn1 > yc: la hipotesis de tramo 1 steep no es consistente (revisar).');
end
if yn2 > yc, tipo2='M'; cmp2='>'; else, tipo2='S'; cmp2='<'; end
fprintf('  yn2 %s yc => TRAMO 2 TIPO %s\n', cmp2, tipo2);

% --- Curva S2 en tramo 1 (x: 0 -> L1), desde yc hacia yn1 ---
par1 = [Q b S01 n1 yc m];
xg1 = linspace(0, L1, 3001);
odeo = odeset('RelTol',1e-10,'AbsTol',1e-10);
[~, yS2] = ode45(@(x,y) rect(x,y,par1), xg1, yc*(1-1e-6), odeo);
yS2 = yS2(:);
fprintf('Curva S2 tramo1: y(x=0)=%.3f m -> y(x=%.0f)=%.3f m (yn1=%.3f m)\n', yS2(1), L1, yS2(end), yn1);

% --- Control de salida en tramo 2 (lago B) ---
if hLB <= yc
    fprintf('Control de salida: hLB=%.2f m <= yc=%.3f m => CAIDA LIBRE (critico en x=%.0f)\n', hLB, yc, L1+L2);
    y_sal_ctrl = yc;
else
    fprintf('Control de salida: hLB=%.2f m > yc=%.3f m => lago B controla, y(x=%.0f)=hLB\n', hLB, yc, L1+L2);
    y_sal_ctrl = hLB;
end

% --- Curva subcritica en tramo 2, integrada hacia atras desde el lago B hasta x=L1 ---
par2 = [Q b S02 n2 yc m];
xg2 = linspace(L1+L2, L1, 3001);
[~, yTr2_rev] = ode45(@(x,y) rect(x,y,par2), xg2, y_sal_ctrl*(1+1e-6), odeo);
y_tr2_en_L1 = yTr2_rev(end);
fprintf('Curva subcritica tramo2 (integrada hacia atras): y(x=%.0f)=%.3f m (control) -> y(x=%.0f)=%.3f m\n', ...
        L1+L2, yTr2_rev(1), L1, y_tr2_en_L1);

% --- Comparacion en la union de tramos x=L1: conjugado de S2 vs curva subcritica tramo2 ---
[~, conj_S2_L1] = Mom_trap(yS2(end), b, m, Q);
fprintf('En x=%.0f m: conjugado(y_S2)=%.3f m  vs  y_tramo2=%.3f m\n', L1, conj_S2_L1, y_tr2_en_L1);

if y_tr2_en_L1 > conj_S2_L1
    fprintf('  => y_tramo2 > conjugado(S2): el resalto esta DENTRO DEL TRAMO 1.\n');
    % Extender la curva subcritica hacia atras DENTRO del tramo 1 (S01,n1).
    % Se para justo al cruzar yc (evento 'critico'): mas atras que eso la
    % rama subcritica ya no tiene sentido fisico en un tramo steep.
    par1sub = [Q b S01 n1 yc m];
    odeo_ev = odeset('RelTol',1e-10,'AbsTol',1e-10,'Events',@(x,y) critico(x,y,par1sub));
    [xsub1, ysub1_raw] = ode45(@(x,y) rect(x,y,par1sub), fliplr(xg1), y_tr2_en_L1, odeo_ev);
    % conjugado de la rama S2 interpolado en los mismos x que devolvio la integracion
    conjS2_vec = zeros(size(yS2));     % trap_geom no esta vectorizado -> loop punto a punto
    for k = 1:numel(yS2)
        [~, conjS2_vec(k)] = Mom_trap(yS2(k), b, m, Q);
    end
    conjS2_en_xsub1 = interp1(xg1, conjS2_vec, xsub1, 'linear', 'extrap');
    dif = ysub1_raw(:) - conjS2_en_xsub1(:);
    idx = find(dif(1:end-1).*dif(2:end) < 0, 1, 'last');
    x_resalto  = interp1(dif(idx:idx+1), xsub1(idx:idx+1), 0);
    y1_resalto = interp1(xg1, yS2, x_resalto);
    y2_resalto = interp1(xsub1, ysub1_raw, x_resalto);
    fprintf('  RESALTO en x = %.2f m (medido desde el Lago A, dentro del tramo 1 de %.0f m): y1=%.3f m -> y2=%.3f m\n', ...
            x_resalto, L1, y1_resalto, y2_resalto);
else
    fprintf('  => y_tramo2 <= conjugado(S2): el resalto esta DENTRO DEL TRAMO 2 (o no hay resalto).\n');
end

fprintf('\nRESUMEN PARTE 1: Q = %.2f m3/s | Tramo1 tipo S (yn1=%.2f m) | Tramo2 tipo M (yn2=%.2f m) | resalto en tramo 1, x=%.2f m desde Lago A (%.2f m -> %.2f m)\n', ...
        Q, yn1, yn2, x_resalto, y1_resalto, y2_resalto);

% --- Grafico de la superficie libre ---
figure('visible','off');
hold on;
plot(xg1, yS2, 'b-', 'LineWidth', 1.5);
xg2f = fliplr(xg2); yTr2f = flipud(yTr2_rev(:));
plot(xg2f, yTr2f, 'r-', 'LineWidth', 1.5);
plot([0 L1+L2], [0 0], 'k--');
plot(x_resalto, y1_resalto, 'ko', 'MarkerFaceColor','k');
plot(x_resalto, y2_resalto, 'ko', 'MarkerFaceColor','k');
xlabel('x (m)'); ylabel('y (m)'); title('Perfil FGV — Ejercicio 1, Parte 1 (hLB=2.6 m)');
legend('Tramo 1 (S2, supercritico)','Tramo 2 (subcritico)','fondo','Location','best');
grid on;
print('-dpng', 'perfil_parte1.png');

%% ============ PARTE 2: rango de hLB para resalto en TRAMO 2 ============
fprintf('\n=================== PARTE 2: rango de hLB con resalto en tramo 2 ===================\n');
% Q, yc, yn1, yn2 no dependen de hLB (el control de entrada es siempre
% critico, tramo 1 steep, independiente de lo que pase aguas abajo,
% MIENTRAS el lago B no ahogue la seccion critica de entrada).
%
% El resalto esta en el tramo 2 si y solo si el valor de la curva
% subcritica de tramo2 en la union x=L1 es MENOR que el conjugado de la
% curva S2 en x=L1 (si fuera mayor, el resalto se corre al tramo 1, Parte 1).
% El caso limite es cuando ambos coinciden exactamente en x=L1: y_tramo2(L1) = conj_S2(L1).
%
% Se integra la curva subcritica de tramo2 hacia atras desde x=L1 (con
% el valor limite conj_S2_L1) HACIA ADELANTE hasta el lago B (x=L1+L2)
% para hallar el hLB umbral.
par2 = [Q b S02 n2 yc m];
xg2f = linspace(L1, L1+L2, 3001);
[~, y_umbral_fwd] = ode45(@(x,y) rect(x,y,par2), xg2f, conj_S2_L1*(1+1e-6), odeo);
hLB_umbral = y_umbral_fwd(end);
fprintf('Integrando hacia adelante desde x=%.0f (y=conjugado(S2)=%.3f m) hasta el lago B: hLB_umbral = %.3f m\n', ...
        L1, conj_S2_L1, hLB_umbral);
fprintf('  (para hLB por debajo de este umbral el resalto esta en el tramo 2; por encima, en el tramo 1)\n');

% Chequeo de la condicion de caudal libre: si hLB<=yc, el lago B deja de
% controlar la salida (pasa a caida libre, y(x=L1+L2)=yc); se verifica
% que AUN en ese caso el resalto sigue quedando dentro del tramo 2 (no
% se corre al tramo 1), integrando la curva M2 desde el control critico
% de salida hacia atras hasta la union x=L1 y comparando con el mismo
% conjugado de S2 de antes.
par2cl = [Q b S02 n2 yc m];
[~, yM2_cl] = ode45(@(x,y) rect(x,y,par2cl), xg2, yc*(1+1e-6), odeo);
y_tr2_en_L1_caidalibre = yM2_cl(end);
fprintf('Chequeo caida libre (hLB<=yc): y(x=%.0f) partiendo de yc en la salida = %.3f m  vs  conjugado(S2)=%.3f m\n', ...
        L1, y_tr2_en_L1_caidalibre, conj_S2_L1);
if y_tr2_en_L1_caidalibre < conj_S2_L1
    fprintf('  => sigue siendo MENOR: el resalto permanece en el TRAMO 2 para cualquier hLB<=yc (no hay cota inferior).\n');
end

fprintf('\nRESUMEN PARTE 2: hay resalto en el TRAMO 2 para  0 <= hLB < %.2f m\n', hLB_umbral);
fprintf('  (para yc=%.2f m < hLB < %.2f m el lago B controla la salida; para hLB<=yc la salida es caida libre,\n', yc, hLB_umbral);
fprintf('   pero el resalto sigue en el tramo 2 en ambos casos — solo por encima de %.2f m se corre al tramo 1)\n', hLB_umbral);
