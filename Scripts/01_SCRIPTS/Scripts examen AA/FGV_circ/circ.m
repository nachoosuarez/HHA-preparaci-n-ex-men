function dydx = circ(x,y,par)

%% Datos de entrada
Q = par(1);% caudal en m3/s
d = par(2);% ancho de fondo en m
S = par(3);% pendiente de fondo
n = par(4);% n de Manning

%% Propiedades geométricas
tt=2*acos(1-2*y/d);% angulo al centro rad

B=d*sin(tt/2);% ancho superficial m
A=((tt-sin(tt))*(d^2))/8;% área m2
P=tt*d/2; % perimetro mojado m
R= A./P;% radio hidráulico

%% Función
Fr2=(Q^2)*B/(9.8*(A)^3);% número de Froude al cuadrado
Sf=((Q^2)*(n^2))/((A)^(2)*(R^(4/3)));% pendiente de energía

dydx = (S-Sf)/(1-Fr2);%dy/dx

