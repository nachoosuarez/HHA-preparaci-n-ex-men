%% EJERCICIO 1 - Parte 2
% Compuerta de fondo ideal a L=800 m antes de la caida libre (x = 3200 m
% medido desde el Lago A), abertura a = 0.8 m.
clear all
load('part1.mat');   % Q, yn, yc, b, m, n, S0, hLA, L, g, x, y (perfil M2 sin compuerta)

xg = 3200;           % ubicacion de la compuerta (800 m antes de la caida)
a  = 0.8;            % abertura de la compuerta (m)

fprintf('--- Datos ---\n');
fprintf('Q = %.4f m3/s (se mantiene el de la Parte 1)\n', Q);
fprintf('yc = %.4f m ; a = %.2f m\n', yc, a);
if a < yc
  fprintf('a < yc => la compuerta CONTROLA el escurrimiento (aguas arriba se forma una curva M1/M2).\n');
else
  fprintf('a > yc => la compuerta no afecta el perfil (queda ahogada sin restriccion).\n');
end

%% Aguas arriba de la compuerta: yB = a (compuerta ideal, sin contraccion)
% Por conservacion de energia especifica en el pasaje por la compuerta,
% yA (aguas arriba) es el tirante alterno subcritico de yB = a.
yB = a;
[E_gate, ~] = Eesp_trap(yB, b, Q, m);
[yalt1, yalt2] = alternos_trap(b, m, Q, E_gate);
yA = max(yalt1, yalt2);   % raiz subcritica (mayor tirante)
fprintf('\nE en la compuerta = %.4f m\n', E_gate);
fprintf('yA (tirante inmediatamente aguas arriba de la compuerta) = %.4f m\n', yA);

if yA > yn
  fprintf('yA > yn => curva M1 (remanso) entre el Lago A y la compuerta.\n');
else
  fprintf('yA < yn => curva M2 entre el Lago A y la compuerta.\n');
end

%% Integrar la curva aguas arriba de la compuerta (M1) desde x=3200 hasta x=0
par = [Q b S0 n yc m];
[xu, yu] = ode23(@(x,y) rect(x,y,par), [xg, 0], yA);
y_lago = yu(end);
[Bl,Al,Pl,Rl,yGl,Dl] = trap_geom(y_lago,b,m);
Ul = Q/Al;
El = y_lago + Ul^2/(2*g);
fprintf('\nIntegrando M1 desde la compuerta (x=%.0f) hasta el Lago A (x=0):\n', xg);
fprintf('y(x=0) = %.4f m ; E(x=0) = %.4f m (hLA = %.4f m)\n', y_lago, El, hLA);
fprintf('=> Al ser el canal muy largo aguas arriba de la compuerta, la curva M1\n');
fprintf('   se relaja a yn mucho antes de llegar al lago: el caudal Q no cambia.\n');

%% Aguas abajo de la compuerta: verificar si la descarga es libre o ahogada
% a* = conjugado de a (rama subcritica del salto hidraulico partiendo de yB=a)
[Mg, yconj] = Mom_trap(a, b, m, Q);
a_star = yconj;
fprintf('\nConjugado de a (a*) = %.4f m\n', a_star);

% yBM1M2: tirante que traeria la curva M2 que baja desde la caida libre
% (calculada en la Parte 1) evaluado en x = xg
yBM1M2 = interp1(x, y, xg);
fprintf('Tirante de la curva M2 (proveniente de la caida libre) en x = %.0f m: %.4f m\n', xg, yBM1M2);

if a_star > yBM1M2
  fprintf('a* > y_M2(xg)  => DESCARGA LIBRE en la compuerta.\n');
  libre = true;
else
  fprintf('a* <= y_M2(xg) => DESCARGA AHOGADA en la compuerta.\n');
  libre = false;
end

%% Funcion auxiliar rapida (biseccion) para el tirante conjugado subcritico
function y2 = conj_fast(y1, b, m, Q, yc, g)
  Mfun = @(yy) momentum_trap(yy, b, m, Q, g);
  M1 = Mfun(y1);
  lo = yc*1.0001; hi = yc*2;
  while Mfun(hi) < M1
    hi = hi*1.5;
  end
  for it = 1:60
    mid = (lo+hi)/2;
    if Mfun(mid) < M1
      lo = mid;
    else
      hi = mid;
    end
  end
  y2 = (lo+hi)/2;
end

function Mv = momentum_trap(y, b, m, Q, g)
  [B,A,P,R,yG,D] = trap_geom(y,b,m);
  Mv = yG*A + Q^2/(g*A);
end

%% Si la descarga es libre: curva M3 aguas abajo de la compuerta y resalto
if libre
  xd = linspace(xg, L, 161)';
  [xd, yd] = ode23(@(x,y) rect(x,y,par), xd, a);

  % Para cada punto de la M3, calculo el conjugado (biseccion rapida) y lo
  % comparo con la curva M2 (validada ~constante = yn en este tramo, Parte 1)
  nds = numel(xd);
  conj_M3 = nan(nds,1);
  for i = 1:nds
    conj_M3(i) = conj_fast(yd(i), b, m, Q, yc, g);
  end
  y_M2_tramo = interp1(x, y, xd);   % curva M2 evaluada en los mismos x

  diff_fun = conj_M3 - y_M2_tramo;
  isign = find(diff_fun(1:end-1) .* diff_fun(2:end) < 0, 1, 'first');

  if ~isempty(isign)
    % interpolacion lineal para hallar el cruce
    x1 = xd(isign); x2 = xd(isign+1);
    d1 = diff_fun(isign); d2 = diff_fun(isign+1);
    x_resalto = x1 - d1*(x2-x1)/(d2-d1);
    y_M3_resalto = interp1(xd, yd, x_resalto);
    y_M2_resalto = interp1(x, y, x_resalto);
    fprintf('\nResalto hidraulico ubicado en x = %.2f m (x_rel = %.2f m aguas abajo de la compuerta)\n', ...
             x_resalto, x_resalto - xg);
    fprintf('Tirante antes del resalto  (rama M3, supercritico) y1 = %.4f m\n', y_M3_resalto);
    fprintf('Tirante despues del resalto (rama M2, subcritico)  y2 = %.4f m\n', y_M2_resalto);
  else
    fprintf('\nNo se encontro interseccion entre M3* y M2 en el tramo: revisar.\n');
  end
end

save('-mat','part2.mat','Q','yn','yc','b','m','n','S0','hLA','L','g','xg','a','yA','y_lago', ...
     'a_star','yBM1M2','libre','xd','yd','x_resalto','y_M3_resalto','y_M2_resalto');
