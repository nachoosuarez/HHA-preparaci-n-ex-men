% tirantes_yn_yc.m — atajo que calcula juntos el tirante normal yn
% (Manning) y el tirante crítico yc de un canal trapezoidal, resolviendo
% eq_yn.m y eq_yc.m con fsolve a partir de una estimación inicial fija
% (y_ini=1). Entradas: Q, n, m, b, S. Usar cuando: se necesitan yn e yc
% de entrada para armar el perfil de FGV (tipo de curva M/S, condiciones
% de borde de fgv_trap.m). Requiere trap_geom.m, eq_yn.m, eq_yc.m.
function [yn,yc] = tirantes_yn_yc(Q,n,m,b,S)

  % estimaci�n inicial
  y_ini = 1;

  % tirante normal (Manning)
  yn = fsolve(@(y) eq_yn(y,Q,n,m,b,S), y_ini);

  % tirante cr�tico
  yc = fsolve(@(y) eq_yc(y,Q,m,b), y_ini);

endfunction
