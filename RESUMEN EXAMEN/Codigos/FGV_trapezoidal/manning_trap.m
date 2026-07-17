% manning_trap.m — función auxiliar de error (Q_Manning(y) - Q) con
% vector de parámetros par=[Q b S n m], pensada para pasarse como
% function handle a fsolve/fzero (p.ej. dentro de fgv_trap.m para hallar
% yn). Equivalente "estilo par" de eq_yn.m. Requiere trap_geom.m.
function en = manning_trap(y,par)
% Funci�n auxiliar que calcula la diferencia entre el caudal que circular�a
% en el canal si el tirante normal fuera el tirante de entrada (y) y el
% caudal real que circula en el canal.
% INPUTS
% y tirante de entrada con el que calcular� el caudal con ese tirante en flujo uniforme
% par vector de par�metros de entrada
% OUTPUTS
% en apartamiento del Caudal estimado con el tirante y respecto al caudal real
 
%% Descomposici�n del vector de par�metros de entrada
Q = par(1);% caudal (m3/s)
b = par(2);% ancho de fondo (m)
S = par(3);% pendiente de fondo
n = par(4);% n de Manning
m = par(5);%% pendiente taludes laterales 1V:mH
 
%% Funci�n
[B,A,P,R,yG,D]=trap_geom(y,b,m);% funci�n que calcula par�metros geom�tricos de la secci�n
en=A/n*R.^(2/3).*S.^0.5 - Q;% diferencia entre el caudal estimado suponiendo flujo uniforme con tirante y con el caudal real

