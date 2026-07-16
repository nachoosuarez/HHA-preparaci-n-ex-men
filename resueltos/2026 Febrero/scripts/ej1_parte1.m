%% EJERCICIO 1 - Parte 1
% Lago A descarga a canal trapezoidal que termina en caida libre.
% Datos del enunciado (Examen Febrero 2026)
clear all
addpath('.')

b   = 5.5;    % ancho de fondo (m)
m   = 1;      % talud lateral 1V:mH
n   = 0.012;  % n de Manning
S0  = 0.001;  % pendiente de fondo
hLA = 1.5;    % nivel del Lago A sobre el fondo del canal (m)
L   = 4000;   % longitud del canal (m)
g   = 9.8;

%% 1) Suponiendo canal tipo M: y(x=0) = yn, E(x=0) = hLA
[Q, yn, yc] = caudal_M_ini(n, m, b, S0, hLA);
fprintf('Q  = %.4f m3/s\n', Q);
fprintf('yn = %.4f m\n', yn);
fprintf('yc = %.4f m\n', yc);

if yn > yc
  fprintf('yn > yc => canal tipo MILD (M). Se confirma la hipotesis.\n');
else
  fprintf('yn < yc => canal tipo STEEP (S). La hipotesis M es incorrecta.\n');
end

%% Verificacion numerica: integrar curva M2 desde la caida (y=yc) hasta x=0
% y comprobar que el tirante en el lago (x=0) es efectivamente ~ yn,
% validando la hipotesis y1=yn usada para estimar Q.
par = [Q b S0 n yc m];
options = odeset('Events', @(x,y) critico(x,y,par));
x_ini = L; x_end = 0; y_ini = yc + 0.001;
[x,y] = ode23(@(x,y) rect(x,y,par), [x_ini, x_end], y_ini, options);

y0 = y(end);
fprintf('\nIntegrando la curva M2 desde la caida libre (x=%.0f, y=yc) hacia aguas arriba:\n', L);
fprintf('y(x=0) obtenido por integracion = %.4f m  (yn = %.4f m)\n', y0, yn);
fprintf('Diferencia relativa = %.3f %%\n', 100*abs(y0-yn)/yn);

% Verificacion de energia especifica en el lago con el y0 integrado
[B0,A0,P0,R0,yG0,D0] = trap_geom(y0,b,m);
U0 = Q/A0;
E0 = y0 + U0^2/(2*g);
fprintf('Energia especifica en x=0 con y0 integrado = %.4f m (hLA = %.4f m)\n', E0, hLA);

% Distancia a la que la curva M2 se aparta mas de 1%% de yn (longitud de la
% zona de remanso/abatimiento cerca de la caida)
idx = find(abs(y - yn) > 0.01*yn, 1, 'last');
if ~isempty(idx)
  fprintf('\nLa curva se aparta >1%% de yn recien a partir de x = %.1f m\n', x(idx));
  fprintf('(es decir, el tramo con caudal M2 significativo tiene largo ~ %.1f m de %.0f m totales)\n', L-x(idx), L);
end

save('-mat','part1.mat','Q','yn','yc','x','y','b','m','n','S0','hLA','L','g');
