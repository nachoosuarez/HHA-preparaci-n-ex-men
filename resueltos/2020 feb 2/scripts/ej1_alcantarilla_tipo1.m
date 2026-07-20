% ej1_alcantarilla_tipo1.m — Examen 13/feb/2020, Ejercicio 1, Parte 2.
% Balance de carga en la alcantarilla (Tipo 1: entrada y salida ahogadas),
% Teorico HHA Sec.3.2.1. h1 = h4 + perdida localizada entrada + perdida
% distribuida (Manning), referidas al fondo (zampeado) de salida de la
% alcantarilla.
clear all

%% Datos de la alcantarilla
Q    = 10;     % caudal (m3/s)
Balc = 2;      % ancho (m)
Halc = 1.5;    % altura (m)
nalc = 0.013;  % n de Manning
Lalc = 20;     % longitud (m)
rH   = 0.02;   % r/H (embocadura redondeada)
g    = 9.8;

%% Geometria (seccion llena, Tipo 1)
AT = Balc*Halc;
Pm = 2*Halc + Balc;
Rh = AT/Pm;

%% Coeficiente de descarga CD1 (Tabla 3.2.1, r/H=0.02 -> CD1=0.88)
CD1 = 0.88;

%% Verificacion de condicion de flujo Tipo 1: h4/H >= 1
h4 = 1.5636;  % tirante en el cauce a la salida (calculado en ej1_cauce_fgv.m)
printf('h4/H = %.3f (Tipo 1 requiere >= 1)\n', h4/Halc);

%% Balance de carga h1 = h4 + perdida entrada + perdida friccion
perdida_entrada = Q^2/(2*g*CD1^2*AT^2);
perdida_friccion = Q^2*nalc^2*Lalc/(AT^2*Rh^(4/3));
h1 = h4 + perdida_entrada + perdida_friccion;

printf('AT = %.3f m2, Rh = %.4f m\n', AT, Rh);
printf('perdida entrada  = %.4f m\n', perdida_entrada);
printf('perdida friccion = %.4f m\n', perdida_friccion);
printf('h1 (referido al fondo de salida) = %.4f m\n', h1);
printf('h1/H = %.3f\n', h1/Halc);
