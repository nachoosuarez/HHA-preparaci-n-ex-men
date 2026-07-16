% Ejercicio 4 - Parte 2: Q=0.11 m3/s -> presion Pi requerida, carga de la
% bomba, factor de friccion, y verificacion de cavitacion (NPSH disponible
% vs NPSH requerido).
clc; clear;

g = 9.81;
rho = 1000;
gamma = rho*g;
nu = 1e-6;
eps = 0.05e-3;
D = 0.35;
A = pi*D^2/4;

Ls = 25; ks = 4; zs = -1;
Li = 2500; ki = 8; zi = 9;
zB = 0;

Qb = [0 0.05 0.10 0.15 0.20 0.25];
Hb = [53 51 48 43 37 30];
NPSHr_tab = [5 6 7.8 10 13.7 20];

Patm_menos_Pv_sobre_gamma = 10.09; % Patm/gamma - Pv/gamma (agua ~20-25C)

Q = 0.11;

Hm = interp1(Qb, Hb, Q, "pchip");

v = Q/A;
Re = v*D/nu;
f = colebrook(Re, eps/D);

dHs = (ks + f*Ls/D) * Q^2/(2*g*A^2);
dHi = (ki + f*Li/D) * Q^2/(2*g*A^2);

% Hm = Pi/gamma + (zi - zs) + dHs + dHi  =>  Pi = gamma*(Hm - (zi-zs) - dHs - dHi)
Pi = gamma * (Hm - (zi - zs) - dHs - dHi);

NPSHd = Patm_menos_Pv_sobre_gamma + zs - dHs - zB;
NPSHr = interp1(Qb, NPSHr_tab, Q, "pchip");

fprintf('Q = %.2f m3/s\n', Q);
fprintf('v = %.4f m/s , Re = %.0f , f (Colebrook) = %.5f\n', v, Re, f);
fprintf('Carga de la bomba Hm = %.2f m\n', Hm);
fprintf('dHs (perdida succion) = %.4f m , dHi (perdida impulsion) = %.4f m\n', dHs, dHi);
fprintf('Presion requerida en Ti: Pi = %.3e Pa\n', Pi);
fprintf('NPSH disponible = %.2f m\n', NPSHd);
fprintf('NPSH requerido  = %.2f m\n', NPSHr);
if NPSHd > NPSHr
  fprintf('=> NO cavita (NPSHd > NPSHr)\n');
else
  fprintf('=> CAVITA (NPSHd <= NPSHr)\n');
end
