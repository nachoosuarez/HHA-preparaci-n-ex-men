function [tt,B,A,P,R,yG,D]=circ_geom(y,d)

%% Propiedades geométricas
tt=2*acos(1-2*y/d);% angulo al centro rad

B=d*sin(tt/2);% ancho superficial m
A=((tt-sin(tt))*(d^2))/8;% área m2
P=tt*d/2; % perimetro mojado m
R= A./P;% radio hidráulico
yG= 4*d*(sin(tt/2)).^3/6./(tt-sin(tt)) - d/2*cos(tt/2); %profundidad del baricentro de la sección desde la superfice libre m
D=A./B;% profundidad hidráulica m
