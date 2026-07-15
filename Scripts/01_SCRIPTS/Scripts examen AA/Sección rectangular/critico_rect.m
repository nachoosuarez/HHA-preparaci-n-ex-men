function yc = critico_rect(b,Q)

% Funcion que calcula el tirante critico de una seccion rectangular, para un 
% caudal y tirante dados
%
% INPUTS
% b ancho de la base (m)
% Q caudal (m^3/s)
%
% OUTPUTS
% yc tirante critico (m)
%
% CALCULO DEL TIRANTE
yc=(Q^2/(9.8*b^2))^(1/3);