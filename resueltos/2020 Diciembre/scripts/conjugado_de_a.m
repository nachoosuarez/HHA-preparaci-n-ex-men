% conjugado_de_a.m — devuelve solo el tirante conjugado (momento) de un
% tirante dado en canal trapezoidal, para poder usarse dentro de fsolve
% (Mom_trap.m devuelve [M,yconj], fsolve necesita una funcion escalar).
function yconj = conjugado_de_a(a, b, m, Q)
  [~, yconj] = Mom_trap(a, b, m, Q);
end
