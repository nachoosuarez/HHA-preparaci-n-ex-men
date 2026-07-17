% rect.m — OJO CON EL NOMBRE: a pesar de llamarse "rect", esta función
% es la ecuación diferencial dy/dx del FGV para CANAL TRAPEZOIDAL (usa
% trap_geom.m con el talud m=par(6)); quedó con ese nombre porque se
% adaptó de la versión rectangular original. NO confundir con el
% rect.m real de la carpeta FGV_rectangular (ese sí es para sección
% rectangular). Se pasa como function handle a ode23 dentro de
% fgv_trap.m y encontrar_resalto.m: par=[Q b S n yc m].
% Entradas: x (posición, muda), y (tirante), par=[Q,b,S,n,yc,m].
% Salida: dydx = pendiente de la superficie libre. Requiere trap_geom.m.
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
m = par(6);% pendiente taludes laterales 1V:mH
 
%% Ecuaci�n de FGV
[B,A,P,R,yG,D]=trap_geom(y,b,m);% funci�n que calcula par�metros geom�tricos de la secci�n
Fr2=(Q^2)*B/(9.8*(A)^3);% n�mero de Froude al cuadrado
Sf=((Q^2)*(n^2))/((A)^(2)*(R^(4/3)));% pendiente de energ�a
 
dydx = (S-Sf)/(1-Fr2);%dy/dx derivada del tirante
