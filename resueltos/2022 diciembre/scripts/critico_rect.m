% critico_rect.m — calcula directamente (fórmula cerrada, sin
% iteración) el tirante crítico yc=(Q^2/(g*b^2))^(1/3) de un canal
% RECTANGULAR. Entradas: b (ancho, m), Q (caudal, m3/s). Salida: yc
% (tirante crítico, m). NO CONFUNDIR con critico.m de este mismo
% directorio: ese es la función "Events" de parada para ode23 (distinto
% propósito, incluido igual porque fgv_rect.m lo necesita internamente).
% Usar cuando: se pide sólo el tirante crítico de un canal rectangular
% sin correr todo fgv_rect.m. No requiere otras funciones.
function yc = critico_rect(b,Q)

% Funcion que calcula el tirante critico de una seccion rectangular, para un
% caudal y tirante dados
%
% INPUTS
% b ancho de la base (m)
% Q caudal (m^3/s)
%
% OUTPUTS
% yc tirante critico (m)
%
% CALCULO DEL TIRANTE
yc=(Q^2/(9.8*b^2))^(1/3);