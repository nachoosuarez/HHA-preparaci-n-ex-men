function [yconj1 yconj2]=conjugados_trap(b,m,Q,M)
  
% Funcion que calcula los tirantes conjugados para un canal trapezoidal dados
% el ancho de la base del canal, la pendiente de los taludes (expresada como 
% 1V:mH), el caudal circulante y un valor de momentum
%
% INPUTS
% b ancho de la base del canal
% m inverso de la pendiente de los taludes
% Q caudal circulante por el canal
% M momento
%  
% OUTPUTS
% yconj1,yconj2 tirantes conjugados para los parametros especificados
%
% Calculos
ycr=nthroot(Q^2/(9.8*b^2),3); %ycr de canak rect. como primera iteracion
yconj1=fsolve(@(y) conj_iteracion(y,Q,b,M,m),ycr); 
  
function eM=conj_iteracion(y,Q,b,M,m)
  % subfuncion que calcula el error relativo del M calculado con el tirante de 
  % cada iteracion respecto al valor del problema minimizando esta funcion se 
  % halla una aproximacion del tirante buscado
    
  [B A P R yG D]=trap_geom(y,b,m);
   U=Q/A;
   eM=(yG*A+Q^2/(9.8*A))/M-1;
   endfunction
    
[M yconj2]=Mom_trap(yconj1,b,Q,m); 
endfunction