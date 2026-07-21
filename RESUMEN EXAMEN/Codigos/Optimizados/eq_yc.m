% eq_yc.m — función de error (Froude^2 - 1) para hallar el tirante
% crítico yc de un canal trapezoidal por fsolve/fzero. Entradas: y
% (tirante a probar), Q (caudal), m (talud), b (ancho de fondo). Usar
% junto con fsolve(@(y) eq_yc(y,Q,m,b), y0) — ver también
% tirantes_yn_yc.m que ya envuelve esta llamada. Requiere ninguna otra
% función (cálculo cerrado con T y A del trapecio).
function e = eq_yc(y,Q,m,b)

  g = 9.8;
  T = b + 2*m*y;
  A = y*(b + m*y);

  e = (Q^2 * T)/(g * A^3) - 1;

endfunction
