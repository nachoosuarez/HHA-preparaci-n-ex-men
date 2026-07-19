% perfil_union_fn.m — dado un nivel de Lago B (hLB), propaga la rama
% subcritica desde la salida del tramo III (control critico si hLB<=yc,
% o directamente hLB si el lago ahoga la salida) hacia atras a traves
% de los tramos III y II, y devuelve el tirante resultante en la union
% tramo I/II. Usado por Ejercicio1_FGV_trapezoidal_3tramos.m (Parte 3)
% dentro de un fzero para hallar el hLB umbral en el que ese tirante
% iguala el conjugado de yn_I (resalto justo en la union).
% Requiere rect.m (mismo directorio FGV_trapezoidal en el path).
function y_junctionI_II = perfil_union_fn(hLB,Q,b,m,n,yc,S3,S2,LII,LIII)
  if hLB <= yc
    y_exit = yc*1.0005;   % control critico (el lago no alcanza a ahogar la salida)
  else
    y_exit = hLB;         % lago ahoga la salida: su nivel es la condicion de borde
  end
  par3 = [Q b S3 n yc m];
  [~,y3] = ode23(@(x,y) rect(x,y,par3), [LIII, 0], y_exit, ...
                 odeset('RelTol',1e-9,'AbsTol',1e-9));
  par2 = [Q b S2 n yc m];
  [~,y2] = ode23(@(x,y) rect(x,y,par2), [0, -LII], y3(end), ...
                 odeset('RelTol',1e-9,'AbsTol',1e-9));
  y_junctionI_II = y2(end);
end
