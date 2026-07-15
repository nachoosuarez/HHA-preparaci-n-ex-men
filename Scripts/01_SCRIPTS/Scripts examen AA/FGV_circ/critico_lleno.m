function [value,isterminal,direction] = critico_lleno(x,y,yc,d)
% Locate the time when height passes through zero in a 
% decreasing direction and stop integration.
value = [(y-yc);(d-real(y));real(y)];     % Detect yc and stops (y-yc)*
isterminal = [1;1;1];   % Stop the integration
direction = [0;0;0];   % 0 Detect all zero crossings. 1 Detect zero crossings in the positive direction only. -1 Detect zero crossings in the negative direction only.