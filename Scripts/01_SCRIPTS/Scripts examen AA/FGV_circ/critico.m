function [value,isterminal,direction] = critico(x,y,yc)
% Locate the time when height passes through zero in a 
% decreasing direction and stop integration.
value = (y-yc);     % Detect yc and stops
isterminal = 1;   % Stop the integration
direction = 0;   % 0 Detect all zero crossings. 1 Detect zero crossings in the positive direction only. -1 Detect zero crossings in the negative direction only.