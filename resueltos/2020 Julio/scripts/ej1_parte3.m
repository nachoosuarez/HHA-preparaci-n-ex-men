% ej1_parte3.m -- Examen HHA 7/jul/2020, Ejercicio 1, Parte 3
% Se construye la caneria con D=0.6 m > Dmax (0.1552 m, Parte 2), por lo
% que el flujo SI se ve afectado: se establece flujo critico sobre la
% caneria (control nuevo, an?logo a un vertedero de cresta ancha,
% Teorico HHA S2.2.5). Se busca el nuevo caudal Q, el perfil completo
% (M1 aguas arriba, M3 aguas abajo) y la posicion del resalto.
clear all
addpath('.');
load('part1.mat'); % Q1=Q parte 1, yn, yc (de la parte 1), xprof, yprof, ...

g = 9.8;
xpipe = 3000;
D = 0.6;

Q1 = Q; % caudal de la Parte 1 (sin caneria), usado solo como referencia
clear Q

%% 1) Hallar el nuevo caudal Q tal que:
%    - en la caneria se establece flujo critico: E_local_hump = Ec(Q)
%    - E_antes_caneria (datum original) = Ec(Q) + D
%    - integrando la M1/M2 desde x=3000 (y=y1, rama subcritica de esa
%      energia) hasta el Lago A (x=0), se cumple E(x=0) = hLA
function res = residuo_Q(Q,b,m,n,S0,xpipe,hLA,g)
  [yn,yc] = tirantes_yn_yc(Q,n,m,b,S0);
  [~,Ac] = trap_geom(yc,b,m);
  Ec = yc + Q^2/(2*g*Ac^2);
  D = 0.6;
  Eantes = Ec + D;
  % rama subcritica de Eantes (y > yc)
  y1 = fsolve(@(y) Eesp_error(y,b,m,Q,Eantes,g), max(1.5*yn,1.2*yc), optimset('Display','off'));
  par = [Q,b,S0,n,yc,m];
  options = odeset('Events',@(x,y) critico(x,y,par));
  [x,y] = ode23(@(xx,yy) rect(xx,yy,par),[xpipe,0],y1,options);
  y0 = y(end);
  [~,A0] = trap_geom(y0,b,m);
  E0 = y0 + Q^2/(2*g*A0^2);
  res = E0 - hLA;
end

function e = Eesp_error(y,b,m,Q,E,g)
  [~,A] = trap_geom(y,b,m);
  e = y + Q^2/(2*g*A^2) - E;
end

Q = fzero(@(Q) residuo_Q(Q,b,m,n,S0,xpipe,hLA,g), Q1);
[yn2,yc2] = tirantes_yn_yc(Q,n,m,b,S0);
[~,Ac2] = trap_geom(yc2,b,m);
Ec2 = yc2 + Q^2/(2*g*Ac2^2);
Eantes = Ec2 + D;
y1 = fsolve(@(y) Eesp_error(y,b,m,Q,Eantes,g), max(1.5*yn2,1.2*yc2), optimset('Display','off'));
y3 = fsolve(@(y) Eesp_error(y,b,m,Q,Eantes,g), 0.5*yc2, optimset('Display','off'));

printf('--- Ejercicio 1, Parte 3 (D=%.2f m > Dmax=0.1552 m => flujo AFECTADO) ---\n', D);
printf('Nuevo caudal Q          = %.4f m3/s  (vs Q_sin_caneria=%.4f m3/s)\n', Q, Q1);
printf('yn = %.4f m , yc = %.4f m\n', yn2, yc2);
printf('Ec (critica, en la caneria) = %.4f m\n', Ec2);
printf('E antes/despues de la caneria (datum original) = Ec+D = %.4f m\n', Eantes);
printf('y1 (inmediat. antes de la caneria, subcritico)  = %.4f m\n', y1);
printf('y3 (inmediat. despues de la caneria, supercrit) = %.4f m\n', y3);

%% 2) Perfil aguas arriba (M1 desde x=3000 con y=y1 hasta x=0)
par = [Q,b,S0,n,yc2,m];
options = odeset('Events',@(x,y) critico(x,y,par));
[xup,yup] = ode23(@(xx,yy) rect(xx,yy,par),[xpipe,0],y1,options);
[xup,idx] = sort(xup); yup = yup(idx);
y0 = yup(1);
[~,A0] = trap_geom(y0,b,m);
E0 = y0 + Q^2/(2*g*A0^2);
printf('\nVerificacion aguas arriba: y(x=0)=%.4f m , E(x=0)=%.4f m (debe ser ~hLA=%.2f)\n', y0, E0, hLA);

%% 3) Perfil aguas abajo (M3 desde x=3000 con y=y3, hacia x=6000)
% OJO: la curva M3 tiene pendiente dy/dx -> infinito al acercarse a yc
% (Fr->1), por lo que se debe usar el mismo evento 'critico' para
% detener la integracion apenas se acerca a yc (fisicamente, ahi debe
% ocurrir el resalto, ver Teorico HHA S2.5.5)
[xdn,ydn] = ode23(@(xx,yy) rect(xx,yy,par),[xpipe,L],y3,options);

%% 4) Perfil que llega desde el Lago B (M1/M2 con y(L)=hLB), para el
%%    nuevo caudal Q
[xB,yB] = ode23(@(xx,yy) rect(xx,yy,par),[L,xpipe],hLB,options);
[xB,idx] = sort(xB); yB = yB(idx);

%% 5) Ubicacion del resalto: se busca x en (xpipe,L) donde el conjugado
%%    de la curva M3 (aguas abajo de la caneria) coincide con la curva
%%    que llega desde el Lago B
function d = diff_resalto(x,xdn,ydn,xB,yB,b,m,Q)
  y_m3 = interp1(xdn,ydn,x);
  [~,yconj] = Mom_trap(y_m3,b,m,Q);
  y_desdeB = interp1(xB,yB,x);
  d = yconj - y_desdeB;
end

x_lo = xpipe + 0.1; x_hi = min(max(xB),max(xdn)) - 0.1;
printf('\nDominio valido de la curva M3 (hasta casi yc): x en [%.1f, %.1f]\n', xpipe, max(xdn));
xs = linspace(x_lo,x_hi,60);
ds = arrayfun(@(x) diff_resalto(x,xdn,ydn,xB,yB,b,m,Q), xs);
signchange = find(sign(ds(1:end-1)) ~= sign(ds(2:end)),1);
if isempty(signchange)
  printf('\nNo se encontro cruce (resalto) en el tramo analizado.\n');
  x_resalto = NaN; y1_resalto = NaN; y2_resalto = NaN;
else
  x_resalto = fzero(@(x) diff_resalto(x,xdn,ydn,xB,yB,b,m,Q), [xs(signchange),xs(signchange+1)]);
  y1_resalto = interp1(xdn,ydn,x_resalto);
  y2_resalto = interp1(xB,yB,x_resalto);
  printf('\n--- Resalto hidraulico ---\n');
  printf('x_resalto = %.1f m  (%.1f m aguas abajo de la caneria)\n', x_resalto, x_resalto-xpipe);
  printf('y1 (antes del resalto, rama M3) = %.4f m\n', y1_resalto);
  printf('y2 (despues del resalto, ~yn)   = %.4f m\n', y2_resalto);
end

save('-mat','part3.mat','Q','yn2','yc2','y1','y3','xup','yup','xdn','ydn','xB','yB','x_resalto','y1_resalto','y2_resalto','D','xpipe');
