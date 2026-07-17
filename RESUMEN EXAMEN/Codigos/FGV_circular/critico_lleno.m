% critico_lleno.m — función "Events" para ode23/ode45 específica de
% CONDUCTO CIRCULAR: detiene la integración de la ecuación diferencial
% de FGV (circ.m/fgv_circ.m) si el tirante y cruza el tirante crítico
% yc, si llega al diámetro d (caño a sección llena), o si y llega a
% cero. Se pasa como
% odeset('Events',@(x,y) critico_lleno(x,y,yc,d)). Es el equivalente
% circular de critico.m (que sólo detecta el cruce por yc), adaptado
% porque en un caño también hay que frenar al llegar a "lleno" (y=d).
function [value,isterminal,direction] = critico_lleno(x,y,yc,d)
% Locate the time when height passes through zero in a
% decreasing direction and stop integration.
value = [(y-yc);(d-real(y));real(y)];     % Detect yc and stops (y-yc)*
isterminal = [1;1;1];   % Stop the integration
direction = [0;0;0];   % 0 Detect all zero crossings. 1 Detect zero crossings in the positive direction only. -1 Detect zero crossings in the negative direction only.