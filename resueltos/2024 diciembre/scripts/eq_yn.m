function e = eq_yn(y,Q,n,m,b,S)

  [B,A,P,R,yG,D] = trap_geom(y,b,m);

  Qm = (1/n)*A*(R^(2/3))*sqrt(S);

  e = Q - Qm;

endfunction
