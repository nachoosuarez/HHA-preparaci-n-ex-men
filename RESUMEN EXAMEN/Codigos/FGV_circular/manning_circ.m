% manning_circ.m â€” funciÃ³n auxiliar de error (Q_Manning(y) - Q) para un
% conducto CIRCULAR parcialmente lleno, con vector de parÃ¡metros
% par=[Q d S n], pensada para pasarse a fzero/fsolve (usada dentro de
% fgv_circ.m para hallar el/los tirante(s) normal(es); en circular
% pueden existir DOS tirantes normales para el mismo caudal cuando
% y>0.82d aprox., ver fgv_circ.m). Requiere circ_geom.m (embebido
% inline, no lo llama por nombre pero replica su cÃ¡lculo).
function en = manning_circ(y,par)
%% Datos de entrada
Q = par(1);% caudal en m3/s
d = par(2);% diámetro en m
S = par(3);% pendiente de fondo
n = par(4);% n de Manning

%% Propiedades geométricas
tt=2*acos(1-2*y/d);% angulo al centro rad

A=((tt-sin(tt))*(d^2))/8;% área m2
P=tt*d/2; % perimetro mojado m
R= A./P;% radio hidráulico
%% Función
en=1/n*R.^(2/3).*A*S.^0.5 - Q;
