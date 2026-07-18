% ej1.m -- Examen HHA 24 de febrero de 2023, Ejercicio 1
% Canal rectangular b=5m, S0=0.001, n=0.017. Desemboca en un lago con
% nivel hL=0.8m sobre el fondo del canal. A 60m antes del lago hay una
% compuerta de fondo ideal.
% Parte 1: a=0.50m descarga libre (dato), v en la compuerta = 4 m/s.
% Parte 2: para el mismo Q, a=0.65m -- libre o ahogada?
% Parte 3: fuerza sobre la compuerta en las condiciones de la parte 2.
%
% Requiere en esta misma carpeta: rect_geom.m, froude_rect.m,
% manning_rect.m, Mom_rect.m, Eesp_rect.m, rect.m (canonicos de
% RESUMEN EXAMEN/Codigos/FGV_rectangular/, sin modificar).
clc; clear; close all;
warning('off','all');
g = 9.8;

b  = 5;
S0 = 0.001;
n  = 0.017;
hL = 0.8;   % nivel del lago sobre el fondo del canal (m)
Lgc = 60;   % distancia compuerta -> lago (m)

%% ---- Parte 1: a=0.50 m, descarga libre, v=4 m/s en la compuerta ----
a1 = 0.50;
v1 = 4;
Q = v1*(b*a1);
fprintf("=== PARTE 1 ===\n");
fprintf("Q = v*(b*a) = %.4f m3/s\n", Q);

% Tirante critico y normal, clasificacion
yc0 = (Q^2/(g*b^2))^(1/3);
yc = fsolve(@(y) froude_rect(y,[Q b]), yc0, optimset('Display','off'));
yn0 = (Q*n/(b*S0^0.5))^(3/5);
yn = fsolve(@(y) manning_rect(y,[Q b S0 n]), yn0, optimset('Display','off'));
fprintf("yc = %.4f m ; yn = %.4f m\n", yc, yn);
if yn > yc
    fprintf("yn > yc => CANAL TIPO M\n");
else
    fprintf("yn < yc => CANAL TIPO S\n");
end

% Aguas arriba de la compuerta: alterno de a1 (energia constante, sin perdidas)
[Ea1, y1_up] = Eesp_rect(a1,b,Q);
fprintf("y aguas arriba de la compuerta (alterno de a=%.2f) = %.4f m", a1, y1_up);
if y1_up < yn
  fprintf(" (< yn => curva M2, aguas arriba de la compuerta)\n");
else
  fprintf(" (> yn => curva M1)\n");
end

% Aguas abajo: y=a1 < yc => supercritico => curva M3, creciente hacia yc
fprintf("y=a=%.4f m < yc => aguas abajo de la compuerta arranca la curva M3\n", a1);

% Control aguas abajo real: el lago, a Lgc=60m, con hL=0.8 (> yc => subcritico)
fprintf("hL=%.2f m > yc=%.4f m => en el lago el flujo es subcritico (curva M2 tambien alli)\n", hL, yc);

% Integrar M2 hacia aguas arriba desde el lago (x=Lgc, y=hL) hasta la compuerta (x=0)
par_fgv = [Q b S0 n yc];
xspanM2 = linspace(Lgc, 0, 400);
[xM2,yM2] = ode23(@(x,y) rect(x,y,par_fgv), xspanM2, hL);

% Integrar M3 hacia aguas abajo desde la compuerta (x=0, y=a1) hasta el lago
xspanM3 = linspace(0, Lgc, 400);
[xM3,yM3] = ode23(@(x,y) rect(x,y,par_fgv), xspanM3, a1+1e-6);
yconjM3 = zeros(size(yM3));
for i=1:length(yM3)
    [~,yconjM3(i)] = Mom_rect(yM3(i),b,Q);
end

% Interpolar ambas curvas sobre una malla comun de x y buscar la
% interseccion entre el conjugado de M3 y el valor de M2 (resalto)
xg = linspace(0,Lgc,2000);
yM2g = interp1(xM2, yM2, xg);
yconjM3g = interp1(xM3, yconjM3, xg);
diffc = yconjM3g - yM2g;
idxr = find(diffc(1:end-1).*diffc(2:end) < 0, 1, 'first');
if isempty(idxr)
    fprintf("(no se hallo interseccion M3-conjugado / M2 en el rango integrado)\n");
