function [y2_sol, E1_sol] = descarga_ahogada(M3, Q, b, m, a)
%se conserva la energía entre 1-2 y se conserva el momento entre 2-3
% Función que resuelve el sistema de energía y momento para una compuerta
% con descarga ahogada, donde las incógnitas son:
%   y2 = tirante aguas abajo
%   E1 = energía específica aguas arriba
%
% INPUTS:
% M3 momento aguas abajo (m^3)
% Q  caudal (m^3/s)
% b  ancho de fondo del canal (m)
% m  talud lateral (1V:mH)
% a  altura de compuerta (m)
%
% OUTPUTS:
% y2_sol tirante aguas abajo (m)
% E1_sol energía específica aguas arriba (m)

g = 9.8;

% Área en movimiento bajo compuerta (fijo)
[~, Am, ~, ~, ~, ~] = trap_geom(a, b, m);

% Estimaciones iniciales
y2_0 = a * 1.2;   % tirante inicial razonable
E1_0 = y2_0 + (Q^2)/(2*g*Am^2);

x0 = [y2_0; E1_0];

% Resolución del sistema no lineal
sol = fsolve(@(x) sistema_ec(x, M3, Q, b, m, Am), x0);

y2_sol = sol(1);
E1_sol = sol(2);

end


function F = sistema_ec(x, M3, Q, b, m, Am)

% x(1) = y2
% x(2) = E1

y2 = x(1);
E1 = x(2);

g = 9.8;

% Geometría completa de la sección 2
[~, A2, ~, ~, yG2, ~] = trap_geom(y2, b, m);

% Ecuación de energía:
% E1 = y2 + (Q^2)/(2*g*Am^2)
F(1) = y2 + (Q^2)/(2*g*Am^2) - E1;

% Ecuación de momento:
% M2 = yG2*A2 + (Q^2)/(g*Am) = M3
M2 = yG2*A2 + (Q^2)/(g*Am);
F(2) = M2 - M3;

end