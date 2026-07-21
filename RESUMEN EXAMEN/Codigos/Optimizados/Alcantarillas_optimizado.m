% Alcantarillas_optimizado.m — ALCANTARILLA Tipo 1 / Tipo 2 consolidada
% (Teorico HHA Sec.3.2.1), con clasificacion automatica y opcion de
% obtener el tirante aguas abajo h4 desde un canal (trapezoidal o
% rectangular, tirante normal yn por Manning) en vez de darlo como dato
% directo. Editar solo el bloque de abajo y correr.
%
% Que resuelve:
%  - Para cada caudal Q de la lista (uno o varios, p.ej. condicion de
%    diseno + evento extremo), calcula el tirante aguas abajo h4 (via
%    yn del canal, si CANAL='trapezoidal'/'rectangular', o tomado
%    directo de H4_DATO si CANAL='directo'), determina si la
%    alcantarilla es TIPO 1 (h4/D>=1, entrada y salida ahogadas) o
%    TIPO 2 (h4/D<1, hidraulicamente larga, sale a tubo lleno h3=D), y
%    calcula h1 (carga aguas arriba, referida al zampeado de SALIDA) y
%    el tirante y1 referido al fondo LOCAL de la entrada.
%  - Si CANAL no es 'directo', tambien calcula yc y clasifica el canal
%    M/S (yn vs yc) para poder describir la curva de remanso aguas
%    arriba si queda Tipo 1.
%
% Que pide: geometria de la alcantarilla (D circular, o B,H rectangular),
% n de Manning de la alcantarilla, longitud L, r/D o r/H de la
% embocadura, numero de tubos (si son varios en paralelo se reparte Q
% en partes iguales); geometria del canal aguas abajo (b, m, n, S0) si
% CANAL≠'directo'; lista de caudales Q a evaluar.
%
% Requiere en la misma carpeta: colebrook.m NO hace falta. Si
% CANAL='trapezoidal', requiere trap_geom.m, eq_yn.m, eq_yc.m (copias
% de FGV_trapezoidal/). Si CANAL='rectangular', requiere rect_geom.m,
% manning_rect.m, froude_rect.m (copias de FGV_rectangular/).
%
% Verificado contra: resueltos/2019 febrero/RESOLUCION.md Ejercicio 1
% (canal trapezoidal b=4.5, m=2.5, n=0.02, S0=0.0007; alcantarilla 3
% tubos D=1m, n=0.013, L=15m, r/D=0.02; Q=10 -> Tipo1, y1=2.64m;
% Q=6 -> Tipo2, y1=1.52m) y resueltos/2020 feb 2/RESOLUCION.md
% Ejercicio 1 (CANAL='directo', h4 dado, Tipo1).
clear all
g = 9.8;

%% ==== EDITAR ACA ====
CANAL = 'trapezoidal';  % 'trapezoidal' | 'rectangular' | 'directo'

% --- si CANAL='trapezoidal' o 'rectangular' ---
b_canal  = 4.5;   % ancho de fondo (m)
m_canal  = 2.5;   % talud lateral 1V:mH (poner 0 si CANAL='rectangular')
n_canal  = 0.02;  % Manning del canal
S0_canal = 0.0007;% pendiente de fondo

% --- si CANAL='directo' ---
H4_DATO = [];     % tirante aguas abajo (m), uno por cada Q de la lista (dejar [] si CANAL~='directo')

% --- Alcantarilla ---
Ntubos = 3;       % cantidad de tubos/celdas iguales en paralelo
circular = true;  % true: usa D ; false: usa Balc,Halc (rectangular)
D    = 1;         % diametro (m), si circular
Balc = 2; Halc = 1.5; % ancho/altura (m), si rectangular
nalc = 0.013;     % Manning de la alcantarilla
Lalc = 15;        % longitud (m)
rD   = 0.02;      % r/D (o r/H) de la embocadura

Qlist = [10 6];   % caudales TOTALES a evaluar (m3/s), uno o varios
%% =====================

if circular
  AT = pi*D^2/4; Pm = pi*D; Dref = D;
else
  AT = Balc*Halc; Pm = 2*Halc+Balc; Dref = Halc;
end
Rh = AT/Pm;

tabla_rH  = [0.00 0.02 0.06 0.08 0.10 0.12];
tabla_CD1 = [0.84 0.88 0.91 0.96 0.97 0.98];
CD1 = interp1(tabla_rH, tabla_CD1, rD, 'linear', 'extrap');
printf('CD1(r/D=%.2f)=%.3f ; AT=%.4f m2 ; Rh=%.4f m\n\n', rD, CD1, AT, Rh);

perdida_entrada_coef  = 1/(2*g*CD1^2*AT^2);
perdida_friccion_coef = nalc^2*Lalc/(AT^2*Rh^(4/3));
z = S0_canal*Lalc; % desnivel de zampeado entrada-salida (0 si CANAL='directo' y no aplica)

for k = 1:length(Qlist)
  Q = Qlist(k);
  printf('=== Q = %.3f m3/s ===\n', Q);

  switch CANAL
    case 'trapezoidal'
      yn = fsolve(@(y) eq_yn(y,Q,n_canal,m_canal,b_canal,S0_canal), 1.0, optimset('Display','off'));
      yc = fsolve(@(y) eq_yc(y,Q,m_canal,b_canal), 0.5, optimset('Display','off'));
      if yn>yc, clase='M (subcritico)'; else clase='S (supercritico)'; end
      printf('yn=%.4f m ; yc=%.4f m -> canal %s\n', yn, yc, clase);
      h4 = yn;
    case 'rectangular'
      par = [Q b_canal S0_canal n_canal];
      yn = fsolve(@(y) manning_rect(y,par), 1.0, optimset('Display','off'));
      yc = (Q^2/(g*b_canal^2))^(1/3);
      if yn>yc, clase='M (subcritico)'; else clase='S (supercritico)'; end
      printf('yn=%.4f m ; yc=%.4f m -> canal %s\n', yn, yc, clase);
      h4 = yn;
    otherwise
      h4 = H4_DATO(k);
      printf('h4 (dato directo) = %.4f m\n', h4);
  end

  Qalc = Q/Ntubos;
  if h4/Dref >= 1
    h1 = h4 + Qalc^2*(perdida_entrada_coef + perdida_friccion_coef);
    y1 = h1 - z;
    printf('h4/D=%.3f>=1 -> TIPO 1 (entrada y salida ahogadas). Qalc=%.4f m3/s\n', h4/Dref, Qalc);
    printf('h1=%.4f m ; y1=h1-z=%.4f m (y1/D=%.3f)\n\n', h1, y1, y1/Dref);
  else
    h3 = Dref;
    h1 = h3 + Qalc^2*(perdida_entrada_coef + perdida_friccion_coef);
    y1 = h1 - z;
    printf('h4/D=%.3f<1 -> TIPO 2 (hidraulicamente larga, h3=D). Qalc=%.4f m3/s\n', h4/Dref, Qalc);
    printf('h1=%.4f m ; y1=h1-z=%.4f m (y1/D=%.3f, Tipo2 requiere y1/D>=1.5)\n\n', h1, y1, y1/Dref);
  end
end
