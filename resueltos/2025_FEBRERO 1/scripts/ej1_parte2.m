% Examen HHA 27/02/2025 - Ejercicio 1, Parte 2
% Zonas del canal donde la tension rasante de fondo supera tau_max = 42 Pa.
clc; clear; close all;
addpath(pwd);
load('part1.mat'); % Q, b, m, n, S0, L, x_s2, y_s2, yn, yc

gama  = 9800;   % peso especifico del agua [N/m3]
Tmax  = 42;     % tension rasante maxima admisible [Pa]

% tau0 = gama*R*Sf = gama*Q^2*n^2 / (A^2 R^(1/3))  (formula de tension rasante
% de fondo en flujo uniforme/gradualmente variado, Teorico Sec. 2.1 / 2.3)
tau_fun = @(y) gama .* (Q.^2 .* n.^2) ./ ...
    ((b.*y+m.*y.^2).^2 .* (((b.*y+m.*y.^2))./(b+2.*y.*sqrt(1+m.^2))).^(1/3));

printf('tau en y=yc (x=0)   = %.2f Pa\n', tau_fun(yc));
printf('tau en y=yn         = %.2f Pa\n', tau_fun(yn));

% y para el cual tau=Tmax (tau decrece con y: a menor tirante, mayor velocidad
% y mayor tension de corte, para un Q fijo)
y_tau42 = fsolve(@(y) tau_fun(y)-Tmax, 1.0);
printf('y para el cual tau = %.0f Pa: y = %.4f m\n', Tmax, y_tau42);

% Tension a lo largo del perfil (curva S2 de la Parte 1)
tau_x = tau_fun(y_s2);
idx_peligro = find(tau_x >= Tmax);
x_cross = interp1(tau_x, x_s2, Tmax);

printf('\ntau en x=0   = %.2f Pa\n', tau_x(1));
printf('tau en x=%dm = %.2f Pa\n', L, tau_x(end));
printf('\ntau supera %.0f Pa desde x = %.2f m hasta x = %d m\n', Tmax, x_cross, L);
printf('(es decir, en los ultimos %.2f m del canal, cerca de la descarga al Lago B)\n', L-x_cross);

save('-mat','part2.mat','Tmax','y_tau42','x_cross');

figure('visible','off');
plot(x_s2, tau_x, 'b-','LineWidth',2); hold on;
plot([0 L],[Tmax Tmax],'r--','LineWidth',1.5);
plot(x_cross, Tmax, 'ko','MarkerFaceColor','k');
xlabel('x [m]'); ylabel('\tau_0 [Pa]');
legend('\tau_0(x)','\tau_{max}=42 Pa','Location','northwest');
title('Ejercicio 1 Parte 2 - Tension rasante a lo largo del canal');
grid on;
print('ej1_tau.png','-dpng','-r150');
