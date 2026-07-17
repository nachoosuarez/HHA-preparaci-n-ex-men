% trap_geom.m — calcula las propiedades geométricas de una sección
% trapezoidal (ancho superficial B, área A, perímetro mojado P, radio
% hidráulico R, profundidad del baricentro yG, profundidad hidráulica D)
% dado el tirante y, el ancho de fondo b y el talud lateral m (1V:mH).
% Es la función geométrica base que usan casi todos los demás scripts
% de este directorio (Mom_trap, Eesp_trap, froude_trap, manning_trap,
% fgv_trap, encontrar_resalto, etc.) — debe estar siempre en el mismo
% directorio que ellos. Usar cuando: cualquier cálculo de canal
% trapezoidal (con m=0 equivale a un canal rectangular).
function [B,A,P,R,yG,D]=trap_geom(y,b,m)
% funci�n que calcula los par�metros geom�tricos de una secci�n trapezoidal
% INPUT
% y tirante (m)
% b ancho del canal (m)
% m proyeccion horizontal de la pendiente cuando se considera una altura de unidad(m)
% OUTPUT
% B ancho superficial (m)
% A �rea (m^3)
% P per�metro mojado (m)
% R radio hidr�ulico (m)
% yG distancia desde la superficie libre al baricentro de la seccion (m)
% D profundidad hidr�ulica (m)
%
B=b+2*y.*m; 
% Parto de b y avanzo una distancia a ambos lados igual a ym 
A=(b+B)*y/2;
% Formula de area de trapecio como de base mayor mas menor por la altura dividido dos
P=b+2*sqrt((y^2)+((m.*y)^2)); 
% Describir el perimetro mojado como la base y los taludes laterales con pitagoras
R= A./P;
% Definici�n de redio hidr�ulico
yG=(y/3)*((B+2*b)/(B+b));
% Posicion del CM de un trapecio buscada en tabla
D=A./B;
%Definicion de profundidad hidraulica
