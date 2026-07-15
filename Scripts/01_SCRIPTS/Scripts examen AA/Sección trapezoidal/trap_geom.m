function [B,A,P,R,yG,D]=trap_geom(y,b,m)
% función que calcula los parámetros geométricos de una sección trapezoidal
%
% INPUT
% y tirante (m)
% b ancho de la base del canal (m)
% m inverso de la pendiente taludes de la seccion 1V:mH
%
% OUTPUT
% B   ancho superficial (m)
% A   área (m^3)
% P   perímetro mojado (m)
% R   radio hidráulico (m)
% yG  distancia desde la superficie libre al baricentro de la seccion (m)
% D   profundidad hidráulica (m)
%
B=b+2*m*y; 
A=(b+m*y).*y;
P=b+2*y*sqrt(1+m^2); 
R= A./P;
yG=y*(B+2*b)/3/(B+b);
D=A./B;