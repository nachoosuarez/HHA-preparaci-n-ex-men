% alcantarilla_tipo1.m — ALCANTARILLA Tipo 1 (entrada y salida ahogadas,
% h1/D>=1 y h4/D>=1), Teorico HHA Sec.3.2.1 Fig.3.2.2. Balance de carga
% entre la seccion aguas arriba (1) y la seccion de salida (4), con
% z=0 en el zampeado de salida.
%
% Que hace: dado el caudal Q, calcula la carga aguas arriba h1 a partir
% de h4 (o viceversa si Q es la incognita), sumando la perdida
% localizada de entrada (coef. CD1, Tabla 3.2.1) y la perdida distribuida
% por friccion (Manning) a lo largo de la alcantarilla.
% Que pide: geometria (B,H rectangular o D circular), n de Manning, L,
% r/H (o r/D) de la embocadura, y el caudal Q o bien h1 y h4 (para el
% caso inverso).
% Que resuelve: verificacion/diseno de alcantarillas ahogadas en ambos
% extremos (ej. cauce con nivel alto en el lago de salida Y aguas
% arriba). Ver tambien alcantarilla_tipo2.m para el caso "hidraulicamente
% larga" con salida NO ahogada.
clear all

%% ==== EDITAR ACA ====
Balc = 2;      % ancho (m), rectangular (usar D para circular, ver abajo)
Halc = 1.5;    % altura/diametro (m)
circular = false; % true si es alcantarilla circular (usa D=Halc)
nalc = 0.013;  % n de Manning
Lalc = 20;     % longitud (m)
rH   = 0.02;   % r/H o r/D de la embocadura (redondeo de entrada)

Q  = 10;       % caudal (m3/s) -- dejar [] si se conoce h1 y h4 y se busca Q
h4 = 1.564;    % carga aguas abajo, referida al zampeado de salida (m)
%% =====================

g = 9.8;

% Geometria a seccion llena
if circular
  D = Halc;
  AT = pi*D^2/4;
  Pm = pi*D;
else
  AT = Balc*Halc;
  Pm = 2*Halc + Balc;
end
Rh = AT/Pm;

% CD1 (Tabla 3.2.1) por interpolacion lineal en r/H
tabla_rH  = [0.00 0.02 0.06 0.08 0.10 0.12];
tabla_CD1 = [0.84 0.88 0.91 0.96 0.97 0.98];
CD1 = interp1(tabla_rH, tabla_CD1, rH, 'linear', 'extrap');

perdida_entrada_coef = 1/(2*g*CD1^2*AT^2);      % multiplica Q^2
perdida_friccion_coef = nalc^2*Lalc/(AT^2*Rh^(4/3)); % multiplica Q^2

if ~isempty(Q)
  h1 = h4 + Q^2*(perdida_entrada_coef + perdida_friccion_coef);
  printf('CD1 = %.3f, Rh = %.4f m\n', CD1, Rh);
  printf('h1 = %.4f m  (h1/D = %.3f)\n', h1, h1/Halc);
  printf('h4/D = %.3f\n', h4/Halc);
  if h1/Halc>=1 && h4/Halc>=1
    printf('=> Tipo 1 verificado (h1/D>=1 y h4/D>=1)\n');
  else
    printf('=> ADVERTENCIA: no se cumple la condicion de Tipo 1, revisar\n');
  end
else
  h1 = input('h1 (m), referido al zampeado de salida: ');
  Q = sqrt((h1-h4)/(perdida_entrada_coef+perdida_friccion_coef));
  printf('Q = %.3f m3/s\n', Q);
end
