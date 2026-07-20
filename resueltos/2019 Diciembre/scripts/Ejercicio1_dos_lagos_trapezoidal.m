% Ejercicio1_dos_lagos_trapezoidal.m — Examen HHA 16/dic/2019, Ejercicio 1.
% Canal trapezoidal (L=370m, b=1.5m, m=2, S0=0.0003, n=0.011) que conecta
% dos lagos: Lago A (entrada, hLA=1.24m, dato fijo) y Lago B (salida,
% hLB variable). Usa el script canónico dos_lagos_trap.m (shooting: itera
% Q hasta que la energía en la entrada cierre con hLA, con la BC de
% salida que corresponda a cada modo).
%
% a) hLB=1.30 m dado -> Q de descarga, clasificación M/S, perfil.
% b) hLB variable -> rango de hLB para el cual Q no depende de hLB
%    (control crítico en la salida) y valor de ese Q.
% c) Con el perfil de b), zonas del canal en riesgo de erosión si
%    tau_max=4 Pa (tau0(y)=gamma*Rh*Sf, decreciente con y).
clear all
addpath(pwd);

b=1.5; m=2; S0=0.0003; n=0.011; L=370; g=9.8; gamma=9800;
hLA=1.24;

%% ---------- Parte a) hLB = 1.30 m (dato) ----------
hLB_a = 1.30;
[Qa,yn_a,yc_a,y0_a,yL_a] = dos_lagos_trap(hLA,hLB_a,b,m,S0,n,L,'hLB_dado');
if yn_a > yc_a; clasif_a = 'M (mild)'; else; clasif_a = 'S (steep)'; end

fprintf('\n===== PARTE a) hLB = %.2f m =====\n', hLB_a);
fprintf('Q = %.3f m3/s\n', Qa);
fprintf('yn = %.4f m , yc = %.4f m -> canal tipo %s\n', yn_a, yc_a, clasif_a);
fprintf('y(entrada, x=0)  = %.4f m\n', y0_a);
fprintf('y(salida, x=L)   = %.4f m (=hLB)\n', yL_a);
fprintf('Perfil subcritico en toda la longitud (Fr<1) -> curva M1, SIN resalto.\n');

%% ---------- Parte b) rango de hLB con Q independiente de hLB ----------
[Qb,yn_b,yc_b,y0_b,yL_b,xb,yb] = dos_lagos_trap(hLA,[],b,m,S0,n,L,'critico_salida');
if yn_b > yc_b; clasif_b = 'M (mild)'; else; clasif_b = 'S (steep)'; end

fprintf('\n===== PARTE b) rango de hLB con Q independiente de hLB =====\n');
fprintf('Qmax = %.3f m3/s  (constante para 0 < hLB <= %.3f m)\n', Qb, yc_b);
fprintf('yn = %.4f m , yc = %.4f m -> canal tipo %s\n', yn_b, yc_b, clasif_b);
fprintf('y(entrada, x=0) = %.4f m\n', y0_b);
fprintf('y(salida, x=L)  = %.4f m (= yc, control critico "interno" en la salida)\n', yL_b);
fprintf('Para hLB > %.3f m: Q depende de hLB (igual mecanismo que en a).\n', yc_b);
fprintf('Para hLB <= %.3f m: la salida pasa a critica: Q=%.3f m3/s no cambia mas.\n', yc_b, Qb);

%% ---------- Parte c) zonas de erosion (tau_max = 4 Pa) sobre el perfil de b) ----------
tau_max = 4; % Pa

tau = zeros(size(yb));
for i=1:numel(yb)
  [~,A,~,R] = trap_geom(yb(i),b,m);
  Sf = (n^2*Qb^2)/(A^2 * R^(4/3));
  tau(i) = gamma*R*Sf;
end

% xb va de L (salida) a 0 (entrada); tau decrece con y, o sea es maxima en la salida
[~,i_lim] = min(abs(tau-tau_max));
y_lim = interp1(tau, yb, tau_max);
x_lim = interp1(tau, xb, tau_max);
Lerosion = L - x_lim; % longitud medida desde la salida (Lago B) hacia aguas arriba

fprintf('\n===== PARTE c) erosion (tau_max = %.1f Pa) sobre el perfil de b) =====\n', tau_max);
fprintf('tau0 en la salida (y=yc=%.4f m)  = %.3f Pa  (> tau_max -> ERODE)\n', yb(1), tau(1));
fprintf('tau0 en la entrada (y=%.4f m)    = %.3f Pa  (< tau_max -> seguro)\n', yb(end), tau(end));
fprintf('tau0 = tau_max en y = %.4f m , a x = %.2f m (medido desde la entrada)\n', y_lim, x_lim);
fprintf('==> riesgo de erosion en los ULTIMOS %.1f m del canal (desde la salida/Lago B)\n', Lerosion);
fprintf('    es decir, para y < %.3f m (tramo final, tirantes bajos, Sf y tau altos)\n', y_lim);
