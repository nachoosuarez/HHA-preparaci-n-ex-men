function [yn,yc] = tirantes_yn_yc(Q,n,m,b,S)

  % estimación inicial
  y_ini = 1;

  % tirante normal (Manning)
  yn = fsolve(@(y) eq_yn(y,Q,n,m,b,S), y_ini);

  % tirante crítico
  yc = fsolve(@(y) eq_yc(y,Q,m,b), y_ini);

endfunction
