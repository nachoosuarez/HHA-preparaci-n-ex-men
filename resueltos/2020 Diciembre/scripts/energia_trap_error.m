% energia_trap_error.m — error entre la energia especifica E(y) de un
% canal trapezoidal y una energia objetivo Etarget, para resolver con
% fsolve el tirante y que da esa energia (subcritico o supercritico
% segun el punto inicial de iteracion). Requiere trap_geom.m.
function e = energia_trap_error(y,b,Q,m,Etarget)
  g = 9.8;
  [~,A] = trap_geom(y,b,m);
  e = (y + (Q/A)^2/(2*g)) - Etarget;
end
