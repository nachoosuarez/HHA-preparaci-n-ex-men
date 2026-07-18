% Ejercicio1_FGV_trapezoidal_lago_escalon.m
% HHA 2023 Febrero (9/feb/2023) — Ejercicio 1 (30 puntos)
%
% QUÉ HACE: Lago A (nivel hLA sobre el fondo) descarga a un canal
% TRAPEZOIDAL de pendiente mild que termina en caída libre a x=L.
% Parte 1: caudal de descarga y clasificación M/S (control normal en la
% entrada, canal largo). Parte 2: se coloca una tubería/obstáculo de
% fondo (escalón, transición suave) a x=2000 m; se verifica si ahoga la
% sección de entrada al escalón (Dmax=E1-Ec) y, si ahoga, se calcula el
% perfil completo (M1 aguas arriba, cresta crítica, M3 aguas abajo +
% resalto reconectando con la M2 que viene de la caída libre). Parte 3:
% altura máxima de la tubería que NO cambia el caudal del lago (el
% remanso M1 debe relajarse a ~yn antes de llegar a la entrada, 2000 m
% aguas arriba del escalón).
%
% ENTRADAS (bloque DATOS abajo): b, m, n, S0, L, hLA, x_esc, Zesc.
% Requiere (mismo directorio): trap_geom.m, eq_yc.m, eq_yn.m,
% froude_trap.m, manning_trap.m, critico.m, rect.m (ODE), Eesp_trap.m,
% Mom_trap.m, alternos_trap.m.

clear all; close all; clc;
g = 9.8;
opt = optimset('Display','off');

%% ==================== DATOS ====================
b   = 2;      % ancho de fondo (m)
m   = 2;      % talud lateral 1V:mH
n   = 0.02;   % Manning
S0  = 0.001;  % pendiente de fondo
L   = 2500;   % longitud del canal hasta la caída libre (m)
hLA = 1.2;    % nivel del Lago A sobre el fondo del canal (m)
x_esc = 2000; % posición del escalón/tubería (m desde el inicio)
Zesc  = 0.95; % altura del escalón/tubería (m)

fprintf('==================== PARTE 1 ====================\n');
%% Canal tipo M alimentado por un lago, muy largo: sistema (Q,yn)
%   hLA = yn + Q^2/(2g*A(yn)^2)      (energía, sin pérdidas en la entrada)
%   Q   = (1/n)*A(yn)*R(yn)^(2/3)*sqrt(S0)   (Manning, flujo uniforme)
sistema = @(v) sistema_lago_M(v,b,m,n,S0,hLA);
sol = fsolve(sistema, [5;1], opt);
Q  = sol(1);
yn = sol(2);
fprintf('Q = %.4f m3/s   yn = %.4f m\n', Q, yn);

% tirante crítico para ese Q
yc = fsolve(@(y) eq_yc(y,Q,m,b), 0.8, opt);
fprintf('yc = %.4f m\n', yc);
if yn > yc
  fprintf('yn > yc  =>  CANAL TIPO M (mild)\n');
else
  fprintf('yn < yc  =>  CANAL TIPO S (steep) -- hipotesis M invalida!\n');
end

% Verificación: la caída libre en x=L no debe afectar la entrada.
% Se integra la M2 desde x=L (y=1.01yc, control de caída libre) hacia
% atrás y se comprueba que para x=0 el tirante ya practicamente vale yn.
par = [Q b S0 n yc m];
y_brink = 1.01*yc;
optE = odeset('Events', @(x,y) critico(x,y,par), 'RelTol',1e-8,'AbsTol',1e-8);
[xM2, yM2] = ode23(@(x,y) rect(x,y,par), [L 0], y_brink, optE);
fprintf('Perfil M2 (caida libre): y(x=%d)=%.4f (brink) -> y(x=0)=%.4f (yn=%.4f)\n', ...
        L, y_brink, yM2(end), yn);
fprintf('=> Diferencia relativa en x=0: %.3f%% => caida libre NO afecta la descarga\n\n', ...
        100*abs(yM2(end)-yn)/yn);

fprintf('==================== PARTE 2 ====================\n');
%% Perfil "natural" (sin escalón) a x=x_esc, usando la M2 que llega desde
%% la caida libre (se evalua en x=x_esc, a L-x_esc=500 m del final)
y_natural = interp1(xM2, yM2, x_esc);
[~,A_nat] = trap_geom(y_natural,b,m);
E_natural = y_natural + Q^2/(2*g*A_nat^2);
fprintf('Perfil natural (sin escalon) en x=%d: y=%.4f m  ->  E1=%.4f m\n', ...
        x_esc, y_natural, E_natural);

% Energia critica (misma en toda la seccion, mismo Q)
[~,Ac] = trap_geom(yc,b,m);
Ec = yc + Q^2/(2*g*Ac^2);
fprintf('Ec = yc + Q^2/(2g Ac^2) = %.4f m\n', Ec);

