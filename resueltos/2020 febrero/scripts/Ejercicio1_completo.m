% Ejercicio1_completo.m — Examen HHA 28/feb/2020, Ejercicio 1 (30 pts),
% resuelto de punta a punta.
%
% Un lago (nivel hL=1.2 m sobre el fondo) descarga a un canal trapezoidal
% infinito (b=1.5 m, m=1, S0=0.005, n=0.009).
%   1) Determinar Q, clasificar M/S, dibujar la superficie libre.
%   2) A partir de x=700 m el canal pasa a ser RECTANGULAR (b=1.5 m,
%      n=0.02, misma S0). Determinar Q, clasificar ambos tramos y
%      dibujar la superficie libre completa (con resalto si corresponde).
%
% Requiere (mismo directorio): trap_geom.m, rect.m, rect_rect.m,
% critico.m, froude_trap.m, froude_rect.m, manning_trap.m,
% manning_rect.m, rect_geom.m, Mom_rect.m, sistema_lago_M.m,
% control_critico_lago_trap.m.
clear all; close all; clc;
addpath(pwd);
opt = optimset('Display','off');
g = 9.81;

%% ===================== PARTE 1: canal trapezoidal =====================
b_t = 1.5; m_t = 1; S0 = 0.005; n_t = 0.009; hL = 1.2;

% Hipotesis (a): canal M, y_entrada=yn (sistema_lago_M.m)
sol_M = fsolve(@(v) sistema_lago_M(v,b_t,m_t,n_t,S0,hL), [3.5 0.5], opt);
Q_M = sol_M(1); yn_M = sol_M(2);
yc_M = fsolve(@(y) froude_trap(y,[Q_M b_t m_t]), yn_M, opt);
hipM_ok = yn_M > yc_M;

% Hipotesis (b): canal S, y_entrada=yc (control_critico_lago_trap.m)
[Q_S, yc_S] = control_critico_lago_trap(hL,b_t,m_t,[0.1 20]);
yn_S = fsolve(@(y) manning_trap(y,[Q_S b_t S0 n_t m_t]), yc_S*0.7, opt);
hipS_ok = yn_S < yc_S;

fprintf('=========== PARTE 1: canal trapezoidal (0-700 m si se modifica) ===========\n');
fprintf('Hipotesis M (y(0)=yn): Q=%.4f, yn=%.4f, yc=%.4f -> %s\n', ...
        Q_M, yn_M, yc_M, merge(hipM_ok,'CONSISTENTE','descartada (yn<yc)'));
fprintf('Hipotesis S (y(0)=yc): Q=%.4f, yc=%.4f, yn=%.4f -> %s\n\n', ...
        Q_S, yc_S, yn_S, merge(hipS_ok,'CONSISTENTE -> CANAL S, curva S2','descartada'));

Q = Q_S; yc_trap = yc_S; yn_trap = yn_S;

% Perfil S2 completo (canal sin modificar, x=0 a x grande)
par_t = [Q b_t S0 n_t yc_trap m_t];
opt1 = odeset('Events',@(x,y) critico(x,y,par_t),'RelTol',1e-10,'AbsTol',1e-12);
[xS2,yS2] = ode23(@(x,y) rect(x,y,par_t),[0 700],yc_trap-1e-4,opt1);
y700 = yS2(end);
fprintf('Perfil S2: yc=%.4f m (x=0) -> y=%.4f m (x=700 m, yn=%.4f m, diff %.2f%%)\n\n', ...
        yc_trap, y700, yn_trap, 100*(y700-yn_trap)/yn_trap);

%% ===================== PARTE 2: tramo rectangular desde 700 m ==========
b_r = 1.5; n_r = 0.02; % mismo S0

ycR = fsolve(@(y) froude_rect(y,[Q b_r]), (Q^2/(g*b_r^2))^(1/3), opt);
ynR = fsolve(@(y) manning_rect(y,[Q b_r S0 n_r]), 1.5, opt);
tipoII = merge(ynR>ycR,'M (mild)','S (steep)');

fprintf('=========== PARTE 2: tramo rectangular (x>700 m) ===========\n');
fprintf('Mismo Q=%.4f m3/s (tramo de entrada supercritico: el cambio aguas\n', Q);
fprintf('abajo no puede modificar el control critico en la boca del lago).\n');
fprintf('yc_rect=%.4f m , yn_rect=%.4f m -> CANAL %s\n', ycR, ynR, tipoII);
fprintf('y(700+)=%.4f m < yc_rect -> entra SUPERCRITICO (curva M3)\n\n', y700);

% FGV1 = M3 (supercritico), forward desde x'=0
par_r = [Q b_r S0 n_r ycR];
opt2 = odeset('Events',@(x,y) critico(x,y,par_r),'RelTol',1e-11,'AbsTol',1e-13);
[xM3,yM3] = ode23(@(x,y) rect_rect(x,y,par_r),[0 400],y700,opt2);

% FGV2 = subcritica, backward desde lejos (y->yn_rect)
opt3 = odeset('RelTol',1e-11,'AbsTol',1e-13);
[xSub,ySub] = ode23(@(x,y) rect_rect(x,y,par_r),[400 0],ynR*1.0002,opt3);
[xSub,ix] = sort(xSub); ySub = ySub(ix);

% Conjugado de FGV1 (formula cerrada rectangular) vs FGV2 -> resalto
ySub_on_M3 = interp1(xSub,ySub,xM3,'linear','extrap');
yconjM3 = nan(size(yM3));
for i=1:length(yM3)
  [~,yconjM3(i)] = Mom_rect(yM3(i),b_r,Q);
end
d = yconjM3 - ySub_on_M3;
idx = find(d(1:end-1).*d(2:end) <= 0, 1);
xa=xM3(idx); xb=xM3(idx+1); fa=d(idx); fb=d(idx+1);
x_resalto = xa - fa*(xb-xa)/(fb-fa);
y1_resalto = interp1(xM3,yM3,x_resalto);
y2_resalto = interp1(xM3,yconjM3,x_resalto);

fprintf('RESALTO a x'' = %.2f m despues de la transicion (x = %.2f m desde el lago)\n', ...
        x_resalto, 700+x_resalto);
fprintf('  y1 (antes, supercritico) = %.4f m\n', y1_resalto);
fprintf('  y2 (despues, ~yn_rect)   = %.4f m\n', y2_resalto);
fprintf('Aguas abajo del resalto: flujo ~uniforme a yn_rect = %.4f m (canal M, infinito)\n', ynR);

function s = merge(cond,a,b)
  if cond, s=a; else, s=b; end
end
