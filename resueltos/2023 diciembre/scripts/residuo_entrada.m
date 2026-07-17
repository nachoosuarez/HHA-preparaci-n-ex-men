% residuo_entrada.m — función auxiliar (residuo de energía) usada por
% Ejercicio1_FGV_dostramos.m Parte 2 dentro de fzero, para hallar el
% caudal Q tal que, con control crítico en el cambio de pendiente
% (x=L1, y=yc(Q)) integrando la curva M2 del tramo 1 HACIA ATRÁS hasta
% x=0, la energía en la entrada iguale la del Lago A (hLA). Requiere
% rect.m (misma carpeta).
function res = residuo_entrada(Q, b, n, S01, hLA, L1)
    g = 9.8;
    ycQ = (Q^2/(g*b^2))^(1/3);
    par = [Q b S01 n];
    [~, yb] = ode23(@(x,y) rect(x,y,par), [L1 0], ycQ*(1+1e-4));
    y0 = yb(end);
    A0 = b*y0;
    res = (y0 + Q^2/(2*g*A0^2)) - hLA;
end
