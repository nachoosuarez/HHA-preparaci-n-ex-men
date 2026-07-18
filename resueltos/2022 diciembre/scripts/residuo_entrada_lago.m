% residuo_entrada_lago.m — función auxiliar (residuo de energía) usada
% por Ejercicio1_FGV_doslagos.m Parte 3 dentro de fzero, para hallar el
% caudal Q tal que, integrando la rama subcrítica HACIA ATRÁS desde la
% salida (x=L, y=hL2, sin término cinético: la salida disipa la energía
% cinética en la expansión hacia el lago) hasta la entrada (x=0), la
% energía en la entrada (con término cinético, la entrada SÍ conserva
% energía por ser una contracción) iguale la del Lago 1 (hL1). Requiere
% rect.m (misma carpeta).
function E0 = residuo_entrada_lago(Q, b, S0, n, g, L, hL2, opts)
    [~, ys] = ode45(@(x,y) rect(x,y,[Q b S0 n]), [L 0], hL2, opts);
    y0 = ys(end);
    A0 = b*y0;
    E0 = y0 + Q^2/(2*g*A0^2);
end
