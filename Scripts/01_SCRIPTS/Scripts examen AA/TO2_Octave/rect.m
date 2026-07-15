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
