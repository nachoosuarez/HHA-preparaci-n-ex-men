% ej1_cauce_fgv.m — Examen 13/feb/2020, Ejercicio 1, Parte 2.
% Cauce rectangular aguas abajo de la alcantarilla, que descarga a un lago.
% Calcula yn, yc del cauce y la curva M2 controlada por el nivel del lago,
% para obtener el tirante y4 en la sección de la alcantarilla (200 m aguas
% arriba del lago).
% Requiere: rect_geom.m, rect.m, critico.m, froude_rect.m, manning_rect.m
% (misma carpeta).
clear all

%% Datos de entrada (cauce)
Q = 10;        % caudal (m3/s)
b = 3.5;       % ancho del cauce (m)
S = 0.0003;    % pendiente de fondo del cauce
n = 0.009;     % n de Manning del cauce
L = 200;       % distancia alcantarilla-lago (m)
hLago = 1.55;  % nivel del lago sobre el fondo del cauce (m)

%% Tirante crítico (fórmula cerrada, rectangular)
yc = (Q^2/(9.8*b^2))^(1/3);
par = [Q b];
yc = fsolve(@(y) froude_rect(y,par), yc);

%% Tirante normal (Manning)
yn0 = (Q*n/(b*S^0.5))^(3/5);
par = [Q b S n];
yn = fsolve(@(y) manning_rect(y,par), yn0);

printf('yc = %.4f m\n', yc);
printf('yn = %.4f m\n', yn);
if yn > yc
  printf('=> yn > yc: canal tipo M (mild)\n');
else
  printf('=> yn < yc: canal tipo S (steep)\n');
end

%% Curva M2: control aguas abajo (lago) hacia aguas arriba (alcantarilla)
% x=0 en el lago, x=-200 en la alcantarilla (x crece hacia aguas abajo)
par = [Q b S n yc];
options = odeset('Events',@(x,y) critico(x,y,par), 'RelTol',1e-10,'AbsTol',1e-12);
[x,y] = ode45(@(x,y) rect(x,y,par), [0,-L], hLago, options);

y4 = y(end);
printf('\nCondicion de borde: y(lago, x=0) = %.3f m\n', hLago);
printf('y4 = tirante en la alcantarilla (x=-200 m) = %.4f m\n', y4);
