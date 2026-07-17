% Ejercicio1_FGV_dostramos.m — Examen HHA 11/dic/2023, Ejercicio 1.
%
% Canal RECTANGULAR (b=1.1 m, n=0.012) que conecta el Lago A (hLA=2.1 m
% sobre el fondo) con el Lago B (hLB=0.4 m sobre el fondo), en DOS tramos
% de 100 m cada uno con distinta pendiente de fondo S01, S02 (mismo b, n
% en todo el canal). Se pide, para dos combinaciones de (S01,S02): el
% caudal de descarga, clasificar cada tramo en M o S, y dibujar la
% superficie libre con los tirantes relevantes y resaltos si los hay.
%
% Requiere, en esta misma carpeta (copias del toolkit canónico
% RESUMEN EXAMEN/Codigos/FGV_rectangular): rect_geom.m, froude_rect.m,
% manning_rect.m, Mom_rect.m, rect.m.
%
% MÉTODO (ver RESUMEN_TEORICO.md §A4):
% - Si el tramo 1 (el que sale del lago) es TIPO S (steep): el lago
%   descarga el caudal máximo compatible con su energía => control
%   CRÍTICO en la entrada (x=0): y(0)=yc, con E(yc)=(3/2)yc=hLA. Esto da
%   Q en forma cerrada, SIN iterar, y es válido siempre que el tramo 1
%   sea realmente steep con ese Q (se verifica al final, autoconsistente).
% - Si el tramo 1 es TIPO M (mild): la entrada NO es control crítico (el
%   lago no puede forzar más caudal que el que el tramo aguas abajo deja
%   pasar); en su lugar, el control crítico aparece en el CAMBIO DE
%   PENDIENTE (mild->steep), en x=L1=100 m: y(100)=yc. Q se halla
%   iterando (shooting): se prueba Q, se calcula yc(Q), se integra la
%   curva M2 del tramo 1 hacia ATRÁS desde (x=100,y=yc) hasta x=0, y se
%   ajusta Q hasta que la energía en x=0 iguale hLA.
% - El lago de salida (hLB) sólo controla la salida si hLB supera el
%   tirante que trae el perfil ahí Y el tramo de salida puede transmitir
%   esa info hacia aguas arriba (tramo M, subcrítico). Si hLB < yc, la
%   salida se comporta como una caída libre (control crítico) sin
%   importar el valor exacto de hLB, porque el flujo pasa por crítico y
%   se acelera solo en el borde mismo.
% - Si una rama supercrítica (control aguas arriba) debe empalmar con una
%   subcrítica impuesta aguas abajo, hay un RESALTO: se ubica comparando,
%   sobre una malla común de x, el CONJUGADO de la rama supercrítica
%   (Mom_rect) contra el valor real de la rama subcrítica extendida con
%   la pendiente del tramo donde se busca el resalto (RESUMEN_TEORICO.md
%   §A3).

clc; clear; close all;
warning('off','all');

%% ==== EDITAR ACÁ (datos del enunciado) ====
b   = 1.1;    % ancho de fondo (m)
n   = 0.012;  % Manning
g   = 9.8;
hLA = 2.1;    % nivel Lago A sobre el fondo del canal (m)
hLB = 0.4;    % nivel Lago B sobre el fondo del canal (m)
L1  = 100;    % longitud tramo 1 (m)
L2  = 100;    % longitud tramo 2 (m)
%% ============================================

fprintf('=================== PARTE 1: S01=0.01, S02=0.002 ===================\n');
S01 = 0.01; S02 = 0.002;

% --- Control de entrada: verificar si tramo1 es steep con control critico ---
yc = (2/3)*hLA;                 % E=1.5*yc=hLA (cerrado, ver encabezado)
Q  = b*sqrt(g*yc^3);            % de Fr(yc)=1
fprintf('Control critico en la entrada (lago A -> tramo 1):\n');
fprintf('  yc = (2/3)*hLA = %.3f m ; Q = b*sqrt(g*yc^3) = %.3f m3/s\n', yc, Q);

yn1 = fsolve(@(y) manning_rect(y,[Q b S01 n]), (Q*n/(b*S01^0.5))^(3/5), optimset('Display','off'));
yn2 = fsolve(@(y) manning_rect(y,[Q b S02 n]), (Q*n/(b*S02^0.5))^(3/5), optimset('Display','off'));
fprintf('  yn1 (tramo1, S01=%.3f) = %.3f m ; yn2 (tramo2, S02=%.3f) = %.3f m\n', S01, yn1, S02, yn2);

if yn1 < yc
    fprintf('  yn1 < yc => TRAMO 1 TIPO S (steep) -> control critico en la entrada es CONSISTENTE\n');
