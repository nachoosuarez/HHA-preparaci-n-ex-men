% dos_lagos_trap.m — resuelve por "shooting" el caudal Q de un canal
% TRAPEZOIDAL tipo M (mild) que conecta dos lagos de nivel conocido,
% cuando el canal NO es "muy largo" (no alcanza a que y(entrada)=>yn) y
% por lo tanto no sirve la aproximación directa de A4 ("canal tipo M
% muy largo"): hay que integrar la curva de FGV completa entre los dos
% extremos. Dos modos de uso:
%
%   modo = 'hLB_dado'      : el nivel del lago de salida hLB es DATO.
%                             BC de salida: y(x=L) = hLB (expansión
%                             brusca lago-canal, sin sumar Q^2/2gA^2).
%                             Se itera Q hasta que la energía específica
%                             en la entrada (contracción, SIN pérdidas)
%                             cierre con el nivel del lago de entrada:
%                             E(y(x=0)) = hLA.
%
%   modo = 'critico_salida': el nivel de salida hLB es tan bajo que deja
%                             de controlar: se vuelve control CRÍTICO en
%                             la propia salida del canal (como una caída
%                             libre "interna"), y aguas abajo de ahí el
%                             perfil es supercrítico hasta el lago B
%                             (que ya no influye). BC de salida:
%                             y(x=L) = yc(Q). Se itera Q con el mismo
%                             cierre de energía en la entrada. El Q que
%                             resulta es el CAUDAL MÁXIMO que el lago de
%                             entrada puede descargar por este canal: es
%                             constante para cualquier hLB <= yc(Q) (el
%                             caudal deja de depender de hLB).
%
% Entradas:
%   hLA   nivel del lago de entrada sobre el fondo del canal en x=0 (m)
%   hLB   nivel del lago de salida sobre el fondo del canal en x=L (m)
%         (ignorado si modo='critico_salida'; pasar [] o cualquier valor)
%   b,m,S0,n  geometría/rugosidad del canal (ancho de fondo, talud
%             1V:mH, pendiente de fondo, Manning)
%   L     longitud del canal (m)
%   modo  'hLB_dado' (default) o 'critico_salida'
%   Q_rango  (opcional) [Qmin Qmax] para el fzero externo; default [0.05 50]
%
% Salidas:
%   Q         caudal de régimen (m3/s)
%   yn,yc     tirante normal y crítico para ese Q
%   y0,yL     tirante en la entrada (x=0) y en la salida (x=L)
%   x,y       perfil completo y(x) (x de L a 0, orden de integración)
%   clasif    'M' o 'S' según yn vs yc
%
% Verificar SIEMPRE al final que yn>yc (canal efectivamente M/mild) y
% que el perfil resultante no cruza yc en el medio (si cruzara, el
% planteo no es válido y hay que revisar cuál extremo controla).
%
% Ejemplo de uso completo: resueltos/2019 Diciembre/scripts/
% Ejercicio1_dos_lagos_trapezoidal.m (canal 2 lagos, L=370m, b=1.5m,
% m=2, S0=0.0003, n=0.011, hLA=1.24m; parte a) hLB=1.3m dado -> Q=3.33
% m3/s; parte b) rango de hLB para el cual Q no depende de él ->
% hLB<=0.84m -> Q=6.20 m3/s constante).
%
% Requiere (mismo directorio): trap_geom.m, eq_yn.m, eq_yc.m,
% tirantes_yn_yc.m, rect.m, critico.m.
function [Q,yn,yc,y0,yL,x,y,clasif] = dos_lagos_trap(hLA,hLB,b,m,S0,n,L,modo,Q_rango)

  if nargin < 8 || isempty(modo)
    modo = 'hLB_dado';
  end
  if nargin < 9 || isempty(Q_rango)
    Q_rango = [0.05 50];
  end

  g = 9.8;
  opt = optimset('Display','off');

  Q = fzero(@(QQ) residuo(QQ,hLA,hLB,b,m,S0,n,L,modo,g), Q_rango, opt);

  [yn,yc] = tirantes_yn_yc(Q,n,m,b,S0);
  par = [Q,b,S0,n,yc,m];
  yL_bc = yL_condicion(Q,hLB,yc,modo);
  odeopt = odeset('Events',@(x,y) critico(x,y,par),'RelTol',1e-10,'AbsTol',1e-10);
  [x,y] = ode45(@(x,yy) rect(x,yy,par), [L,0], yL_bc, odeopt);

  y0 = y(end);   % tirante en la entrada, x=0
  yL = y(1);     % tirante en la salida, x=L

  if yn > yc
    clasif = 'M';
  else
    clasif = 'S';
  end

end

function yL_bc = yL_condicion(Q,hLB,yc,modo)
  if strcmp(modo,'critico_salida')
    yL_bc = yc*1.0005;   % arrancar apenas por encima de yc (evita evento espurio en x=L)
  else
    yL_bc = hLB;
  end
end

function res = residuo(Q,hLA,hLB,b,m,S0,n,L,modo,g)
  [yn,yc] = tirantes_yn_yc(Q,n,m,b,S0);
  par = [Q,b,S0,n,yc,m];
  yL_bc = yL_condicion(Q,hLB,yc,modo);
  odeopt = odeset('Events',@(x,y) critico(x,y,par),'RelTol',1e-10,'AbsTol',1e-10);
  [x,y] = ode45(@(x,yy) rect(x,yy,par), [L,0], yL_bc, odeopt);
  y0 = y(end);
  [~,A0] = trap_geom(y0,b,m);
  E0 = y0 + Q^2/(2*g*A0^2);
  res = E0 - hLA;
end
