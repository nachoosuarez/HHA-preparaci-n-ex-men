% Script que dados un tirante (y), un ancho de canal rectangular (b) y un
% caudal (Q) calcula el momento y la energía especifica asociada a ese
% tirante y los tirante conjugados y alternos, en el sistema mks de unidades.
y=2;% tirante (m)
b=5;% ancho (m)
Q=15;% caudal (m^3/s)
[M,yconj]=Mom_rect(y,b,Q)% momento (m^3), tirante conjugado de y (m)
[E,yalt]=Eesp_rect(y,b,Q)% Energia especifica (m), tirante alterno de y (m)
