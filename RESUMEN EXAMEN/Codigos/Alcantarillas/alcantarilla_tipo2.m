% alcantarilla_tipo2.m — ALCANTARILLA Tipo 2 (entrada ahogada h1/D>=1.5,
% salida NO ahogada pero alcantarilla "hidraulicamente larga": fluye
% LLENA en toda su longitud), Teorico HHA Sec.3.2.1 Fig.3.2.3. Balance
% de carga entre la seccion aguas arriba (1) y la seccion de salida (3),
% con h3=D (chorro a tubo lleno saliendo a la atmosfera) y z=0 en el
% zampeado de salida.
%
% Que hace: dado h1 (carga aguas arriba, referida al zampeado de
% salida), calcula el caudal Q que circula, sumando la perdida
% localizada de entrada (CD1, Tabla 3.2.1, igual que Tipo 1) y la
% perdida distribuida por friccion (Manning) a lo largo de la
% alcantarilla.
% Que pide: geometria (B,H rectangular o D circular), n de Manning, L,
% r/H de la embocadura, y h1.
% Que resuelve: caudal circulante quando la entrada esta ahogada pero la
% salida descarga libre (no hay lago que ahogue la salida) y la
% alcantarilla es larga/de pendiente baja (se verifica Tipo2 vs Tipo3
% con el abaco Fig.3.2.5/3.2.6, no incluido aqui: para L/D grande y S0
% chica corresponde Tipo 2).
clear all

%% ==== EDITAR ACA ====
Balc = 2;      % ancho (m), rectangular (usar D para circular, ver abajo)
Halc = 1.5;    % altura/diametro (m)
circular = false; % true si es alcantarilla circular (usa D=Halc)
nalc = 0.013;  % n de Manning
Lalc = 20;     % longitud (m)
rH   = 0.02;   % r/H o r/D de la embocadura (redondeo de entrada)

h1 = 2.456;    % carga aguas arriba, referida al zampeado de salida (m)
%% =====================

g = 9.8;

if circular
  D = Halc;
  AT = pi*D^2/4;
  Pm = pi*D;
else
  D = Halc;
  AT = Balc*Halc;
  Pm = 2*Halc + Balc;
end
Rh = AT/Pm;

tabla_rH  = [0.00 0.02 0.06 0.08 0.10 0.12];
tabla_CD1 = [0.84 0.88 0.91 0.96 0.97 0.98];
CD1 = interp1(tabla_rH, tabla_CD1, rH, 'linear', 'extrap');

h3 = D; % salida a tubo lleno (chorro), referida a su propio zampeado

den = 1 + 2*g*CD1^2*nalc^2*Lalc/Rh^(4/3);
Q = CD1*AT*sqrt(2*g*(h1-h3)/den);

printf('CD1 = %.3f, Rh = %.4f m, h3 = D = %.3f m\n', CD1, Rh, h3);
printf('Q (Tipo 2) = %.3f m3/s\n', Q);
printf('h1/D = %.3f (Tipo 2 requiere entrada ahogada, h1/D>=1.5)\n', h1/D);
