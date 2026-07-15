function [M,yconj]=Mom_trap(y,b,Q,m)

%IMPORTANTE:
% Matlab cambió como maneja las funciones anidadas entre la version 6.1 que hay 
% en las salas de computadoras de facultad y las versiones mas nuevas.
% El código que sigue contempla la sintaxix nueva de Matlab que es la que 
% también usa Octave.

% Función que calcula el momento y el tirante conjugado para un canal
% trapezoidal para un tirante, ancho de canal, caudal y m dados
% INPUTS
% y tirante (m)
% b ancho (m)
% Q caudal (m^3/s)
% m proyeccion horizontal de la pendiente cuando se considera una altura de unidad (m)
% OUTPUTS
% M momento (m^3)
% yconj tirante conjugado de y (m)
%
%% Calculo del momento
[B,A,P,R,yG,D]=trap_geom(y,b,m);% función que calcula parámetros geométricos de 
% la sección (algunos de los cuales no son usados en esta función), debe estar 
% en el mismo directorio.
M=yG.*A+Q^2./(9.8.*A);% momento (por definicion)
Fr2=(Q^2)*B./(9.8.*A.^3);% número de Froude al cuadrado
%
%% Búsqueda del tirante conjugado
yconj=y.*(-1 + sqrt(1 + 8.*Fr2))/2;% % Solución para caso rectangular que se 
% puede usar para el caso trapezoidal como primera estimación del tirante 
% conjugado para iniciar iteración

% NOTA: para el caso rectangular las siguientes dos líneas de código no son 
% necesarias. Se incluyen como ayuda para la Tarea.
par=[Q,b,M];% armado de vector de parámetros que permite pasar los valores 
% de Q, b y M dentro de la función que busca el tirante conjugado

% Busqueda del cero de la función, descoemntar y comentar segús se trabaje en 
% Matlab o en Octave:
% En Matlab:
% yconj=fzero(@(y) conj_rect(y,par), yconj);% función de Matlab que busca el 
% cero de la función conj_rect. Ver help de Matlab para fzero.
% En Octave:
yconj=fsolve(@(y) conj_rect(y,par,m), yconj);% función de Octave que busca el 
% cero de la función conj_rect. Ver help de Octave para fsolve.

function eM=conj_rect(y,par,m)
% Sub-función auxiliar que calcula el error relativo entre el momento dado y el
% momento calculado usando el tirante conjugado estimado, que se buscara
% minimizar.
% INPUTS
% par vector de entrada de parámetros fijos
% y variable de entrada a la función cuyo valor se seleccionara para
% minimizar el error eM. En este caso cuando se llama a esta sub-función dentro 
% de fzero la variable de entrada en yconj.
% OUTPUTS
% eM error relativo
%
% descomposición del vector de parámetros en las variables originales
Q = par(1);
b = par(2);
M = par(3);
%
[B,A,P,R,yG,D]=trap_geom(y,b,m);% función que calcula parámetros geométricos de 
% la sección (algunos de los cuales no son usados en esta sub-función), 
% debe estar en el mismo directorio.
eM=M/(yG.*A+Q^2./(9.8*A))-1;% error relativo entre el valor del momento dado y 
% el calculado con el valor de la variable de entrada y.