Dmax = E_natural - Ec;
fprintf('Zesc_max (=E1-Ec) = %.4f m   vs   Zesc = %.4f m\n', Dmax, Zesc);

if Zesc > Dmax
  fprintf('Zesc > Zesc_max => el escalon AHOGA/afecta la seccion: aparece remanso M1 aguas arriba\n\n');

  % Nueva energia aguas arriba del escalon (subcritica, rama alta)
  E2 = Ec + Zesc;
  y2 = fsolve(@(y) energia_trap_error(y,b,Q,m,E2), 1.5*yc, opt);
  [E2chk,y4] = Eesp_trap(y2,b,Q,m);  % y4 = alterno supercritico de y2 (misma E2)
  y3 = yc;
  fprintf('E2 (=Ec+Zesc) = %.4f m\n', E2);
  fprintf('y2 (aguas arriba del escalon, subcritico) = %.4f m\n', y2);
  fprintf('y3 (cresta, = yc)                          = %.4f m\n', y3);
  fprintf('y4 (aguas abajo del escalon, supercritico)  = %.4f m\n\n', y4);

  %% Perfil aguas abajo del escalon: M3 desde y4 (x=x_esc) creciendo,
  %% hasta que su conjugado empalme (resalto) con la M2 que viene de la
  %% caida libre (misma M2 de la Parte 1, valida aguas abajo del escalon).
  par3 = [Q b S0 n yc m];
  opt3 = odeset('Events', @(x,y) critico(x,y,par3), 'RelTol',1e-9,'AbsTol',1e-9,'MaxStep',0.5);
  [xM3, yM3] = ode23(@(x,y) rect(x,y,par3), [x_esc L], y4+1e-4, opt3);

  % conjugado de la rama M3 en cada punto
  yconjM3 = nan(size(yM3));
  for i=1:length(yM3)
    if yM3(i) < yc
      [~,yconjM3(i)] = Mom_trap(yM3(i), b, m, Q);
    end
  end

  % M2 (misma de la Parte 1) interpolada en el rango de xM3
  yM2_here = interp1(xM2, yM2, xM3, 'linear');

  diffy = yconjM3 - yM2_here;
  mask = ~isnan(diffy);
  idxs = find(mask(1:end-1) & mask(2:end));
  cambio = idxs(find(diffy(idxs).*diffy(idxs+1) <= 0, 1));

  if ~isempty(cambio)
    i = cambio;
    xA=xM3(i); xB=xM3(i+1); fA=diffy(i); fB=diffy(i+1);
    x_resalto = xA - fA*(xB-xA)/(fB-fA);
    y_sup = interp1(xM3, yM3, x_resalto);
    y_sub = interp1(xM2, yM2, x_resalto);
    fprintf('Resalto hidraulico en x=%.2f m (x_esc+%.2f m):\n', x_resalto, x_resalto-x_esc);
    fprintf('  y (rama supercritica, antes del resalto) = %.4f m\n', y_sup);
    fprintf('  y (rama subcritica = M2 caida libre)      = %.4f m\n\n', y_sub);
  else
    fprintf('No se encontro interseccion conjugado(M3)-M2 en el rango integrado.\n\n');
  end

  fprintf('Como el remanso M1 se disipa acercandose a yn mucho antes de\n');
  fprintf('llegar a la entrada (x=0, a %d m del escalon), el caudal del\n', x_esc);
  fprintf('lago NO cambia: Q = %.4f m3/s (igual que en la Parte 1).\n\n', Q);

else
  fprintf('Zesc <= Zesc_max => el escalon NO afecta el tirante aguas arriba (y1 no cambia)\n\n');
end

fprintf('==================== PARTE 3 ====================\n');
%% Altura maxima de la tuberia que mantiene Q: la M1 aguas arriba del
%% escalon debe haberse relajado a ~yn justo en la entrada (x=0), 2000 m
%% aguas arriba del escalon. Criterio (analogo al 1% de yc en caida
%% libre): se toma como limite y(x=0) = 1.01*yn.
y0_lim = 1.01*yn;
par1u = [Q b S0 n yc m];
opt1u = odeset('Events', @(x,y) critico(x,y,par1u), 'RelTol',1e-9,'AbsTol',1e-9);
[xM1, yM1] = ode23(@(x,y) rect(x,y,par1u), [0 x_esc], y0_lim, opt1u);
y2_max = yM1(end);
[~,A2max] = trap_geom(y2_max,b,m);
E2_max = y2_max + Q^2/(2*g*A2max^2);
Zesc_MAX = E2_max - Ec;

fprintf('Condicion limite: y(x=0) = 1.01*yn = %.4f m\n', y0_lim);
fprintf('Integrando la M1 hasta x=%d m (escalon): y2_max = %.4f m\n', x_esc, y2_max);
fprintf('E(y2_max) = %.4f m   Ec = %.4f m\n', E2_max, Ec);
fprintf('==> Zesc_MAXIMO = E(y2_max) - Ec = %.4f m\n', Zesc_MAX);

