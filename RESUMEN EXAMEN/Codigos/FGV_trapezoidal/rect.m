% rect.m â€” OJO CON EL NOMBRE: a pesar de llamarse "rect", esta funciÃ³n
% es la ecuaciÃ³n diferencial dy/dx del FGV para CANAL TRAPEZOIDAL (usa
% trap_geom.m con el talud m=par(6)); quedÃ³ con ese nombre porque se
% adaptÃ³ de la versiÃ³n rectangular original. NO confundir con el
% rect.m real de la carpeta FGV_rectangular (ese sÃ­ es para secciÃ³n
% rectangular). Se pasa como function handle a ode23 dentro de
% fgv_trap.m y encontrar_resalto.m: par=[Q,b,S,n,yc,m].
% Entradas: x (posiciÃ³n, muda), y (tirante), par=[Q,b,S,n,yc,m].
% Salida: dydx = pendiente de la superficie libre. Requiere trap_geom.m.
function dydx = rect(x,y,par)
% función que estima la pendiente de la superficie libre para el cálculo
% del tirante en FGV
% INPUT
% x variable muda para pasar la condición de parada cuando se llega al
% tirante crítico
% y tirante (m)
% par vector de parámetros de entrada
 
%% Descomposición del vector de parámetros de entrada
Q = par(1);% caudal (m3/s)
b = par(2);% ancho de fondo (m)
S = par(3);% pendiente de fondo
n = par(4);% n de Manning
m = par(6);% pendiente taludes laterales 1V:mH
 
%% Ecuación de FGV
[B,A,P,R,yG,D]=trap_geom(y,b,m);% función que calcula parámetros geométricos de la sección
Fr2=(Q^2)*B/(9.8*(A)^3);% número de Froude al cuadrado
Sf=((Q^2)*(n^2))/((A)^(2)*(R^(4/3)));% pendiente de energía
 
dydx = (S-Sf)/(1-Fr2);%dy/dx derivada del tirante
