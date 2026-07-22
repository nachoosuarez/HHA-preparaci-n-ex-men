% Ejercicio1_lago_compuerta_caidalibre.m — HHA 2018 diciembre, Ejercicio 1.
% Canal RECTANGULAR (b=2m, n=0.01) que sale de un lago (cota sup.=3.8m,
% cota fondo en el arranque=2.2m) y termina en caída libre 1500 m aguas
% abajo (cota fondo=1m). Parte 1) resuelve Q sin obstáculos (A4: canal M
% "largo", y(0)≈yn). Parte 2) inserta una compuerta de fondo ideal
% (abertura a=0.35m) a 1000m del lago (500m antes de la caída libre) y
% resuelve el nuevo Q por SHOOTING: como el remanso de la compuerta no
% se relaja a yn en los 1000m upstream, hay que iterar Q hasta que la
% energía específica en x=0 (integrando la EDO de FGV hacia atrás desde
% la compuerta) cierre con la energía del lago. Parte 3) fuerza sobre la
% compuerta (Mom_rect) y potencia disipada en el resalto aguas abajo.
% Ver "RESUMEN_TEORICO.md" secciones A4/A5 (caso "Compuerta INTERIOR
% entre un lago a distancia finita y una caída libre").
% Requiere en la misma carpeta: rect_geom.m, rect.m, critico.m,
% manning_rect.m, critico_rect.m, Eesp_rect.m, Mom_rect.m, froude_rect.m
clear all
g = 9.8; gamma = 9800;

%% Datos de entrada
b  = 2;               % ancho del canal (m)
n  = 0.01;             % n de Manning
L  = 1500;             % longitud total del canal (m)
S  = (2.2-1)/L;         % pendiente de fondo (cota fondo lago - cota fondo caida libre)/L
hL = 3.8-2.2;           % carga del lago sobre el fondo del canal en el arranque (m)

printf('--- Datos ---\nS0=%.6f  hL=%.3f m\n\n', S, hL);

%% ==================== PARTE 1: sin compuerta ====================
% Canal M "largo": y(x=0) ~= yn(Q). Sistema 2x2 (Q,yn): E(yn)=hL y Manning.
function e = eqQ_sin_compuerta(Q,b,n,S,hL)
  par=[Q b S n];
  yn0=(Q*n/(b*S^0.5))^(3/5);
  yn=fsolve(@(y) manning_rect(y,par), yn0);
  [B,A,P,R,yG,D]=rect_geom(yn,b);
  U=Q/A;
  e = (yn+U^2/(2*9.8)) - hL;
end
Q1 = fzero(@(Q) eqQ_sin_compuerta(Q,b,n,S,hL), 5.5);
yn1_ = fsolve(@(y) manning_rect(y,[Q1 b S n]), (Q1*n/(b*S^0.5))^(3/5));
yc1_ = critico_rect(b,Q1);
printf('PARTE 1 (sin compuerta): Q=%.3f m3/s  yn=%.3f m  yc=%.3f m  (yn>yc => canal tipo M/suave)\n', Q1, yn1_, yc1_);
printf('  Perfil: M2 decreciente desde ~yn (lago) hasta yc (caida libre), SIN resalto.\n\n');

%% ==================== PARTE 2: con compuerta a x=1000m, a=0.35m ====================
a = 0.35;   % apertura de la compuerta (m)
L1 = 1000;  % distancia lago -> compuerta (m)
L2 = L-L1;  % distancia compuerta -> caida libre (m)

function y_lago = perfil_hasta_lago(Q,b,n,S,a,L1)
  [E_a,y1req] = Eesp_rect(a,b,Q);      % tirante alterno de a (aguas arriba de la compuerta, ideal)
  par=[Q b S n 0];
  [x,y]=ode23(@(x,y) rect(x,y,par),[L1,0],y1req);
  y_lago = y(end);
end
function e = eqQ_con_compuerta(Q,b,n,S,hL,a,L1,g)
  y_lago = perfil_hasta_lago(Q,b,n,S,a,L1);
  e = (y_lago + Q^2/(2*g*(b*y_lago)^2)) - hL;
end

Q2 = fzero(@(Q) eqQ_con_compuerta(Q,b,n,S,hL,a,L1,g), [3.5 5.0]);
[Ea,yA] = Eesp_rect(a,b,Q2);           % yA = tirante inmediatamente aguas arriba de la compuerta
yn2 = fsolve(@(y) manning_rect(y,[Q2 b S n]), (Q2*n/(b*S^0.5))^(3/5));
yc2 = critico_rect(b,Q2);
[Ma,astar] = Mom_rect(a,b,Q2);         % a* = conjugado de la apertura a

printf('PARTE 2 (con compuerta a=%.2fm en x=%dm): Q=%.4f m3/s\n', a, L1, Q2);
printf('  yA (aguas arriba compuerta) = %.3f m   (E(a)=%.3f m)\n', yA, Ea);
printf('  yn(canal,Q2)=%.3f m   yc(canal,Q2)=%.3f m\n', yn2, yc2);
printf('  a*=conjugado(a)=%.3f m  vs yn=%.3f m  -> %s\n\n', astar, yn2, ...
       merge(astar>yn2, 'a*>yn => DESCARGA LIBRE (M3 + resalto aguas abajo)', 'a*<yn => DESCARGA AHOGADA'));

% Ubicacion del resalto en el tramo de salida (libre): M3 desde la compuerta
% (adelante) vs M2 desde la caida libre (atras); cruce del conjugado de M3
% con M2.
par2=[Q2 b S n yc2];
[x3,y3]=ode23(@(x,y) rect(x,y,par2),[L1,L],a);
[x2,y2]=ode23(@(x,y) rect(x,y,par2),[L,L1],yc2+0.001, odeset('Events',@(x,y) critico(x,y,par2)));
xg = linspace(L1,L,4001);
y3i = interp1(x3,y3,xg);
y2i = interp1(x2,y2,xg,'linear','extrap');
conj3 = zeros(size(xg));
for i=1:length(xg)
  [~,yc_] = Mom_rect(y3i(i),b,Q2);
  conj3(i) = yc_;
end
d = conj3 - y2i;
idx = find(d(1:end-1).*d(2:end) < 0, 1);
x_resalto = interp1(d(idx:idx+1), xg(idx:idx+1), 0);
y1_resalto = interp1(xg,y3i,x_resalto);
[Mres,y2_resalto] = Mom_rect(y1_resalto,b,Q2);  % conjugado exacto
printf('  Resalto en x=%.1f m (%.1f m aguas abajo de la compuerta)\n', x_resalto, x_resalto-L1);
printf('  y1(antes)=%.4f m   y2(despues,conjugado)=%.4f m\n\n', y1_resalto, y2_resalto);

%% ==================== PARTE 3: fuerza sobre la compuerta y potencia disipada ====================
[M1,~] = Mom_rect(yA,b,Q2);   % momento aguas arriba (seccion llena, yA)
[M2,~] = Mom_rect(a,b,Q2);    % momento aguas abajo (seccion llena y=a; descarga LIBRE => sin formula hibrida)
F = gamma*(M1-M2);

hj = (y2_resalto-y1_resalto)^3/(4*y1_resalto*y2_resalto);   % perdida de carga en el resalto
P = gamma*Q2*hj;

printf('PARTE 3:\n');
printf('  M1=%.4f m3  M2=%.4f m3\n', M1, M2);
printf('  Fuerza sobre la compuerta F = gamma*(M1-M2) = %.1f N = %.2f kN\n', F, F/1000);
printf('  Perdida de carga en el resalto hj=%.4f m\n', hj);
printf('  Potencia disipada P = gamma*Q*hj = %.1f W = %.3f kW\n', P, P/1000);
