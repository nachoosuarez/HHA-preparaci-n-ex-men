% control_critico_lago_trap.m — halla el caudal Q de control crítico con
% el que un lago (nivel hLago sobre el fondo del canal) descarga a un
% canal TRAPEZOIDAL cuyo tramo de entrada es tipo S (steep). A diferencia
% del caso rectangular (Q=b*sqrt(g*yc^3), yc=(2/3)*hLago, forma cerrada),
% en sección trapezoidal yc(Q) no tiene forma cerrada: se itera un fzero
% EXTERNO en Q alrededor del fsolve interno en yc (eq_yc.m), hasta que
% yc(Q) + Q^2/(2g*A(yc)^2) = hLago (conservación de energía, sin
% pérdidas, entre el lago y la sección de entrada del canal).
%
% Entradas: hLago (nivel del lago sobre el fondo, m), b (ancho de fondo,
% m), m_talud (talud lateral 1V:mH), Q_rango (opcional, [Qmin Qmax] para
% fzero; default [0.1 100]).
% Salidas: Q (caudal de control crítico, m3/s), yc (tirante crítico, m).
%
% Usar cuando: un lago alimenta un canal trapezoidal cuyo tramo de
% entrada resulta (o se sospecha) tipo S — SIEMPRE verificar después,
% con yn (eq_yn.m) del tramo de entrada, que yn<yc (canal
% efectivamente steep); si no, el control crítico en la entrada NO es
% válido y el control pasa a estar aguas abajo (ver
% RESUMEN_TEORICO.md §A4, "canal de dos tramos"). Ejemplo de uso
% completo: resueltos/2023 Julio/scripts/Ejercicio1_FGV_trapezoidal_relleno.m
% Requiere trap_geom.m, eq_yc.m (mismo directorio).
function [Q,yc] = control_critico_lago_trap(hLago,b,m_talud,Q_rango)

  if nargin < 4
    Q_rango = [0.1 100];
  end

  opt = optimset('Display','off');
  g = 9.8;

  Q = fzero(@(QQ) residuo(QQ,b,m_talud,hLago,g,opt), Q_rango);
  yc = fsolve(@(y) eq_yc(y,Q,m_talud,b), 1, opt);

end

function res = residuo(Q,b,m_talud,hLago,g,opt)
  yc = fsolve(@(y) eq_yc(y,Q,m_talud,b), 1, opt);
  [~,A] = trap_geom(yc,b,m_talud);
  E = yc + Q^2/(2*g*A^2);
  res = E - hLago;
end
