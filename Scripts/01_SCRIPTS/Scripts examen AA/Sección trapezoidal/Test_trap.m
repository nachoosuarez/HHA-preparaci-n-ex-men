% Script que dados un tirante (y), un ancho de canal trapezoidal (b), un caudal 
% (Q) y pendiente de los taludes (1/m) calcula el momento y la energia especifica asociada a ese
% tirante y los tirante conjugados y alternos, en el sistema mks de unidades.
y=1;% tirante (m)
b=1;% ancho (m)
Q=5;% caudal (m^3/s)
m=2;% 1/m
[M,yconj]=Mom_trap(y,b,Q,m)% momento (m^3), tirante conjugado de y (m)
[E,yalt]=Eesp_trap(y,b,Q,m)% Energia especifica (m), tirante alterno de y (m)
yc = critico_trap(b,Q,m)