else
    x_res = interp1(diffc(idxr:idxr+1), xg(idxr:idxr+1), 0);
    y_M3_res = interp1(xM3, yM3, x_res);
    y_M2_res = interp1(xM2, yM2, x_res);
    fprintf("RESALTO a x = %.1f m aguas abajo de la compuerta: y=%.4f m -> y=%.4f m\n", ...
            x_res, y_M3_res, y_M2_res);
end
fprintf("y(M2) justo en la compuerta (x=0, referencia para Parte 2) = %.4f m\n", yM2(end));
yM2_gate = yM2(end);

%% ---- Parte 2: a=0.65 m, mismo Q. Libre o ahogada? ----
fprintf("\n=== PARTE 2 ===\n");
a2 = 0.65;
[~, aconj2] = Mom_rect(a2,b,Q);
fprintf("a=%.2f m ; a* (conjugado de a) = %.4f m\n", a2, aconj2);
fprintf("Tirante de referencia aguas arriba/abajo en la compuerta (M2 desde el lago) = %.4f m\n", yM2_gate);
if aconj2 > yM2_gate
    fprintf("a* > y(M2 en la compuerta) => DESCARGA LIBRE\n");
    ahogada = false;
else
    fprintf("a* < y(M2 en la compuerta) => DESCARGA AHOGADA (flujo dividido)\n");
    ahogada = true;
end

if ahogada
    % Flujo dividido en (2): tirante y3=yM2_gate aguas abajo del resalto sumergido
    y3 = yM2_gate;
    [M3_,~] = Mom_rect(y3,b,Q);
    % Momentum entre seccion contraida bajo la compuerta (area b*a2, y2 hidrostatico
    % con area completa b*y2) y la seccion (3): yG2*A(y2) + Q^2/(g*A(a2)) = M(y3)
    y2_eq = @(y2) (y2/2).*(b*y2) + Q^2/(g*b*a2) - M3_;
    y2 = fzero(y2_eq, y3/2);
    fprintf("y2 (inmediatamente aguas abajo de la compuerta, flujo dividido) = %.4f m\n", y2);

    % Energia entre (1) aguas arriba [seccion completa b*y1] y (2) [presion con
    % y2, velocidad con area contraida b*a2]: y1+Q^2/(2g(b y1)^2) = E2
    E2 = y2 + Q^2/(2*g*(b*a2)^2);
    fprintf("Energia especifica en (2): E2 = %.4f m\n", E2);
    y1 = fzero(@(y) y + Q^2/(2*g*(b*y)^2) - E2, max(E2,1));
    fprintf("y1 (aguas arriba de la compuerta) = %.4f m\n", y1);

    %% ---- Parte 3: fuerza sobre la compuerta ----
    % OJO: la fuerza sobre la COMPUERTA actua entre la seccion (1) aguas
    % arriba (seccion completa, area b*y1) y la seccion (2) en la vena
    % contraida bajo la compuerta. En (2) el flujo esta "dividido": la
    % presion es hidrostatica hasta la superficie libre y2 (area completa
    % b*y2 para el termino de presion) pero la velocidad real corresponde
    % al area contraida b*a2 (termino de cantidad de movimiento). Por eso
    % NO se puede usar Mom_rect(y2,...) (que asume area completa b*y2
    % tambien para el termino de velocidad): hay que usar el momento
    % "hibrido" M2_hib = yG(y2)*A(y2) + Q^2/(g*A(a2)), que por construccion
    % (ver mas arriba, y2_eq) coincide con M3_ = Mom_rect(y3=yM2_gate).
    fprintf("\n=== PARTE 3 ===\n");
    gamma = 1000*g; % N/m3 (agua)
    [M1_,~] = Mom_rect(y1,b,Q);
    M2_hib = (y2/2)*(b*y2) + Q^2/(g*b*a2);
    F = gamma*(M1_ - M2_hib);
    fprintf("M(y1=%.4f, seccion completa) = %.4f m3\n", y1, M1_);
    fprintf("M2 hibrido (y2=%.4f, presion con seccion completa + velocidad en area contraida a2) = %.4f m3 (~M3_=%.4f)\n", y2, M2_hib, M3_);
    fprintf("Fuerza sobre la compuerta F = gamma*(M1-M2_hib) = %.1f N\n", F);
else
    [Ea2, y1_2] = Eesp_rect(a2,b,Q);
    fprintf("y aguas arriba de la compuerta (alterno de a=%.2f) = %.4f m\n", a2, y1_2);
end
