function [Q,y1] = caudal_S_ini(n,m,b,S,yl1)
  %n numero de manning
  %Q caudal [m^3/s]
  %m talud canal trapezoidal
  %b ancho del canal trapezoidal
  %S pendiente
  %yl1 tirante en el lago 1
  
  %ESTE SCRIPT LO QUE BUSCA ES ENCONTRAR UN CAUDAL EL CAUL SEA UTIL PARA COMENZAR A PROBAR EN RESOLVER LOS CANALES S
  
  %para ello, se suponer que y1=yn 
  
   par = [n,m,b,S,yl1];
   yalt_ini = 1;%variable para comenzar a iterar
   
   y1 =fsolve(@(y1) tirante2(y1,par),yalt_ini);
   [B,A,P,R,yG,D]=trap_geom(y1,b,m);
   Q =  (9.8*(A^2)*D)^(1/2);
 endfunction

function e = tirante2(y1,par);
  n = par(1);
  m = par(1);
  b = par(3);
  S = par(4);
  yl1 = par(5);
  [B,A,P,R,yG,D]=trap_geom(y1,b,m);
  e = ((yl1-y1)*2*9.8*(A^2)) - (9.8*(A^2)*D);
 endfunction

