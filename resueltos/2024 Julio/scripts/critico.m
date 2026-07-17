function [value,isterminal,direction] = critico(x,y,par)
% Función que encuentra la posición x donde el tirante pasa por el tirante
% crítico para la integración de la ecuación diferencial.

yc=par(5);
value = y-yc; % cuando el tirante cruza el tirante crítico se debe parar
isterminal = 1;   % si es igual a 1 se detiene la integración
direction = 0;   % 0 detecta todos los cruces a cero. 1 detecta los cruces a cero en la dirección positiva solamente. -1 detecta los cruces a cero en la dirección negativa solamente.
