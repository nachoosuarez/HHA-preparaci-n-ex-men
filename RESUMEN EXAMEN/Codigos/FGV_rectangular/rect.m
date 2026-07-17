% rect.m â€” ecuaciÃ³n diferencial dy/dx del FGV para CANAL RECTANGULAR
% (usa rect_geom.m, sin talud). Se pasa como function handle a ode23
% dentro de fgv_rect.m: par=[Q,b,S,n]. Entradas: x (posiciÃ³n, muda), y
% (tirante), par. Salida: dydx = pendiente de la superficie libre.
% OJO: no confundir con el archivo homÃ³nimo "rect.m" de la carpeta
% FGV_trapezoidal â€” ese, pese al nombre, es en realidad la versiÃ³n
% trapezoidal (usa trap_geom.m con talud m). Requiere rect_geom.m.
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
 
%% Ecuación de FGV
[B,A,P,R,yG,D]=rect_geom(y,b);% función que calcula parámetros geométricos de la sección
Fr2=(Q^2)*B/(9.8*(A)^3);% número de Froude al cuadrado
Sf=((Q^2)*(n^2))/((A)^(2)*(R^(4/3)));% pendiente de energía
 
dydx = (S-Sf)/(1-Fr2);%dy/dx derivada del tirante
