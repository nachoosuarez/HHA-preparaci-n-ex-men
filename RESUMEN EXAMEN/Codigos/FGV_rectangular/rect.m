% rect.m — ecuación diferencial dy/dx del FGV para CANAL RECTANGULAR
% (usa rect_geom.m, sin talud). Se pasa como function handle a ode23
% dentro de fgv_rect.m: par=[Q,b,S,n]. Entradas: x (posición, muda), y
% (tirante), par. Salida: dydx = pendiente de la superficie libre.
% OJO: no confundir con el archivo homónimo "rect.m" de la carpeta
% FGV_trapezoidal — ese, pese al nombre, es en realidad la versión
% trapezoidal (usa trap_geom.m con talud m). Requiere rect_geom.m.
function dydx = rect(x,y,par)
% funci�n que estima la pendiente de la superficie libre para el c�lculo
% del tirante en FGV
% INPUT
% x variable muda para pasar la condici�n de parada cuando se llega al
% tirante cr�tico
% y tirante (m)
% par vector de par�metros de entrada
 
%% Descomposici�n del vector de par�metros de entrada
Q = par(1);% caudal (m3/s)
b = par(2);% ancho de fondo (m)
S = par(3);% pendiente de fondo
n = par(4);% n de Manning
 
%% Ecuaci�n de FGV
[B,A,P,R,yG,D]=rect_geom(y,b);% funci�n que calcula par�metros geom�tricos de la secci�n
Fr2=(Q^2)*B/(9.8*(A)^3);% n�mero de Froude al cuadrado
Sf=((Q^2)*(n^2))/((A)^(2)*(R^(4/3)));% pendiente de energ�a
 
dydx = (S-Sf)/(1-Fr2);%dy/dx derivada del tirante
