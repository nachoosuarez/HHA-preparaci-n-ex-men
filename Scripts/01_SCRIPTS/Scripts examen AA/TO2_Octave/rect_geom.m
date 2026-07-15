function [B,A,P,R,yG,D]=rect_geom(y,b)
% función que calcula los parámetros geométricos de una sección rectangular
% INPUT
% y tirante (m)
% b ancho del canal (m)
% OUTPUT
% B ancho superficial (m)
% A área (m^3)
% P perímetro mojado (m)
% R radio hidráulico (m)
% yG distancia desde la superficie libre al baricentro de la sección (m)
% D profundidad hidráulica (m)
%
B=b; 
A=b.*y;
P=b+2*y; 
R= A./P;
yG=y/2;
D=A./B;
