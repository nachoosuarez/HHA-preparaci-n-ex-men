% Eesp_rect.m ‚Äî calcula la energ√≠a espec√≠fica E de un canal RECTANGULAR
% para un tirante y dado, y su tirante ALTERNO yalt de forma CERRADA
% (f√≥rmula anal√≠tica, no requiere iteraci√≥n como la versi√≥n trapezoidal
% Eesp_trap.m). Entradas: y (tirante, m), b (ancho, m), Q (caudal,
% m3/s). Salidas: E (energ√≠a espec√≠fica, m), yalt (tirante alterno, m).
% Usar cuando: transici√≥n con ENERG√çA CONSTANTE en canal rectangular
% (escal√≥n de fondo, compuerta sin p√©rdidas). Requiere rect_geom.m.
function [E,yalt]=Eesp_rect(y,b,Q)

%  FunciÛn que calcula la energÌa especifica y el tirante alterno para un canal
% rectangular para un tirante, ancho de canal y caudal dados
%
% INPUTS
% y tirante (m)
% b ancho (m)
% Q caudal (m^3/s)
%
% OUTPUTS
% EnergÌa especifica (m)
% yalt tirante alterno de y (m)
%
% Calculo de la energÌa especifica
[B,A,P,R,yG,D]=rect_geom(y,b);
U=Q./A;% velocidad media
E=y+U.^2/(2*9.8);% energÌa especifica
Fr2=(Q^2)*B./(9.8.*A.^3);% n˙mero de Froude al cuadrado
%
% Busqueda del tiernte alterno
yalt=y./(-1 + sqrt(1 + 8./Fr2))*2;% Sol. para caso rectangular

function eE=alt_rect(y,par)
% FunciÛn auxiliar que calcula el error relativo entre la energÌa
% especifica dada y la energÌa especifica calculada usando el tirante alterno estimado, que se buscara
% minimizar.
% INPUTS
% par vector de par·metros de entrada
% y variable de entrada a la funciÛn cuyo valor se seleccionara para minimizar el error eE
% OUTPUTS
% eE error relativo
%
% descomposiciÛn del vector de par·metros en las variables originales
Q = par(1);
b = par(2);
E = par(3);

[B,A,P,R,yG,D]=rect_geom(y,b);% funciÛn que calcula par·metros geomÈtricos de la 
% secciÛn (algunos de los cuales no son usados en esta sub-funciÛn), debe estar en el mismo directorio.
U=Q/A;% velocidad media
eE=E/(y+U^2/(2*9.8))-1;% error relativo entre el valor de la energÌa especifica 
% dada y la calculada con el valor de la variable de entrada y.
