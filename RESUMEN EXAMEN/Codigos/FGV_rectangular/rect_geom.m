% rect_geom.m — calcula las propiedades geométricas de una sección
% RECTANGULAR (ancho superficial B=b, área A, perímetro mojado P, radio
% hidráulico R, profundidad del baricentro yG=y/2, profundidad
% hidráulica D) dado el tirante y y el ancho b. Función geométrica base
% para los demás scripts de este directorio (Mom_rect, Eesp_rect,
% froude_rect, manning_rect, fgv_rect, rect.m). Usar cuando: cualquier
% cálculo de canal rectangular (caso particular de trap_geom.m con m=0,
% pero con fórmulas cerradas más simples).
function [B,A,P,R,yG,D]=rect_geom(y,b)
% funci�n que calcula los par�metros geom�tricos de una secci�n rectangular
%
% INPUT
% y tirante (m)
% b ancho del canal (m)
%
% OUTPUT
% B   ancho superficial (m)
% A   �rea (m^3)
% P   per�metro mojado (m)
% R   radio hidr�ulico (m)
% yG  distancia desde la superficie libre al baricentro de la seccion (m)
% D   profundidad hidr�ulica (m)
%
B=b; 
A=b.*y;
P=b+2*y; 
R= A./P;
yG=y/2;
D=A./B;
