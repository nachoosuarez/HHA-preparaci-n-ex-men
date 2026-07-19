% sistema_lago_M.m — sistema 2x2 (energia + Manning) para el caudal Q y
% tirante normal yn con que un lago (nivel hLago sobre el fondo) alimenta
% un canal TRAPEZOIDAL tipo M (mild), muy largo (el tirante de entrada
% tiende a yn). v=[Q,yn]. Requiere trap_geom.m.
function e = sistema_lago_M(v,b,m,n,S0,hLago)
  Q = v(1); yn = v(2);
  g = 9.8;
  [~,A,~,R] = trap_geom(yn,b,m);
  e = [ hLago - (yn + Q^2/(2*g*A^2)) ;
        Q - (1/n)*A*R^(2/3)*sqrt(S0) ];
end
