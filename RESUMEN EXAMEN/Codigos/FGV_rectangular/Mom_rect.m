% Mom_rect.m — calcula el momento (cantidad de movimiento) M de un canal
% RECTANGULAR para un tirante y dado, y su tirante CONJUGADO yconj de
% forma CERRADA (fórmula analítica del salto hidráulico rectangular,
% no requiere iteración como la versión trapezoidal Mom_trap.m).
% Entradas: y (tirante, m), b (ancho, m), Q (caudal, m3/s). Salidas: M
% (momento, m^3), yconj (tirante conjugado, m). Usar cuando: hay que
% ubicar/verificar un RESALTO HIDRÁULICO en canal rectangular (se
% conserva momento entre los dos tirantes conjugados). Requiere
% rect_geom.m.
function [M,yconj]=Mom_rect(y,b,Q)

% Funci�n que calcula el momento y el tirante conjugado para un canal
% rectangular para un tirante, ancho de canal y caudal dados
%
% INPUTS
% y tirante (m)
% b ancho (m)
% Q caudal (m^3/s)
%
% OUTPUTS
% M     momento (m^3)
% yconj tirante conjugado de y (m)
%
% Calculo del momento
[B,A,P,R,yG,D]=rect_geom(y,b);
M=yG.*A+Q^2./(9.8.*A);    % momento
Fr2=(Q^2)*B./(9.8.*A.^3); % n�mero de Froude al cuadrado
%
% B�squeda del tirante conjugado
yconj=y.*(-1 + sqrt(1 + 8.*Fr2))/2;% Soluci�n para caso rectangular

function eM=conj_rect(y,par)
% Sub-funci�n auxiliar que calcula el error relativo entre el momento dado y el
% momento calculado usando el tirante conjugado estimado, que se buscara
% minimizar.
% INPUTS
% par vector de entrada de par�metros fijos
% y variable de entrada a la funci�n cuyo valor se seleccionara para
% minimizar el error eM. En este caso cuando se llama a esta sub-funci�n dentro de fzero la
% variable de entrada en yconj.
% OUTPUTS
% eM error relativo
%
% descomposici�n del vector de par�metros en las variables originales
Q = par(1);
b = par(2);
M = par(3);
%
[B,A,P,R,yG,D]=rect_geom(y,b);
eM=M/(yG.*A+Q^2./(9.8*A))-1;% error relativo entre el valor del momento dado y 
% el calculado con el valor de la variable de entrada y.

% Funciones en el mismo directorio
% rect_geom