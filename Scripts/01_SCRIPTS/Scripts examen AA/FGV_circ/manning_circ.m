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
