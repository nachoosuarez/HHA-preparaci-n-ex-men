% Ejercicio1_FGV_rectangular.m — Examen HHA 1 de marzo 2024, Ejercicio 1
% Canal rectangular infinito (b=6m, n=0.02, S0=0.001) que finaliza en una
% caída libre, Q=19 m3/s. Compuerta de fondo ideal L=3000m antes de la
% caída libre, con dos aperturas a evaluar: a=0.35m (parte 2) y a=0.6m
% (parte 3). Usa el toolkit canónico RESUMEN EXAMEN/Codigos/FGV_rectangular
% (rect_geom, Eesp_rect, Mom_rect, manning_rect, froude_rect, rect, critico)
% copiado a este mismo directorio. g=9.8 (consistente con Eesp_rect/Mom_rect).
clc; clear; close all;
warning('off','all');
g = 9.8;

Q = 19;   % m3/s
b = 6;    % m
S0 = 0.001;
n = 0.02;

%% Tirante crítico y normal (clasificación del canal)
yc = (Q^2/(g*b^2))^(1/3);
par = [Q b];
yc = fsolve(@(y) froude_rect(y,par), yc, optimset('Display','off'));

yn0 = (Q*n/(b*S0^0.5))^(3/5);
par = [Q b S0 n];
yn = fsolve(@(y) manning_rect(y,par), yn0, optimset('Display','off'));

fprintf("yc = %.3f m ; yn = %.3f m\n", yc, yn);
if yn > yc
    fprintf("yn > yc => CANAL TIPO M (pendiente suave)\n");
else
    fprintf("yn < yc => CANAL TIPO S (pendiente fuerte)\n");
end

%% Parte 1: perfil sin compuerta (caída libre aguas abajo, control critico)
% Canal tipo M => control aguas abajo (caida libre): curva M2, y crece
% desde yc en el borde hasta yn (asintoticamente) aguas arriba.
fprintf("\n--- Parte 1: canal SIN compuerta, con caida libre aguas abajo ---\n");
fprintf("En la caida libre: y = yc = %.3f m (control critico)\n", yc);
fprintf("Aguas arriba (canal infinito): y -> yn = %.3f m (curva M2)\n", yn);

%% Parte 2: compuerta con a=0.35 m, a L=3000 m aguas arriba de la caida libre
fprintf("\n--- Parte 2: compuerta a=0.35 m, L=3000 m antes de la caida libre ---\n");
a2 = 0.35;
[M_a2, aconj2] = Mom_rect(a2,b,Q);
fprintf("a* (conjugado de a=%.2f) = %.3f m\n", a2, aconj2);
% Tirante "aguas abajo" en esa seccion (sin compuerta): a 3000 m del borde
% la curva M2 ya practicamente recupero yn (canal muy largo, S0 chica).
fprintf("Tirante de referencia aguas abajo (~yn, la M2 ya convergio a 3000 m) = %.3f m\n", yn);
if aconj2 > yn
    fprintf("a* > yn => DESCARGA LIBRE\n");
    [E_a2, y1_2] = Eesp_rect(a2,b,Q);
    fprintf("Tirante aguas arriba de la compuerta (alterno de a): y1 = %.3f m\n", y1_2);

    % Integrar la curva M3 aguas abajo de la compuerta (supercritica,
    % creciente) y buscar donde su conjugado alcanza yn (resalto).
    par_fgv = [Q b S0 n yc];
    xspan = 0:0.5:60; % la curva M3 se acerca a yc muy rapido (asintota) => limitar el rango
    [xM3,yM3] = ode23(@(x,y) rect(x,y,par_fgv), xspan, a2+1e-6);
    yconjM3 = zeros(size(yM3));
    for i=1:length(yM3)
        [~,yconjM3(i)] = Mom_rect(yM3(i),b,Q);
    end
    % El conjugado de la rama M3 arranca en a* (> yn, ya que la descarga es
    % libre) y DECRECE a medida que y crece hacia yc: el resalto ocurre
    % donde ese conjugado decreciente cruza yn (tirante ~constante de la
    % rama subcritica, M2 ya convergida a 3000 m de la caida libre).
    idx_res = find(yconjM3 < yn, 1, 'first');
    if isempty(idx_res) || idx_res==1
        fprintf("(no se encontro cruce con yn en el rango integrado)\n");
    else
        x_res = interp1(yconjM3(idx_res-1:idx_res), xM3(idx_res-1:idx_res), yn);
        y1_res = interp1(xM3(idx_res-1:idx_res), yM3(idx_res-1:idx_res), x_res);
        fprintf("RESALTO a x = %.1f m aguas abajo de la compuerta: y=%.3f m -> y=%.3f m (~yn)\n", ...
                 x_res, y1_res, yn);
    end
else
    fprintf("a* < yn => DESCARGA AHOGADA\n");
end

%% Parte 3: compuerta con a=0.6 m
fprintf("\n--- Parte 3: compuerta a=0.6 m ---\n");
a3 = 0.6;
[M_yn, yn_conj] = Mom_rect(yn,b,Q);
fprintf("Conjugado de yn (%.3f m) = %.3f m ; a = %.2f m\n", yn, yn_conj, a3);
if a3 > yn_conj
    fprintf("a > conjugado(yn) => DESCARGA AHOGADA (flujo dividido aguas abajo de la compuerta)\n");

    % Momentum entre (2) [flujo dividido, area completa b*y2 para la
    % hidrostatica, area contraida b*a para el termino de velocidad] y
    % (3) [aguas abajo del resalto sumergido, y3=yn, seccion completa]:
    %   b*y2^2/2 + Q^2/(g*b*a) = M(yn)      (yG3*A3 + Q^2/(g A3) = M(yn))
    rhs_mom = M_yn;
    y2_eq = @(y2) b*y2.^2/2 + Q^2/(g*b*a3) - rhs_mom;
    y2 = fzero(y2_eq, yn/2);
    fprintf("Tirante y2 (inmediatamente aguas abajo de la compuerta, flujo dividido) = %.3f m\n", y2);

    % Energia entre (1) [aguas arriba, seccion completa b*y1] y (2)
    % [presion con y2, velocidad con area contraida b*a]:
    %   y1 + Q^2/(2g (b y1)^2) = y2 + Q^2/(2g (b a)^2)
    E2 = y2 + Q^2/(2*g*(b*a3)^2);
    fprintf("Energia en la seccion (2): E2 = %.3f m\n", E2);
    y1_eq = @(y1) y1 + Q^2/(2*g*(b*y1)^2) - E2;
    y1_3 = fzero(y1_eq, 3);
    fprintf("Tirante aguas arriba de la compuerta: y1 = %.3f m\n", y1_3);
else
    fprintf("a < conjugado(yn) => DESCARGA LIBRE\n");
end
