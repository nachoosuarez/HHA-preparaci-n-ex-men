% ej1_parte1.m -- Examen HHA 7/jul/2020, Ejercicio 1, Parte 1
% Dos lagos (A en x=0, B en x=L) conectados por un canal trapezoidal.
% Se busca Q, se clasifica el canal M/S y se calcula el perfil de la
% superficie libre.
clear all

addpath('.');

%% Datos de entrada
b   = 3;       % ancho de fondo (m)
m   = 2;       % talud lateral 2H:1V
n   = 0.015;   % Manning
S0  = 0.0008;  % pendiente de fondo
L   = 6000;    % longitud del canal (m)
hLA = 1.6;     % nivel Lago A sobre el fondo en x=0 (m)
hLB = 1.8;     % nivel Lago B sobre el fondo en x=L (m)
g   = 9.8;

%% Estimacion inicial asumiendo canal muy largo (y(0)~=yn, tipo M)
v0 = fsolve(@(v) sistema_lago_M(v,b,m,n,S0,hLA), [15;1.2]);
Q0 = v0(1); yn0 = v0(2);
[~,yc0] = tirantes_yn_yc(Q0,n,m,b,S0);
printf('--- Estimacion inicial (canal muy largo) ---\n');
printf('Q0 = %.4f m3/s, yn0 = %.4f m, yc0 = %.4f m\n', Q0, yn0, yc0);

%% Resolucion "exacta": integrar la M1/M2 desde el Lago B (y(L)=hLB)
% hacia aguas arriba y buscar Q tal que E(y(0)) = hLA
function E1 = E1_of_Q(Q,b,m,n,S0,L,hLB,g)
  [yn,yc] = tirantes_yn_yc(Q,n,m,b,S0);
  y2 = hLB; % se asume yL2 > yc (verificado a posteriori)
  par = [Q,b,S0,n,yc,m];
  options = odeset('Events',@(x,y) critico(x,y,par));
  [x,y] = ode23(@(x,yy) rect(x,yy,par),[L,0],y2,options);
  y1 = y(end);
  [~,A1] = trap_geom(y1,b,m);
  E1 = y1 + Q^2/(2*g*A1^2);
end

Q = fzero(@(Q) E1_of_Q(Q,b,m,n,S0,L,hLB,g) - hLA, Q0);
[yn,yc] = tirantes_yn_yc(Q,n,m,b,S0);

printf('\n--- Solucion (integracion completa FGV) ---\n');
printf('Q  = %.4f m3/s\n', Q);
printf('yn = %.4f m\n', yn);
printf('yc = %.4f m\n', yc);
if yn > yc
  printf('yn > yc => CANAL TIPO M (mild)\n');
else
  printf('yn < yc => CANAL TIPO S (steep)\n');
end
printf('hLB (%.2f) vs yn (%.4f): %s\n', hLB, yn, ifelse(hLB>yn,'hLB>yn => curva M1','hLB<=yn => curva M2/otra'));

%% Perfil completo x=0..L (integrando desde B hacia A, y(L)=hLB)
par = [Q,b,S0,n,yc,m];
options = odeset('Events',@(x,y) critico(x,y,par));
[xprof,yprof] = ode23(@(x,yy) rect(x,yy,par),[L,0],hLB,options);
% reordenar de x=0 a x=L
[xprof,idx] = sort(xprof);
yprof = yprof(idx);

y1 = yprof(1);
[~,A1] = trap_geom(y1,b,m);
E1 = y1 + Q^2/(2*g*A1^2);
printf('\nVerificacion: y(x=0) = %.4f m, E(x=0) = %.4f m (debe ser ~hLA=%.2f)\n', y1, E1, hLA);

save('-mat','part1.mat','Q','yn','yc','xprof','yprof','b','m','n','S0','L','hLA','hLB');

function r = ifelse(cond,a,b)
  if cond
    r = a;
  else
    r = b;
  end
end
