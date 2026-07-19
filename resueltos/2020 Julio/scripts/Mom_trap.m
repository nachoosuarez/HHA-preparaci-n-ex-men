% Mom_trap.m ‚Äî calcula el momento (cantidad de movimiento) M de un canal
% trapezoidal para un tirante y dado, y busca por iteraci√≥n (fsolve) su
% tirante CONJUGADO yconj (mismo M, distinta rama del flujo). Firma:
% [M,yconj] = Mom_trap(y,b,m,Q)  -- OJO con el orden de argumentos
% (y,b,m,Q), distinto del de Eesp_trap.m (y,b,Q,m).
% Entradas: y (tirante, m), b (ancho de fondo, m), m (talud 1V:mH), Q
% (caudal, m3/s). Salidas: M (momento, m^3), yconj (tirante conjugado).
% Usar cuando: hay que ubicar un RESALTO HIDR√ÅULICO (se conserva momento
% entre los dos tirantes conjugados) ‚Äî ver tambi√©n encontrar_resalto.m,
% conjugados_trap.m y descarga_ahogada.m. Requiere trap_geom.m.
function [M,yconj]=Mom_trap(y,b,m,Q)

%IMPORTANTE:
% Matlab cambiÛ como maneja las funciones anidadas entre la version 6.1 que hay 
% en las salas de computadoras de facultad y las versiones mas nuevas.
% El cÛdigo que sigue contempla la sintaxix nueva de Matlab que es la que 
% tambiÈn usa Octave.

% FunciÛn que calcula el momento y el tirante conjugado para un canal
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
[B,A,P,R,yG,D]=trap_geom(y,b,m); % funciÛn que calcula par·metros geomÈtricos de 
% la secciÛn (algunos de los cuales no son usados en esta funciÛn), debe estar 
% en el mismo directorio.

g = 9.81;
M = yG.*A + Q^2./(g.*A); % momento (por definicion)
Fr2 = (Q^2)*B./(g.*A.^3); % n˙mero de Froude al cuadrado

%
%% B˙squeda del tirante conjugado
% EstimaciÛn inicial: fÛrmula rectangular (sirve como aproximaciÛn)
yconj = y.*(-1 + sqrt(1 + 8.*Fr2))/2;

% Para trapezoidal conviene arrancar con un valor mayor (rama subcrÌtica)
if yconj <= y
    yconj = y * 3;   % estimaciÛn inicial m·s robusta
end

% NOTA: para el caso rectangular las siguientes dos lÌneas de cÛdigo no son 
% necesarias. Se incluyen como ayuda para la Tarea.
par=[Q,b,M]; % armado de vector de par·metros que permite pasar los valores 
% de Q, b y M dentro de la funciÛn que busca el tirante conjugado

% Busqueda del cero de la funciÛn, descomentar y comentar seg˙n se trabaje en 
% Matlab o en Octave:
% En Matlab:
% yconj=fzero(@(y) conj_rect(y,par), yconj); % funciÛn de Matlab que busca el 
% cero de la funciÛn conj_rect. Ver help de Matlab para fzero.
% En Octave:
yconj=fsolve(@(yc) conj_rect(yc,par,m), yconj); % funciÛn de Octave que busca el 
% cero de la funciÛn conj_rect. Ver help de Octave para fsolve.

% --- NUEVO: verificaciÛn de que la soluciÛn sea subcrÌtica ---
[Bc,Ac,Pc,Rc,yGc,Dc] = trap_geom(yconj,b,m);
Uc = Q/Ac;
Fr = Uc / sqrt(g*Dc);

if Fr >= 1 || yconj <= y
    % Si no es subcrÌtico, no es un conjugado v·lido
    yconj = NaN;
end

end % fin de Mom_trap


function eM=conj_rect(y,par,m)
% Sub-funciÛn auxiliar que calcula el error relativo entre el momento dado y el
% momento calculado usando el tirante conjugado estimado, que se buscara
% minimizar.
% INPUTS
% par vector de entrada de par·metros fijos
% y variable de entrada a la funciÛn cuyo valor se seleccionara para
% minimizar el error eM. En este caso cuando se llama a esta sub-funciÛn dentro 
% de fzero la variable de entrada en yconj.
% OUTPUTS
% eM error relativo
%
% descomposiciÛn del vector de par·metros en las variables originales
Q = par(1);
b = par(2);
M = par(3);

[B,A,P,R,yG,D]=trap_geom(y,b,m); % funciÛn que calcula par·metros geomÈtricos de 
% la secciÛn (algunos de los cuales no son usados en esta sub-funciÛn), 
% debe estar en el mismo directorio.

eM = M/(yG.*A + Q^2./(9.8*A)) - 1; % error relativo entre el valor del momento dado y 
% el calculado con el valor de la variable de entrada y.

end % fin de conj_rect