else
    fprintf('  *** yn1 > yc: tramo 1 NO es steep; el control critico en la entrada no es valido (ver parte 2) ***\n');
end
if yn2 > yc, tipo2 = 'M'; cmp2 = '>'; else, tipo2 = 'S'; cmp2 = '<'; end
fprintf('  yn2 %s yc => TRAMO 2 TIPO %s\n', cmp2, tipo2);

% --- Curva S2 en tramo 1 (x:0->100), desde yc hacia yn1 ---
par1 = [Q b S01 n];
xg = linspace(0, L1, 4001);
[~, yS2] = ode23(@(x,y) rect(x,y,par1), xg, yc*(1-1e-4));
fprintf('  Curva S2 tramo1: y(x=0)=%.3f m -> y(x=%d)=%.3f m (asintotico a yn1=%.3f m)\n', yS2(1), L1, yS2(end), yn1);

% --- Control de salida (Lago B) ---
fprintf('Control de salida (tramo 2 -> lago B):\n');
if hLB < yc
    fprintf('  hLB=%.2f m < yc=%.3f m => la salida se comporta como CAIDA LIBRE (control critico, y(x=%d)=yc)\n', hLB, yc, L1+L2);
    y_salida_control = yc;
else
    fprintf('  hLB=%.2f m > yc=%.3f m => el lago B controla con y=hLB en x=%d\n', hLB, yc, L1+L2);
    y_salida_control = hLB;
end

% --- Curva M2 en tramo 2 (x:200->100 hacia atras), desde el control de salida ---
par2 = [Q b S02 n];
xg2 = linspace(L1+L2, L1, 4001);   % de 200 a 100 (integracion hacia atras)
[~, yM2_rev] = ode23(@(x,y) rect(x,y,par2), xg2, y_salida_control*(1+1e-4));
fprintf('  Curva M2 tramo2: y(x=%d)=%.3f m (control) -> y(x=%d)=%.3f m\n', L1+L2, yM2_rev(1), L1, yM2_rev(end));

% --- Empalme en x=100: comparar S2 (supercritico) con M2 (subcritico) ---
y_S2_100 = yS2(end);
y_M2_100 = yM2_rev(end);
[~, conj_S2_100] = Mom_rect(y_S2_100, b, Q);
fprintf('En x=%d m: y_S2=%.3f m (supercritico) ; y_M2=%.3f m (subcritico)\n', L1, y_S2_100, y_M2_100);
if conj_S2_100 < y_M2_100, cmpc = '<'; else, cmpc = '>='; end
fprintf('  Conjugado de y_S2(100) = %.3f m  %s  y_M2(100) = %.3f m\n', conj_S2_100, cmpc, y_M2_100);

x_resalto = NaN; y1_resalto = NaN; y2_resalto = NaN;
if conj_S2_100 < y_M2_100
    fprintf('  => El conjugado de la rama supercritica en x=100 NO alcanza el nivel de la rama\n');
    fprintf('     subcritica M2: el resalto esta UPSTREAM, dentro del TRAMO 1.\n');
    % Extender la rama subcritica hacia atras dentro del tramo 1 (misma
    % pendiente S01), partiendo de (x=100, y=y_M2_100):
    [~, yS1ext_rev] = ode23(@(x,y) rect(x,y,par1), fliplr(xg), y_M2_100);
    yS1ext = flipud(yS1ext_rev(:));    % alineado con xg (0->100)
    yS2col = yS2(:);
    [~, conjS2_vec] = Mom_rect(yS2col, b, Q);   % conjugado de la rama supercritica en toda la malla
    dif = yS1ext - conjS2_vec;
    idx = find(dif(1:end-1).*dif(2:end) < 0, 1, 'last');
    if isempty(idx)
        fprintf('  (no se encontro cruce dentro de [0,%d] m)\n', L1);
    else
        x_resalto  = interp1(dif(idx:idx+1), xg(idx:idx+1), 0);
        y1_resalto = interp1(xg(idx:idx+1), yS2col(idx:idx+1), x_resalto);
        y2_resalto = interp1(xg(idx:idx+1), yS1ext(idx:idx+1), x_resalto);
        fprintf('  RESALTO en x = %.1f m (dentro del tramo 1): y = %.3f m -> y = %.3f m\n', x_resalto, y1_resalto, y2_resalto);
    end
else
    fprintf('  => El resalto ocurre dentro del tramo 2 (o justo en el cambio de pendiente).\n');
end

fprintf('\nRESUMEN PARTE 1: Q=%.2f m3/s | Tramo1 S (yn1=%.2f m) | Tramo2 M (yn2=%.2f m) | resalto en tramo 1, x=%.1f m (%.2f m -> %.2f m)\n', ...
        Q, yn1, yn2, x_resalto, y1_resalto, y2_resalto);


