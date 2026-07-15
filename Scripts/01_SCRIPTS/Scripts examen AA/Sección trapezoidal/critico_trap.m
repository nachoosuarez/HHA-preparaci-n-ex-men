function yc = critico_trap(b,Q,m)

% Funcion que calcula el tirante critico de una seccion trapezoidal, para un 
% caudal y tirante dados.
%
% INPUTS
% b ancho de la base (m)
% Q caudal (m^3/s)
% m inverso de la pendiente de los taludes (1V:mH)
b=5
Q=15
m=2
%
% OUTPUTS
% yc tirante critico (m)
%
% CALCULO DEL TIRANTE
yc=(Q^2/(9.8*b^2))^(1/3);% estimación inicial suponiendo canal rectangular 
par=[Q b];% vector con parámetros
yc=fsolve(@(y) froude_trap(y,par,m), yc);% tirante critico(m)
[Bc,Ac,Pc,Rc,yGc,Dc]=trap_geom(yc,b,m);% cálculo de parámetros geométricos 
% asociados a las condiciones de flujo crítico
Uc=Q/Ac;% velocidad en flujo crítico (m/s)
Ec=yc+Uc^2/(2*9.8);% energía específica en flujo crítico(m)