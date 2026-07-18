% descarga_ahogada_rect.m — resuelve una COMPUERTA con DESCARGA AHOGADA
% (sumergida) en canal RECTANGULAR: se conserva energía entre la sección
% 1 (aguas arriba) y la 2 (bajo la compuerta, área de velocidad fija
% Am=b*a dada por la apertura a, pero área hidrostática completa b*y2),
% y se conserva MOMENTO entre la 2 y la 3 (aguas abajo, con momento M3
% ya conocido — usar Mom_rect.m con el tirante que impone la condición
% de aguas abajo, p.ej. yn si el resalto queda lejos de otro control).
% Análogo a descarga_ahogada.m de FGV_trapezoidal pero con fórmulas
% cerradas de rect_geom.m (no requiere fsolve para la geometría interna).
% Entradas: M3 (momento aguas abajo, m^3), Q (caudal, m3/s), b (ancho, m),
% a (apertura de la compuerta, m). Salidas: y2 (tirante aguas abajo de la
% compuerta, flujo dividido), y1 (tirante aguas arriba de la compuerta).
% Usar cuando: se determinó que la descarga es AHOGADA, es decir
% a > conjugado(y3) [Mom_rect(y3,b,Q) da ese conjugado]. Para descarga
% LIBRE usar Eesp_rect.m (alterno) + Mom_rect.m (conjugado) en su lugar.
% Requiere rect_geom.m.
function [y2, y1] = descarga_ahogada_rect(M3, Q, b, a)
g = 9.8;

Am = b*a; % area de velocidad bajo la compuerta (fija, flujo dividido)

% 1) Momento entre (2) y (3): b*y2^2/2 + Q^2/(g*Am) = M3   (cerrada en y2^2)
y2 = sqrt( 2/b * (M3 - Q^2/(g*Am)) );

% 2) Energia entre (1) y (2): y1 + Q^2/(2g (b y1)^2) = y2 + Q^2/(2g Am^2)
E2 = y2 + Q^2/(2*g*Am^2);
y1 = fzero(@(y) y + Q^2/(2*g*(b*y)^2) - E2, max(E2,1));
end
