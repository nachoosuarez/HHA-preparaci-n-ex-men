function [E,yalt]=Eesp_trap(y,b,Q,m)
%IMPORTANTE:
% Matlab cambió como maneja las funciones anidadas entre la version 6.1 que hay 
% en las salas de computadoras de facultad y las versiones mas nuevas.
% El código que sigue contempla la sintaxix nueva de Matlab que es la que también 
% usa Octave.

% Función que calcula la energía especifica y el tirante alterno para un canal
% trapezoidal para un tirante, ancho de canal y caudal dados
% INPUTS
% y tirante (m)
% b ancho (m)
% Q caudal (m^3/s)
% m proyección horizontal de la pendiente cuando se considera una altura de 
% unidad (m)
% OUTPUTS
% Energía especifica (m)
% yalt tirante alterno de y (m)
%
%% Calculo de la energía especifica
[B,A,P,R,yG,D]=trap_geom(y,b,m);% función que calcula parámetros geométricos de 
% la sección (algunos de los cuales no son usados en esta función), debe estar 
% en el mismo directorio.
U=Q./A; % velocidad media (es como se define)
E=y+U.^2/(2*9.8); % energía especifica (es como se define)
Fr2=(Q^2)*B./(9.8.*A.^3);% número de Froude al cuadrado (es como se define)
%
%% Busqueda del tiernte alterno
yalt=y./(-1 + sqrt(1 + 8./Fr2))*2;% Solución para caso rectangular que se puede 
% usar para el caso trapezoidal como primera estimación del tirante alterno para 
% iniciar iteración

% NOTA: para el caso rectangular las siguientes  dos líneas de código no son 
% necesarias. Se incluyen como ayuda para la Tarea.
par=[Q,b,E];% para el caso trapezoidal: armado de vector de parámetros que 
% permite pasar los valores de Q, b y E dentro de la función que busca el 
% tirante alterno

% Busqueda del cero de la función, descoemntar y comentar segús se trabaje en 
% Matlab o en Octave:
% En Matlab:
% yalt=fzero(@(y) alt_rect(y,par), yalt);% para el caso trapezoidal: función de 
% Matlab que busca el cero de la función alt_rect. Ver help de Matlab para fzero.
% En Octave:
yalt=fsolve(@(y) alt_rect(y,par,m), yalt);% para el caso trapezoidal: función de 
% Octave que busca el cero de la función alt_rect. Ver help de Octave para fsolve.


function eE=alt_rect(y,par,m)
% Función auxiliar que calcula el error relativo entre la energía
% especifica dada y la energía especifica calculada usando el tirante alterno 
% estimado, que se buscara minimizar.
% INPUTS
% parámetros de entrada
% y variable de entrada a la función cuyo valor se seleccionara para 
% minimizar el error eE
% OUTPUTS
% eE error relativo
%
% descomposición del vector de parámetros en las variables originales
Q = par(1);
b = par(2);
E = par(3);

[B,A,P,R,yG,D]=trap_geom(y,b,m);% función que calcula parámetros geométricos de 
% la sección (algunos de los cuales no son usados en esta sub-función), 
% debe estar en el mismo directorio.
U=Q/A;% velocidad media
eE=E/(y+U^2/(2*9.8))-1;% error relativo entre el valor de la energía especifica 
% dada y la calculada con el valor de la variable de entrada y.
