function [M,yconj]=Mom_trap(y,b,Q,m)
    
% Función que calcula el momento y el tirante conjugado para un canal
% rectangular para un tirante, ancho de canal, caudal y pendiente de talud dados
%
% INPUTS
% y tirante (m)
% b ancho (m)
% Q caudal (m^3/s)
% m inverso de la pendiente taludes de la seccion 1V:mH
%
% OUTPUTS
% M     momento (m^3)
% yconj tirante conjugado de y (m)
%
% Calculo del momento
[B,A,P,R,yG,D]=trap_geom(y,b,m);
M=yG.*A+Q^2./(9.8.*A);    % momento
Fr2=(Q^2)*B./(9.8.*A.^3); % número de Froude al cuadrado
%
% Búsqueda del tirante conjugado
yconj=y.*(-1 + sqrt(1 + 8.*Fr2))/2;% Sol. para caso rect. que se puede usar para 
% el caso trapezoidal como primera estimación del tirante conjugado para iniciar iteración

par=[Q,b,M];% armado de vector de parámetros que permite pasar los valores de 
% Q, b y M dentro de la función que busca el tirante conjugado

% Busqueda del cero de la función, descomentar y comentar según herramienta:
% En Matlab:
% yconj=fzero(@(y) conj_trap(y,par,m), yconj);% función que busca el cero de la función conj_rect
% En Octave:
yconj=fsolve(@(y) conj_trap(y,par,m), yconj);% función que busca el cero de la función conj_rect

function eM=conj_trap(y,par,m)
% Sub-función auxiliar que calcula el error relativo entre el momento dado y el
% momento calculado usando el tirante conjugado estimado, que se buscara
% minimizar.
% INPUTS
% par vector de entrada de parámetros fijos
% y   variable de entrada a la función cuyo valor se seleccionara para
% minimizar el error eM. En este caso cuando se llama a esta sub-función dentro de fzero la
% variable de entrada en yconj.
% OUTPUTS
% eM error relativo
%
% descomposición del vector de parámetros en las variables originales
Q = par(1);
b = par(2);
M = par(3);
%
[B,A,P,R,yG,D]=trap_geom(y,b,m); 
eM=M/(yG.*A+Q^2./(9.8*A))-1;% error relativo entre el valor del momento dado y el calculado con el valor de la variable de entrada y.

% Funciones en el mismo directorio
% trap_geom