fprintf('\n=================== PARTE 2: S01=0.002, S02=0.01 ===================\n');
S01b = 0.002; S02b = 0.01;

% --- Chequeo: el control critico "ingenuo" en la entrada, es consistente? ---
yc_naive = (2/3)*hLA; Q_naive = b*sqrt(g*yc_naive^3);
yn1_naive = fsolve(@(y) manning_rect(y,[Q_naive b S01b n]), 1, optimset('Display','off'));
if yn1_naive > yc_naive, cmpn='>'; else, cmpn='<'; end
fprintf('Chequeo: con control critico "ingenuo" en la entrada, yn1=%.3f m %s yc=%.3f m\n', yn1_naive, cmpn, yc_naive);
if yn1_naive > yc_naive
    fprintf('  => tramo 1 resultaria MILD: el control critico en la entrada NO es valido; hay que\n');
    fprintf('     iterar Q con control critico en el cambio de pendiente (x=%d m).\n', L1);
else
    fprintf('  => tramo 1 resultaria STEEP: el control critico en la entrada SI seria valido.\n');
end

% --- Shooting: hallar Q tal que, integrando la curva M2 de tramo1 hacia
%     atras desde (x=100,y=yc(Q)) hasta x=0, la energia en x=0 iguale hLA ---
Q = fzero(@(QQ) residuo_entrada(QQ,b,n,S01b,hLA,L1), [0.5 20]);
yc = (Q^2/(g*b^2))^(1/3);
fprintf('Iterando Q (fzero) para que E(x=0)=hLA con control critico en x=%d: Q = %.3f m3/s ; yc = %.3f m\n', L1, Q, yc);

yn1 = fsolve(@(y) manning_rect(y,[Q b S01b n]), (Q*n/(b*S01b^0.5))^(3/5), optimset('Display','off'));
yn2 = fsolve(@(y) manning_rect(y,[Q b S02b n]), (Q*n/(b*S02b^0.5))^(3/5), optimset('Display','off'));
fprintf('  yn1 (tramo1, S01=%.3f) = %.3f m ; yn2 (tramo2, S02=%.3f) = %.3f m\n', S01b, yn1, S02b, yn2);
if yn1>yc, t1='M'; c1='>'; else, t1='S'; c1='<'; end
if yn2>yc, t2='M'; c2='>'; else, t2='S'; c2='<'; end
fprintf('  yn1 %s yc => TRAMO 1 TIPO %s  |  yn2 %s yc => TRAMO 2 TIPO %s\n', c1, t1, c2, t2);

% --- Entrada (x=0): tirante que satisface la energia del lago A ---
y0 = fzero(@(y) (y + Q^2/(2*g*(b*y)^2)) - hLA, [yc yn1]);
fprintf('Entrada (x=0): y0 + Q^2/(2g(b y0)^2) = hLA  =>  y0 = %.3f m\n', y0);

% --- Perfil tramo 1: curva M2 desde x=0 (y=y0) hasta x=100 (debe dar ~yc) ---
par1b = [Q b S01b n];
xg = linspace(0, L1, 4001);
[~, yM2f] = ode23(@(x,y) rect(x,y,par1b), xg, y0);
fprintf('  Verificacion: integrando desde y0 en x=0 hasta x=%d con S01, y(%d) = %.3f m (debe ser ~yc=%.3f m)\n', L1, L1, yM2f(end), yc);

% --- Perfil tramo 2: curva S2 desde x=100 (y=yc) hasta x=200 ---
par2b = [Q b S02b n];
xg2 = linspace(L1, L1+L2, 4001);
[~, yS2b] = ode23(@(x,y) rect(x,y,par2b), xg2, yc*(1-1e-4));
fprintf('Tramo 2 (S02=%.3f, tipo S): y(x=%d)=%.3f m -> y(x=%d)=%.3f m (asintotico a yn2=%.3f m)\n', ...
        S02b, L1, yS2b(1), L1+L2, yS2b(end), yn2);
if hLB < yn2
    fprintf('hLB=%.2f m < yn2=%.3f m => info de aguas abajo NO viaja hacia arriba en flujo supercritico:\n', hLB, yn2);
    fprintf('  la curva S2 domina TODO el tramo 2 (sin resalto); el ajuste final a hLB ocurre en el borde mismo.\n');
end
fprintf('\nRESUMEN PARTE 2: Q=%.2f m3/s | Tramo1 M (yn1=%.2f m, y0=%.2f m en el lago) | Tramo2 S (yn2=%.2f m) | SIN resalto\n', ...
        Q, yn1, y0, yn2);
