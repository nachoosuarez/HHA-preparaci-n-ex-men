% FGV_rectangular_optimizado.m — script CONSOLIDADO para resolver de
% punta a punta un ejercicio de Flujo Gradualmente Variado en canal
% RECTANGULAR: tirante crítico yc y normal yn, clasificación M/S, y
% (opcional) compuerta de fondo ideal con chequeo libre/ahogada, tirante
% aguas arriba, y si es libre, ubicación del resalto hidráulico aguas
% abajo (integrando la curva M3 con ode23). Antes tenías que combinar
% fgv_rect.m + Mom_rect.m + Eesp_rect.m + descarga_ahogada_rect.m a mano;
% acá está todo en un único punto de entrada.
%
% CÓMO USARLO: editar SOLO el bloque "EDITAR ACÁ" de abajo con los datos
% del enunciado y correr el script entero. Si el ejercicio no tiene
% compuerta, dejar USAR_COMPUERTA=false (alcanza para clasificar el canal
% y saber a qué tirante tiende aguas arriba/abajo).
%
% REQUIERE, en esta misma carpeta: rect_geom.m, froude_rect.m,
% manning_rect.m, Mom_rect.m, Eesp_rect.m, rect.m (copias de
% RESUMEN EXAMEN/Codigos/FGV_rectangular/, sin modificar).
%
% Verificado contra resueltos/2024 marzo/RESOLUCION.md Ejercicio 1 (misma
% salida: yc=1.008, yn=1.836, canal M, a=0.35 libre con resalto a
% x=19.7 m, a=0.6 ahogada con y1=2.367/y2=1.037).

clc; clear; close all;
warning('off','all');

%% ==== EDITAR ACÁ ====
Q  = 19;      % caudal (m3/s)
b  = 6;       % ancho de fondo (m)
S0 = 0.001;   % pendiente de fondo del canal
n  = 0.02;    % coeficiente de Manning

% Compuerta de fondo ideal (dejar USAR_COMPUERTA=false si no aplica)
USAR_COMPUERTA = true;
a_compuerta = 0.35;    % apertura de la compuerta (m) — probar cada apertura del enunciado
y_aguasabajo_ref = []; % tirante de referencia aguas abajo de la compuerta para el
                        % chequeo libre/ahogada (p.ej. yn si el control aguas abajo
                        % está lejos, o el nivel de un lago/canal si lo da el
                        % enunciado). Dejar [] para usar yn automáticamente.
%% =====================

g = 9.8;

% ---- Tirante crítico y normal, clasificación ----
yc0 = (Q^2/(g*b^2))^(1/3);
yc = fsolve(@(y) froude_rect(y,[Q b]), yc0, optimset('Display','off'));

yn0 = (Q*n/(b*S0^0.5))^(3/5);
yn = fsolve(@(y) manning_rect(y,[Q b S0 n]), yn0, optimset('Display','off'));

fprintf("yc = %.3f m ; yn = %.3f m\n", yc, yn);
if S0<=0
    fprintf("S0<=0 => yn=Inf (canal horizontal o de contrapendiente)\n");
elseif yn > yc
    fprintf("yn > yc => CANAL TIPO M (pendiente suave)\n");
else
    fprintf("yn < yc => CANAL TIPO S (pendiente fuerte)\n");
end

if ~USAR_COMPUERTA
    return
end

if isempty(y_aguasabajo_ref)
    y_aguasabajo_ref = yn;
end

fprintf("\n--- Compuerta de fondo ideal, a = %.3f m ---\n", a_compuerta);
[~, aconj] = Mom_rect(a_compuerta,b,Q);
fprintf("a* (conjugado de a) = %.3f m ; tirante de referencia aguas abajo = %.3f m\n", ...
        aconj, y_aguasabajo_ref);

if aconj > y_aguasabajo_ref
    fprintf("a* > y_aguasabajo => DESCARGA LIBRE\n");
    [~, y1] = Eesp_rect(a_compuerta,b,Q);
    fprintf("Tirante aguas arriba de la compuerta (alterno de a) = %.3f m\n", y1);

    % Curva M3 aguas abajo (supercrítica) hasta encontrar el resalto.
    % OJO: la curva se acerca a yc en forma asintótica (dydx->Inf) — no
    % ampliar demasiado xspan o ode23 se vuelve muy lento cerca de yc.
    par_fgv = [Q b S0 n yc];
    xspan = 0:0.5:100;
    [xM3,yM3] = ode23(@(x,y) rect(x,y,par_fgv), xspan, a_compuerta+1e-6);
    yconjM3 = zeros(size(yM3));
    for i=1:length(yM3)
        [~,yconjM3(i)] = Mom_rect(yM3(i),b,Q);
    end
    idx = find(yconjM3 < y_aguasabajo_ref, 1, 'first');
    if isempty(idx) || idx==1
        fprintf("(resalto fuera del rango integrado — ampliar xspan)\n");
    else
        x_res = interp1(yconjM3(idx-1:idx), xM3(idx-1:idx), y_aguasabajo_ref);
        y_res = interp1(xM3(idx-1:idx), yM3(idx-1:idx), x_res);
        fprintf("RESALTO a x = %.1f m aguas abajo de la compuerta: y=%.3f -> y=%.3f m\n", ...
                x_res, y_res, y_aguasabajo_ref);
    end
else
    fprintf("a* < y_aguasabajo => DESCARGA AHOGADA (flujo dividido)\n");
    [M3,~] = Mom_rect(y_aguasabajo_ref,b,Q);
    Am = b*a_compuerta;
    y2 = sqrt(2/b*(M3 - Q^2/(g*Am)));
    E2 = y2 + Q^2/(2*g*Am^2);
    y1 = fzero(@(y) y + Q^2/(2*g*(b*y)^2) - E2, max(E2,1));
    fprintf("y2 (aguas abajo, flujo dividido) = %.3f m\n", y2);
    fprintf("y1 (aguas arriba de la compuerta) = %.3f m\n", y1);
end
