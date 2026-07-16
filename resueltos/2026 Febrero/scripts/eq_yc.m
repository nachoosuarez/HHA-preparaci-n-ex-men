function e = eq_yc(y,Q,m,b)

  g = 9.8;
  T = b + 2*m*y;
  A = y*(b + m*y);

  e = (Q^2 * T)/(g * A^3) - 1;

endfunction
