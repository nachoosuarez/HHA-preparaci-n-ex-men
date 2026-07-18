% critico.m â€” funciÃ³n "Events" para ode23/ode45: detiene la integraciÃ³n
% de la ecuaciÃ³n diferencial de FGV (ver rect.m / fgv_trap.m) apenas el
% tirante y cruza el tirante crÃ­tico yc=par(5). No calcula nada por sÃ­
% sola â€” solo se pasa como odeset('Events',@(x,y) critico(x,y,par)).
% Requiere que par traiga yc en la 5ta posiciÃ³n: par=[Q b S n yc m].
function [value,isterminal,direction] = critico(x,y,par)
% Función que encuentra la posición x donde el tirante pasa por el tirante
% crítico para la integración de la ecuación diferencial.

yc=par(5);
value = y-yc; % cuando el tirante cruza el tirante crítico se debe parar
isterminal = 1;   % si es igual a 1 se detiene la integración
direction = 0;   % 0 detecta todos los cruces a cero. 1 detecta los cruces a cero en la dirección positiva solamente. -1 detecta los cruces a cero en la dirección negativa solamente.
