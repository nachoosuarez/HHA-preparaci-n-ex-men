% ej1_evento.m — Examen 13/feb/2020, Ejercicio 1, Parte 3.
% Evento extremo: y1alc=2.45m (aguas arriba alcantarilla), hLago=1.25m.
% Itera Q: para cada Q se calcula yn/yc del cauce, se integra la curva
% M2 desde el lago hasta la alcantarilla (x=-200) para ver si el tirante
% ahi supera Halc (Tipo 1) o no (Tipo 2/3), y se resuelve el balance de
% carga de la alcantarilla correspondiente.
clear all
g = 9.8;
b = 3.5; Scauce = 0.0003; ncauce = 0.009; Lcauce = 200;
Balc = 2; Halc = 1.5; nalc = 0.013; Lalc = 20; CD1 = 0.88;
AT = Balc*Halc; Pm = 2*Halc+Balc; Rh = AT/Pm;
hLago = 1.25;
h1 = 2.45 + 0.006; % y1 (dato) + correccion de datum a fondo de salida

function [yn,yc,yalc] = perfil_cauce(Q,b,S,n,L,hLago)
  yc0 = (Q^2/(9.8*b^2))^(1/3);
  yc = fsolve(@(y) froude_rect(y,[Q b]), yc0);
  yn0 = (Q*n/(b*S^0.5))^(3/5);
  yn = fsolve(@(y) manning_rect(y,[Q b S n]), yn0);
  par = [Q b S n yc];
  options = odeset('Events',@(x,y) critico(x,y,par), 'RelTol',1e-10,'AbsTol',1e-12);
  [x,y] = ode45(@(x,y) rect(x,y,par), [0,-L], hLago, options);
  yalc = y(end);
endfunction

for Q = [15 12 10.6 10.9]
  [yn,yc,yalc] = perfil_cauce(Q,b,Scauce,ncauce,Lcauce,hLago);
  printf('Q=%.2f -> yn=%.3f yc=%.3f y(alc,x=-200)=%.3f (Halc=%.2f)\n',Q,yn,yc,yalc,Halc);
end

printf('\n--- Balance alcantarilla, hipotesis Tipo 2 (h3=Halc=D) ---\n');
h3 = Halc;
den = 1 + 2*g*CD1^2*nalc^2*Lalc/Rh^(4/3);
Q2 = CD1*AT*sqrt(2*g*(h1-h3)/den);
printf('h1=%.3f m, h3=%.3f m -> Q (Tipo 2) = %.3f m3/s\n', h1, h3, Q2);
