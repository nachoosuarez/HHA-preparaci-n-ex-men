% Eesp_rect.m — calcula la energía específica E de un canal RECTANGULAR
% para un tirante y dado, y su tirante ALTERNO yalt de forma CERRADA
% (fórmula analítica, no requiere iteración como la versión trapezoidal
% Eesp_trap.m). Entradas: y (tirante, m), b (ancho, m), Q (caudal,
% m3/s). Salidas: E (energía específica, m), yalt (tirante alterno, m).
% Usar cuando: transición con ENERGÍA CONSTANTE en canal rectangular
% (escalón de fondo, compuerta sin pérdidas). Requiere rect_geom.m.
function [E,yalt]=Eesp_rect(y,b,Q)

%  Funci�n que calcula la energ�a especifica y el tirante alterno para un canal
% rectangular para un tirante, ancho de canal y caudal dados
%
% INPUTS
% y tirante (m)
% b ancho (m)
% Q caudal (m^3/s)
%
% OUTPUTS
% Energ�a especifica (m)
% yalt tirante alterno de y (m)
%
% Calculo de la energ�a especifica
[B,A,P,R,yG,D]=rect_geom(y,b);
U=Q./A;% velocidad media
E=y+U.^2/(2*9.8);% energ�a especifica
Fr2=(Q^2)*B./(9.8.*A.^3);% n�mero de Froude al cuadrado
%
% Busqueda del tiernte alterno
yalt=y./(-1 + sqrt(1 + 8./Fr2))*2;% Sol. para caso rectangular

function eE=alt_rect(y,par)
% Funci�n auxiliar que calcula el error relativo entre la energ�a
% especifica dada y la energ�a especifica calculada usando el tirante alterno estimado, que se buscara
% minimizar.
% INPUTS
% par vector de par�metros de entrada
% y variable de entrada a la funci�n cuyo valor se seleccionara para minimizar el error eE
% OUTPUTS
% eE error relativo
%
% descomposici�n del vector de par�metros en las variables originales
Q = par(1);
b = par(2);
E = par(3);

[B,A,P,R,yG,D]=rect_geom(y,b);% funci�n que calcula par�metros geom�tricos de la 
% secci�n (algunos de los cuales no son usados en esta sub-funci�n), debe estar en el mismo directorio.
U=Q/A;% velocidad media
eE=E/(y+U^2/(2*9.8))-1;% error relativo entre el valor de la energ�a especifica 
% dada y la calculada con el valor de la variable de entrada y.
