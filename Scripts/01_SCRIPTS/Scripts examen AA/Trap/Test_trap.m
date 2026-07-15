% Script que dados un tirante (y), un ancho de canal rectangular (b) y un
% caudal (Q) calcula el momento y la energía especifica asociada a ese
% tirante y los tirante conjugados y alternos, en el sistema mks de unidades.
y=1.81;% tirante (m)
b=3;% ancho (m)
Q=4.85;% caudal (m^3/s)
m=2;% pendiente lateral
[M,yconj]=Mom_trap(y,b,Q,m)% momento (m^3), tirante conjugado de y (m)
[E,yalt]=Eesp_trap(y,b,Q,m)% Energia especifica (m), tirante alterno de y (m)
