% froude_circ.m â€” funciÃ³n auxiliar de error (Fr^2 - 1) para un conducto
% CIRCULAR, con vector de parÃ¡metros par=[Q d], pensada para pasarse a
% fzero/fsolve (usada dentro de fgv_circ.m para hallar yc).
function en = froude_circ(y,par)
%% Datos de entrada
Q = par(1);% caudal en m3/s
d = par(2);% diámetro en m

%% Propiedades geométricas
tt=2*acos(1-2*y/d);% angulo al centro rad
B=d*sin(tt/2);% ancho superficial m
A=((tt-sin(tt))*(d^2))/8;% área m2
%R= A/P;% radio hidráulico
%% Función
en=(Q^2)*B./(9.8*A.^3)-1;