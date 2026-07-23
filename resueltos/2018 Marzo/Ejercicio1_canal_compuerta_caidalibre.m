% Ejercicio1_canal_compuerta_caidalibre.m
% Examen HHA 22 marzo 2018 (Mesa especial) — Ejercicio 1.
% Canal rectangular MUY LARGO ("infinito"), b=6.5m, n=0.02, S0=0.001,
% Q=25 m3/s, termina en caída libre. Se agrega una compuerta de fondo
% ideal a L=3000 m aguas arriba de la caída libre, primero con
% apertura a=0.35 m (parte 2) y luego a=0.6 m (parte 3).
%
% Requiere en la misma carpeta: rect_geom.m, rect.m, critico.m,
% froude_rect.m, manning_rect.m, critico_rect.m, Eesp_rect.m, Mom_rect.m
% (copiados de RESUMEN EXAMEN/Codigos/FGV_rectangular/).
clear all
warning('off','all');
g = 9.8;
gamma = 9800; % N/m3

%% Datos
Q = 25;      % m3/s
b = 6.5;     % m
n = 0.02;
S0 = 0.001;

%% ===== PARTE 1: canal sin compuerta =====
yc = critico_rect(b,Q);
par = [Q b S0 n];
yn = fzero(@(y) manning_rect(y,par), 2);
printf("--- PARTE 1 ---\n");
printf("yc = %.4f m\n", yc);
printf("yn = %.4f m\n", yn);
if yn > yc
  printf("yn > yc => CANAL TIPO M (pendiente suave/subcritica)\n");
else
  printf("yn < yc => CANAL TIPO S (pendiente fuerte/supercritica)\n");
end
% perfil: canal muy largo => y=yn en casi todo el tramo, curva M2 de
% drawdown en el ultimo tramo antes de la caida libre (y: yn -> yc).

%% ===== PARTE 2: compuerta a=0.35 m, L=3000 m aguas arriba de la caida =====
a2 = 0.35;
printf("\n--- PARTE 2 (a = %.2f m) ---\n", a2);

% y2: aguas abajo de la compuerta (vena contracta ideal) = a
y2 = a2;

% y1: aguas arriba de la compuerta = ALTERNO de y2 (misma energia
% especifica, compuerta ideal sin perdidas), rama subcritica
[E2, ~] = Eesp_rect(y2,b,Q);
y1 = fzero(@(y) y + Q^2/(2*g*(b*y)^2) - E2, [yn, 50]);
printf("E(a) = %.4f m  =>  y1 (alterno, aguas arriba) = %.4f m\n", E2, y1);

% Libre o ahogada: conjugado de a2 vs. yn (tirante de referencia aguas abajo)
[~, aconj] = Mom_rect(a2,b,Q);
printf("conjugado(a=%.2f) = %.4f m ; yn = %.4f m\n", a2, aconj, yn);
if aconj > yn
  printf("conjugado(a) > yn => DESCARGA LIBRE (M3 corta + resalto antes de yn)\n");
  modo2 = "libre";
else
  printf("conjugado(a) < yn => DESCARGA AHOGADA\n");
  modo2 = "ahogada";
end

if strcmp(modo2,"libre")
  % Curva M3 corta: acelera desde y2=a hasta y3, tal que el CONJUGADO
  % de y3 (via Mom_rect) sea igual a yn (el resalto reconecta
  % directamente con el tirante normal, ya que el tramo hasta la caida
  % libre es mucho mas largo que el desarrollo de esta curva M3).
  y3 = fzero(@(y) yconj_rect(y,b,Q) - yn, [y2+1e-6, yc-1e-6]);
  [M3chk, y3conj] = Mom_rect(y3,b,Q);
  printf("y3 (fin curva M3, antes del resalto) = %.4f m  (conjugado = %.4f m ~ yn)\n", y3, y3conj);

  % Longitud de la curva M3 (x=0 en la compuerta, aguas abajo) - integracion ode23
  par_fgv = [Q b S0 n yc];
  opts = odeset('Events', @(x,y) critico(x,y,par_fgv), 'RelTol',1e-10,'AbsTol',1e-12);
  [xM3,yM3] = ode23(@(x,y) rect(x,y,par_fgv), [0 3000], y2, opts);
  % localizar x donde yM3 cruza y3
  idx = find(yM3>=y3,1,'first');
  if isempty(idx)
    Lm3 = NaN;
  else
    Lm3 = interp1(yM3(max(idx-1,1):idx), xM3(max(idx-1,1):idx), y3);
  end
  printf("Longitud curva M3 (compuerta -> resalto) ~ %.1f m\n", Lm3);

  % Fuerza sobre la compuerta: F = gamma*(M1 - M2), seccion llena y=a (libre)
  [M1,~] = Mom_rect(y1,b,Q);
  [M2,~] = Mom_rect(y2,b,Q);
  F2 = gamma*(M1-M2);
  printf("M1 = %.3f m3 (y1=%.4f)\n", M1, y1);
  printf("M2 = %.3f m3 (y2=a=%.4f)\n", M2, y2);
  printf("F sobre compuerta = gamma*(M1-M2) = %.0f N = %.3f x10^6 N\n", F2, F2/1e6);
end

%% ===== PARTE 3: se abre la compuerta a a=0.6 m =====
a3 = 0.6;
printf("\n--- PARTE 3 (a = %.2f m) ---\n", a3);
[~, aconj3] = Mom_rect(a3,b,Q);
printf("conjugado(a=%.2f) = %.4f m ; yn = %.4f m\n", a3, aconj3, yn);
if aconj3 > yn
  printf("conjugado(a) > yn => DESCARGA LIBRE\n");
  modo3 = "libre";
else
  printf("conjugado(a) < yn => DESCARGA AHOGADA (flujo dividido bajo la compuerta)\n");
  modo3 = "ahogada";
end

if strcmp(modo3,"ahogada")
  % Momento de referencia aguas abajo = Mom(yn) (el resalto queda muy
  % cerca de la compuerta, tailwater = yn)
  [M4,~] = Mom_rect(yn,b,Q);
  Am = b*a3;
  % Momento entre (2,vena contracta, hidrostatica con y2 real) y (4,yn):
  % b*y2^2/2 + Q^2/(g*Am) = M4
  y2_3 = sqrt(2/b*(M4 - Q^2/(g*Am)));
  E3 = y2_3 + Q^2/(2*g*Am^2);
  y1_3 = fzero(@(y) y + Q^2/(2*g*(b*y)^2) - E3, [yn, 50]);
  [M1_3,~] = Mom_rect(y1_3,b,Q);
  F3 = gamma*(M1_3 - M4);
  printf("M4 (=Mom(yn), referencia aguas abajo) = %.3f m3\n", M4);
  printf("y2 (seccion contraida bajo la compuerta, hidrostatica) = %.4f m\n", y2_3);
  printf("E3 = %.4f m  =>  y1 (aguas arriba de la compuerta) = %.4f m\n", E3, y1_3);
  printf("M1 = %.3f m3\n", M1_3);
  printf("F sobre compuerta = gamma*(M1-M4) = %.0f N = %.3f x10^6 N\n", F3, F3/1e6);
end
