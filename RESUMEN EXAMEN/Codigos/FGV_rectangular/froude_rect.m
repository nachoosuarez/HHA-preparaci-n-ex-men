% froude_rect.m — función auxiliar de error (Fr^2 - 1) con vector de
% parámetros par=[Q b], pensada para pasarse como function handle a
% fsolve/fzero (usada dentro de fgv_rect.m para refinar yc). Requiere
% rect_geom.m.
function ec = froude_rect(y,par)
% Funci�n auxiliar que calcula la diferencia entre 1 y el n�mero %de Froude
% calculado con el tirante.
%
% INPUTS
% par vector de par�metros de entrada
% y   tirante de entrada con el que calcular� el Froude
%
% OUTPUTS
% ec apartamiento del Froude respecto a 1
%
% Descomposici�n del vector de par�metros de entrada
Q = par(1);% caudal (m3/s)
b = par(2);% ancho de fondo (m)
%
% Funci�n
[B,A,P,R,yG,D]=rect_geom(y,b);% funci�n que calcula par�metros geom. de la sec.
ec=(Q^2)*B./(9.8*A.^3)-1;% diferencia entre el Froude estimado con y que tiende al yc con 1