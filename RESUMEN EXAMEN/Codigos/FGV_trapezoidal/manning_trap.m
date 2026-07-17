% manning_trap.m â€” funciÃ³n auxiliar de error (Q_Manning(y) - Q) con
% vector de parÃ¡metros par=[Q b S n m], pensada para pasarse como
% function handle a fsolve/fzero (p.ej. dentro de fgv_trap.m para hallar
% yn). Equivalente "estilo par" de eq_yn.m. Requiere trap_geom.m.
function en = manning_trap(y,par)
% Función auxiliar que calcula la diferencia entre el caudal que circularía
% en el canal si el tirante normal fuera el tirante de entrada (y) y el
% caudal real que circula en el canal.
% INPUTS
% y tirante de entrada con el que calculará el caudal con ese tirante en flujo uniforme
% par vector de parámetros de entrada
% OUTPUTS
% en apartamiento del Caudal estimado con el tirante y respecto al caudal real
 
%% Descomposición del vector de parámetros de entrada
Q = par(1);% caudal (m3/s)
b = par(2);% ancho de fondo (m)
S = par(3);% pendiente de fondo
n = par(4);% n de Manning
m = par(5);%% pendiente taludes laterales 1V:mH
 
%% Función
[B,A,P,R,yG,D]=trap_geom(y,b,m);% función que calcula parámetros geométricos de la sección
en=A/n*R.^(2/3).*S.^0.5 - Q;% diferencia entre el caudal estimado suponiendo flujo uniforme con tirante y con el caudal real

