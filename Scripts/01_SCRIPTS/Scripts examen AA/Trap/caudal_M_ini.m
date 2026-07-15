function [Q_ini,yn,yc] = caudal_M_ini(n,m,b,S,yl1)
  %INPUTS
  %n numero de manning
  %Q caudal [m^3/s]
  %m talud canal trapezoidal
  %b ancho del canal trapezoidal
  %S pendiente3
  %yl1 tirante en el lago 1
  
  %ESTE SCRIPT LO QUE BUSCA ES ENCONTRAR UN CAUDAL EL CAUL SEA UTIL PARA COMENZAR A PROBAR EN RESOLVER LOS CANALES M
  
  %para ello, se suponer que y1=yn 
  
   par = [n,m,b,S,yl1];
   yalt_ini = 1;%variable para comenzar a iterar
   
   yn =fsolve(@(yn) tirante1(yn,par),yalt_ini);
   [B,A,P,R,yG,D]=trap_geom(yn,b,m);
   Q_ini = ((yl1 - yn)*(2*9.8*A^2))^(1/2);
   [~,yc] = tirantes_yn_yc(Q_ini,n,m,b,S);
 endfunction

function e = tirante1(yn,par);
  n = par(1);
  m = par(1);
  b = par(3);
  S = par(4);
  yl1 = par(5);
  [B,A,P,R,yG,D]=trap_geom(yn,b,m);
  e = yl1 - yn - ((((1/n)*A*(R^(2/3))*(S^(1/2)))^2)/(2*9.8*A^2));
 endfunction

