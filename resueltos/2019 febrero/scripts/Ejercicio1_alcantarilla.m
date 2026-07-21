% Ejercicio1_alcantarilla.m — Examen 7/feb/2019, Ejercicio 1.
% Canal trapezoidal infinito (b=4.5m, talud 1V:2.5H, n=0.02, S0=0.0007)
% con alcantarilla de 3 tuberias circulares D=1m (n=0.013, L=15m,
% entrada redondeada r/D=0.02), apoyadas sobre el lecho del canal.
% Para Qd=10 m3/s y Qt=6 m3/s: clasifica el canal (M o S comparando
% yn vs yc), determina el tipo de funcionamiento de la alcantarilla
% (Tipo 1 si h4/D>=1, Tipo 2 si no) y calcula h1 (carga aguas arriba)
% con el balance de carga de RESUMEN EXAMEN/Codigos/Alcantarillas.
% Requiere trap_geom.m, eq_yn.m, eq_yc.m en el mismo directorio.
clear all
g = 9.8;

%% Datos del canal
b  = 4.5;     % ancho de fondo (m)
m  = 2.5;     % talud lateral 1V:2.5H
n  = 0.02;    % Manning del canal
S0 = 0.0007;  % pendiente de fondo

%% Datos de la alcantarilla (por tubo, se reparte Q entre 3 tubos iguales)
Ntubos = 3;
D    = 1;      % diametro (m)
nalc = 0.013;  % Manning de la alcantarilla
Lalc = 15;     % longitud (m)
rD   = 0.02;   % r/D de la embocadura

AT = pi*D^2/4;
Pm = pi*D;
Rh = AT/Pm;

tabla_rH  = [0.00 0.02 0.06 0.08 0.10 0.12];
tabla_CD1 = [0.84 0.88 0.91 0.96 0.97 0.98];
CD1 = interp1(tabla_rH, tabla_CD1, rD, 'linear', 'extrap');
printf('CD1 (r/D=%.2f) = %.3f ; Rh alcantarilla = %.4f m\n\n', rD, CD1, Rh);

perdida_entrada_coef  = 1/(2*g*CD1^2*AT^2);        % multiplica Qalc^2
perdida_friccion_coef = nalc^2*Lalc/(AT^2*Rh^(4/3)); % multiplica Qalc^2

z = S0*Lalc; % desnivel de zampeado entre entrada y salida de la alcantarilla
printf('Desnivel de zampeado z = S0*L = %.4f m\n\n', z);

for Q = [10 6]
  printf('=== Q = %.1f m3/s ===\n', Q);

  % yn (normal, Manning) y yc (critico) del canal trapezoidal aguas abajo
  yn = fsolve(@(y) eq_yn(y,Q,n,m,b,S0), 1.0, optimset('Display','off'));
  yc = fsolve(@(y) eq_yc(y,Q,m,b), 0.5, optimset('Display','off'));
  if yn > yc
    tipo_canal = 'M (subcritico, yn>yc)';
  else
    tipo_canal = 'S (supercritico, yn<yc)';
  end
  printf('yn = %.3f m ; yc = %.3f m -> canal %s\n', yn, yc, tipo_canal);

  Qalc = Q/Ntubos;
  h4_normal = yn; % tirante normal aguas abajo de la alcantarilla (canal infinito)

  if h4_normal/D >= 1
    % Tipo 1: entrada y salida ahogadas. h4 = yn (tirante normal, referido
    % al fondo local aguas abajo == fondo del zampeado de salida).
    h4 = h4_normal;
    h1 = h4 + Qalc^2*(perdida_entrada_coef + perdida_friccion_coef);
    y1 = h1 - z; % tirante aguas arriba, referido al fondo LOCAL de esa seccion
    printf('h4/D = %.3f >= 1 -> ALCANTARILLA TIPO 1 (entrada y salida ahogadas)\n', h4_normal/D);
    printf('Qalc = %.4f m3/s por tubo\n', Qalc);
    printf('h1 (referido al fondo de salida) = %.4f m\n', h1);
    printf('y1 = h1 - z = %.4f m ; y1/D = %.3f\n', y1, y1/D);
    if y1/D >= 1
      printf('=> y1 > yn > yc: curva de remanso M1 aguas arriba de la alcantarilla\n');
    end
    printf('*** RESULTADO Q=%.1f: y1 = %.2f m (Tipo 1) ***\n\n', Q, y1);
  else
    % Tipo 2: entrada ahogada, salida a tubo lleno (chorro), h3=D.
    h3 = D;
    h1 = h3 + Qalc^2*(perdida_entrada_coef + perdida_friccion_coef);
    y1 = h1 - z;
    printf('h4/D = %.3f < 1 -> salida NO ahogada -> ALCANTARILLA TIPO 2 (hidraulicamente larga, L/D=%.0f, S0 baja)\n', h4_normal/D, Lalc/D);
    printf('Qalc = %.4f m3/s por tubo ; h3 = D = %.3f m\n', Qalc, h3);
    printf('h1 (referido al fondo de salida) = %.4f m\n', h1);
    printf('y1 = h1 - z = %.4f m ; y1/D = %.3f (Tipo 2 requiere y1/D>=1.5)\n', y1, y1/D);
    printf('=> Aguas abajo, el tubo lleno descarga como chorro y vuelve por resalto a yn=%.3f (canal M)\n', yn);
    printf('*** RESULTADO Q=%.1f: y1 = %.2f m (Tipo 2) ***\n\n', Q, y1);
  end
end
