% froude_trap.m — función auxiliar de error (Fr^2 - 1) con vector de
% parámetros par=[Q b m], pensada para pasarse como function handle a
% fsolve/fzero (p.ej. dentro de fgv_trap.m para hallar yc). Equivalente
% "estilo par" de eq_yc.m. Requiere trap_geom.m.
function ec = froude_trap(y,par)
% Funci�n auxiliar que calcula la diferencia entre 1 y el n�mero de Froude
% calculado con el tirante.
% INPUTS
% par vector de par�metros de entrada
% y tirante de entrada con el que calcular� el Froude
% OUTPUTS
% ec apartamiento del Froude respecto a 1
 
%% Descomposici�n del vector de par�metros de entrada
Q = par(1);% caudal (m3/s)
b = par(2);% ancho de fondo (m)
m = par(3);% pendiente taludes laterales 1V:mH
 
%% Funci�n
[B,A,P,R,yG,D]=trap_geom(y,b,m);% funci�n que calcula par�metros geom�tricos de la secci�n
ec=(Q^2)*B./(9.8*A.^3)-1;% diferencia entre el Froude estimado con y que tiende al yc con 1

