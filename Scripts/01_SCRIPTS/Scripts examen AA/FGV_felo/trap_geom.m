function [B,A,P,R,yG,D]=trap_geom(y,b,m)
% función que calcula los parámetros geométricos de una sección trapezoidal
% INPUT
% y tirante (m)
% b ancho del canal (m)
% m proyeccion horizontal de la pendiente cuando se considera una altura de unidad(m)
% OUTPUT
% B ancho superficial (m)
% A área (m^3)
% P perímetro mojado (m)
% R radio hidráulico (m)
% yG distancia desde la superficie libre al baricentro de la seccion (m)
% D profundidad hidráulica (m)
%
B=b+2*y.*m; 
% Parto de b y avanzo una distancia a ambos lados igual a ym 
A=(b+B)*y/2;
% Formula de area de trapecio como de base mayor mas menor por la altura dividido dos
P=b+2*sqrt((y^2)+((m.*y)^2)); 
% Describir el perimetro mojado como la base y los taludes laterales con pitagoras
R= A./P;
% Definición de redio hidráulico
yG=(y/3)*((B+2*b)/(B+b));
% Posicion del CM de un trapecio buscada en tabla
D=A./B;
%Definicion de profundidad hidraulica
