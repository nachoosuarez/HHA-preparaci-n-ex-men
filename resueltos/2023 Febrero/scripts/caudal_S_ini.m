% caudal_S_ini.m — dado el tirante de un lago/reservorio de entrada
% (yl1) que alimenta un canal trapezoidal tipo S (supercrítico,
% pendiente fuerte), estima un CAUDAL INICIAL razonable para arrancar a
% resolver el problema (suponiendo y1=yc a la entrada, tirante crítico).
% Entradas: n (Manning), m (talud), b (ancho fondo), S (pendiente), yl1
% (tirante en el lago). Salidas: Q, y1 (tirante inicial estimado). Usar
% cuando: hay que iterar/tantear un caudal de régimen para un canal S
% que nace en un lago y no se conoce Q de antemano.
% NOTA: se corrigió un typo de índice en la subfunción tirante2
% (línea "m = par(2);", en el original decía por error "par(1)",
% duplicando el valor de n) — el resto de la lógica no se modificó.
% Requiere trap_geom.m.
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
  m = par(2);
  b = par(3);
  S = par(4);
  yl1 = par(5);
  [B,A,P,R,yG,D]=trap_geom(y1,b,m);
  e = ((yl1-y1)*2*9.8*(A^2)) - (9.8*(A^2)*D);
 endfunction

