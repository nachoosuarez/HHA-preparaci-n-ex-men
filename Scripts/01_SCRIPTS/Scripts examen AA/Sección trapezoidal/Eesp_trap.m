function [E,yalt]=Eesp_trap(y,b,Q,m)

%  Función que calcula la energía especifica y el tirante alterno para un canal
% trapezoidal para un tirante, ancho de canal, caudal y pendiente de los taludes 
% dados.
%
% INPUTS
% y tirante (m)
% b ancho (m)
% Q caudal (m^3/s)
% m inverso de la pendiente taludes de la seccion 1V:mH
%
% OUTPUTS
% E     energía especifica (m)
% yalt  tirante alterno de y (m)
%
% Calculo de la energía especifica
[B,A,P,R,yG,D]=trap_geom(y,b,m);% función que calcula parám. geom.de la sección
U=Q./A;% velocidad media
E=y+U.^2/(2*9.8);% energía especifica
Fr2=(Q^2)*B./(9.8.*A.^3);% número de Froude al cuadrado
%
% Busqueda del tiernte alterno
yalt=y./(-1 + sqrt(1 + 8./Fr2))*2;% Solución para caso rectangular que se puede 
% usar para el caso trap. como primera estimación del yalt para iniciar iteración

par=[Q,b,E];% armado de vector de parámetros que permite pasar los valores de 
% Q, b y E dentro de la función que busca el tirante alterno

% Busqueda del cero de la función (descomentar y comentar según herramienta)
% En Matlab:
% yalt=fzero(@(y) alt_trap(y,par), yalt);% función que busca el cero de la función alt_trap
% En Octave:
yalt=fsolve(@(y) alt_trap(y,par,m), yalt);% función que busca el cero de la función alt_trap


function eE=alt_trap(y,par,m)
% Función auxiliar que calcula el error relativo entre la energía especifica 
% dada y la energía especifica calculada usando el tirante alterno estimado, 
% que se buscara minimizar.
%
% INPUTS
% par vector de parámetros de entrada
% y variable de entrada a la función cuyo valor se seleccionara para minimizar el error eE
%
% OUTPUTS
% eE error relativo
%
% descomposición del vector de parámetros en las variables originales
Q = par(1);
b = par(2);
E = par(3);

[B,A,P,R,yG,D]=trap_geom(y,b,m);% función que calcula parámetros geom. de la sec.
U=Q/A;% velocidad media
eE=E/(y+U^2/(2*9.8))-1;% error relativo entre el valor de la energía especifica 
% dada y la calculada con el valor de la variable de entrada y.

% Funciones que deben estar en el mismo directorio:
% trap_geom
