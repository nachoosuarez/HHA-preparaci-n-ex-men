% circ_geom.m — calcula las propiedades geométricas de una sección
% CIRCULAR parcialmente llena (ángulo al centro tt, ancho superficial B,
% área A, perímetro mojado P, radio hidráulico R, profundidad del
% baricentro yG, profundidad hidráulica D) dado el tirante y y el
% diámetro d. Función geométrica base para los demás scripts de este
% directorio (manning_circ, circ, froude_circ, fgv_circ). Usar cuando:
% cualquier cálculo de conducto/canal circular (alcantarillas, caños que
% trabajan parcialmente llenos, tipo cloaca pluvial).
function [tt,B,A,P,R,yG,D]=circ_geom(y,d)

%% Propiedades geom�tricas
tt=2*acos(1-2*y/d);% angulo al centro rad

B=d*sin(tt/2);% ancho superficial m
A=((tt-sin(tt))*(d^2))/8;% �rea m2
P=tt*d/2; % perimetro mojado m
R= A./P;% radio hidr�ulico
yG= 4*d*(sin(tt/2)).^3/6./(tt-sin(tt)) - d/2*cos(tt/2); %profundidad del baricentro de la secci�n desde la superfice libre m
D=A./B;% profundidad hidr�ulica m
