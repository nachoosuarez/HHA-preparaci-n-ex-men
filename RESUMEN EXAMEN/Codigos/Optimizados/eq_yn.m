% eq_yn.m — función de error (Q - Q_Manning(y)) para hallar el tirante
% normal yn de un canal trapezoidal por fsolve/fzero. Entradas: y
% (tirante a probar), Q (caudal), n (Manning), m (talud), b (ancho de
% fondo), S (pendiente de fondo). Usar junto con
% fsolve(@(y) eq_yn(y,Q,n,m,b,S), y0) — ver también tirantes_yn_yc.m.
% Requiere trap_geom.m en el mismo directorio.
function e = eq_yn(y,Q,n,m,b,S)

  [B,A,P,R,yG,D] = trap_geom(y,b,m);

  Qm = (1/n)*A*(R^(2/3))*sqrt(S);

  e = Q - Qm;

endfunction
