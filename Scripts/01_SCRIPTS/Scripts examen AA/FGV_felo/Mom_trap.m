function [M,yconj]=Mom_trap(y,b,m,Q)

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
[B,A,P,R,yG,D]=trap_geom(y,b,m); % función que calcula parámetros geométricos de 
% la sección (algunos de los cuales no son usados en esta función), debe estar 
% en el mismo directorio.

g = 9.81;
M = yG.*A + Q^2./(g.*A); % momento (por definicion)
Fr2 = (Q^2)*B./(g.*A.^3); % número de Froude al cuadrado

%
%% Búsqueda del tirante conjugado
% Estimación inicial: fórmula rectangular (sirve como aproximación)
yconj = y.*(-1 + sqrt(1 + 8.*Fr2))/2;

% Para trapezoidal conviene arrancar con un valor mayor (rama subcrítica)
if yconj <= y
    yconj = y * 3;   % estimación inicial más robusta
end

% NOTA: para el caso rectangular las siguientes dos líneas de código no son 
% necesarias. Se incluyen como ayuda para la Tarea.
par=[Q,b,M]; % armado de vector de parámetros que permite pasar los valores 
% de Q, b y M dentro de la función que busca el tirante conjugado

% Busqueda del cero de la función, descomentar y comentar según se trabaje en 
% Matlab o en Octave:
% En Matlab:
% yconj=fzero(@(y) conj_rect(y,par), yconj); % función de Matlab que busca el 
% cero de la función conj_rect. Ver help de Matlab para fzero.
% En Octave:
yconj=fsolve(@(yc) conj_rect(yc,par,m), yconj); % función de Octave que busca el 
% cero de la función conj_rect. Ver help de Octave para fsolve.

% --- NUEVO: verificación de que la solución sea subcrítica ---
[Bc,Ac,Pc,Rc,yGc,Dc] = trap_geom(yconj,b,m);
Uc = Q/Ac;
Fr = Uc / sqrt(g*Dc);

if Fr >= 1 || yconj <= y
    % Si no es subcrítico, no es un conjugado válido
    yconj = NaN;
end

end % fin de Mom_trap


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

[B,A,P,R,yG,D]=trap_geom(y,b,m); % función que calcula parámetros geométricos de 
% la sección (algunos de los cuales no son usados en esta sub-función), 
% debe estar en el mismo directorio.

eM = M/(yG.*A + Q^2./(9.8*A)) - 1; % error relativo entre el valor del momento dado y 
% el calculado con el valor de la variable de entrada y.

end % fin de conj_rect
