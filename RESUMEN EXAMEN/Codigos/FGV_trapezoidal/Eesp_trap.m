% Eesp_trap.m — calcula la energía específica E de un canal trapezoidal
% para un tirante y dado, y busca por iteración (fsolve) su tirante
% ALTERNO yalt (misma E, distinta rama del flujo, sub vs supercrítico).
% Firma: [E,yalt] = Eesp_trap(y,b,Q,m) -- OJO con el orden de argumentos
% (y,b,Q,m), distinto del de Mom_trap.m (y,b,m,Q).
% Entradas: y (tirante, m), b (ancho de fondo, m), Q (caudal, m3/s), m
% (talud 1V:mH). Salidas: E (energía específica, m), yalt (tirante
% alterno). Usar cuando: transición con ENERGÍA CONSTANTE (escalón de
% fondo, contracción/expansión suave, compuerta sin pérdidas) — ver
% también alternos_trap.m. Requiere trap_geom.m.
function [E,yalt]=Eesp_trap(y,b,Q,m)
%IMPORTANTE:
% Matlab cambi� como maneja las funciones anidadas entre la version 6.1 que hay 
% en las salas de computadoras de facultad y las versiones mas nuevas.
% El c�digo que sigue contempla la sintaxix nueva de Matlab que es la que tambi�n 
% usa Octave.

% Funci�n que calcula la energ�a especifica y el tirante alterno para un canal
% trapezoidal para un tirante, ancho de canal y caudal dados
% INPUTS
% y tirante (m)
% b ancho (m)
% Q caudal (m^3/s)
% m proyecci�n horizontal de la pendiente cuando se considera una altura de 
% unidad (m)
% OUTPUTS
% Energ�a especifica (m)
% yalt tirante alterno de y (m)
%
%% Calculo de la energ�a especifica
[B,A,P,R,yG,D]=trap_geom(y,b,m);% funci�n que calcula par�metros geom�tricos de 
% la secci�n (algunos de los cuales no son usados en esta funci�n), debe estar 
% en el mismo directorio.
U=Q./A; % velocidad media (es como se define)
E=y+U.^2/(2*9.8); % energ�a especifica (es como se define)
Fr2=(Q^2)*B./(9.8.*A.^3);% n�mero de Froude al cuadrado (es como se define)
%
%% Busqueda del tiernte alterno
yalt=y./(-1 + sqrt(1 + 8./Fr2))*2;% Soluci�n para caso rectangular que se puede 
% usar para el caso trapezoidal como primera estimaci�n del tirante alterno para 
% iniciar iteraci�n

% NOTA: para el caso rectangular las siguientes  dos l�neas de c�digo no son 
% necesarias. Se incluyen como ayuda para la Tarea.
par=[Q,b,E];% para el caso trapezoidal: armado de vector de par�metros que 
% permite pasar los valores de Q, b y E dentro de la funci�n que busca el 
% tirante alterno

% Busqueda del cero de la funci�n, descoemntar y comentar seg�s se trabaje en 
% Matlab o en Octave:
% En Matlab:
% yalt=fzero(@(y) alt_rect(y,par), yalt);% para el caso trapezoidal: funci�n de 
% Matlab que busca el cero de la funci�n alt_rect. Ver help de Matlab para fzero.
% En Octave:
yalt=fsolve(@(y) alt_rect(y,par,m), yalt);% para el caso trapezoidal: funci�n de 
% Octave que busca el cero de la funci�n alt_rect. Ver help de Octave para fsolve.


function eE=alt_rect(y,par,m)
% Funci�n auxiliar que calcula el error relativo entre la energ�a
% especifica dada y la energ�a especifica calculada usando el tirante alterno 
% estimado, que se buscara minimizar.
% INPUTS
% par�metros de entrada
% y variable de entrada a la funci�n cuyo valor se seleccionara para 
% minimizar el error eE
% OUTPUTS
% eE error relativo
%
% descomposici�n del vector de par�metros en las variables originales
Q = par(1);
b = par(2);
E = par(3);

[B,A,P,R,yG,D]=trap_geom(y,b,m);% funci�n que calcula par�metros geom�tricos de 
% la secci�n (algunos de los cuales no son usados en esta sub-funci�n), 
% debe estar en el mismo directorio.
U=Q/A;% velocidad media
eE=E/(y+U^2/(2*9.8))-1;% error relativo entre el valor de la energ�a especifica 
% dada y la calculada con el valor de la variable de entrada y.
