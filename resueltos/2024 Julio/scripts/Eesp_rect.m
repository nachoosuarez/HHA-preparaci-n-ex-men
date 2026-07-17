function [E,yalt]=Eesp_rect(y,b,Q)

%  Función que calcula la energía especifica y el tirante alterno para un canal
% rectangular para un tirante, ancho de canal y caudal dados
%
% INPUTS
% y tirante (m)
% b ancho (m)
% Q caudal (m^3/s)
%
% OUTPUTS
% Energía especifica (m)
% yalt tirante alterno de y (m)
%
% Calculo de la energía especifica
[B,A,P,R,yG,D]=rect_geom(y,b);
U=Q./A;% velocidad media
E=y+U.^2/(2*9.8);% energía especifica
Fr2=(Q^2)*B./(9.8.*A.^3);% número de Froude al cuadrado
%
% Busqueda del tiernte alterno
yalt=y./(-1 + sqrt(1 + 8./Fr2))*2;% Sol. para caso rectangular

function eE=alt_rect(y,par)
% Función auxiliar que calcula el error relativo entre la energía
% especifica dada y la energía especifica calculada usando el tirante alterno estimado, que se buscara
% minimizar.
% INPUTS
% par vector de parámetros de entrada
% y variable de entrada a la función cuyo valor se seleccionara para minimizar el error eE
% OUTPUTS
% eE error relativo
%
% descomposición del vector de parámetros en las variables originales
Q = par(1);
b = par(2);
E = par(3);

[B,A,P,R,yG,D]=rect_geom(y,b);% función que calcula parámetros geométricos de la 
% sección (algunos de los cuales no son usados en esta sub-función), debe estar en el mismo directorio.
U=Q/A;% velocidad media
eE=E/(y+U^2/(2*9.8))-1;% error relativo entre el valor de la energía especifica 
% dada y la calculada con el valor de la variable de entrada y.
