% alternos_trap.m — dada una energía específica E, devuelve los DOS
% tirantes alternos (yalt1 subcrítico, yalt2 supercrítico o viceversa)
% de un canal trapezoidal, iterando con fsolve. Complementa a
% Eesp_trap.m (que parte de un tirante conocido en vez de la energía).
% Entradas: b (ancho fondo), m (talud), Q (caudal), E (energía
% específica, m). Salidas: yalt1, yalt2 (tirantes alternos, m). Usar
% cuando: se conoce E de antemano y se piden ambos tirantes posibles
% (p.ej. antes/después de un escalón donde se conserva energía).
% Requiere trap_geom.m y Eesp_trap.m.
function [yalt1 yalt2]=alternos_trap(b,m,Q,E)

% Funcion que calcula tirantes alternos para un canal trapezoidal dados el ancho 
% de la base del canal, la pendiente de los taludes (expresada como 1V:mH), el 
% caudal circulante y un valor de energia especifica

% INPUTS
% b ancho de la base del canal
% m inverso de la pendiente de los taludes
% Q caudal circulante por el canal
% E energia especifica
%
% OUTPUTS
% yalt1,yalt2 tirantes alternos para los parametros especificados (m)
%
% Calculos
ycr=2*E/3; %tirante critico para el caso de un canal rect. pero que en esta 
% funcion es utilizado para comenzar con la iteracion
par=[Q b E]; 
yalt1=fsolve(@(y) alt_iteracion(y,par,m),ycr); %para Octave

function eE=alt_iteracion(y,par,m)
  % subfuncion que calcula el error relativo entre la Eesp del problema y la 
  % calculada con el tirante de cada paso de la iteracion
  Q=par(1);
  b=par(2);
  E=par(3);
  [B,A,P,R,yG,D]=trap_geom(y,b,m);
  U=Q/A;
  eE=1-E/(y+U^2/(2*9.8));
  endfunction
  
[E yalt2]=Eesp_trap(yalt1,b,Q,m);
endfunction