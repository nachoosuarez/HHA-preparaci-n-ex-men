% critico.m — función "Events" para ode23/ode45: detiene la integración
% de la ecuación diferencial de FGV (ver rect.m / fgv_trap.m) apenas el
% tirante y cruza el tirante crítico yc=par(5). No calcula nada por sí
% sola — solo se pasa como odeset('Events',@(x,y) critico(x,y,par)).
% Requiere que par traiga yc en la 5ta posición: par=[Q b S n yc m].
function [value,isterminal,direction] = critico(x,y,par)
% Funci�n que encuentra la posici�n x donde el tirante pasa por el tirante
% cr�tico para la integraci�n de la ecuaci�n diferencial.

yc=par(5);
value = y-yc; % cuando el tirante cruza el tirante cr�tico se debe parar
isterminal = 1;   % si es igual a 1 se detiene la integraci�n
direction = 0;   % 0 detecta todos los cruces a cero. 1 detecta los cruces a cero en la direcci�n positiva solamente. -1 detecta los cruces a cero en la direcci�n negativa solamente.
