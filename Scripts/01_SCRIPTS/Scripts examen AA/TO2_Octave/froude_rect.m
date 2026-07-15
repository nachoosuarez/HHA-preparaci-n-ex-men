function ec = froude_rect(y,par)
% Función auxiliar que calcula la diferencia entre 1 y el número de Froude
% calculado con el tirante.
% INPUTS
% par vector de parámetros de entrada
% y tirante de entrada con el que calculará el Froude
% OUTPUTS
% ec apartamiento del Froude respecto a 1
 
%% Descomposición del vector de parámetros de entrada
Q = par(1);% caudal (m3/s)
b = par(2);% ancho de fondo (m)
 
%% Función
[B,A,P,R,yG,D]=rect_geom(y,b);% función que calcula parámetros geométricos de la sección
ec=(Q^2)*B./(9.8*A.^3)-1;% diferencia entre el Froude estimado con y que tiende al yc con 1

