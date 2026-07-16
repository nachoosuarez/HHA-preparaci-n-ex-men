% Ejercicio 4 - Parte 1: rango de caudales y cargas segun Pi in [1e5, 3e5] Pa
% Instalacion: tanque de succion Ts (superficie libre, atm) a zs=-1m,
% bomba a zB=0m, tanque de impulsion Ti (presurizado, presion Pi) con
% superficie a zi=9m. Misma tuberia D=0.35m, eps=0.05mm para succion (Ls=25m,
% ks=4) e impulsion (Li=2500m, ki=8).
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

% Curva de la bomba
Qb = [0 0.05 0.10 0.15 0.20 0.25];
Hb = [53 51 48 43 37 30];

Qmalla = linspace(0.001, 0.25, 2000);
Hbomba = interp1(Qb, Hb, Qmalla, "pchip");

function f = fD(Q, D, A, nu, eps)
  v = Q/A;
  Re = v*D/nu;
  f = colebrook(Re, eps/D);
endfunction

function H = H_inst(Q, Pi, gamma, zi, zs, D, A, g, nu, eps, Ls, ks, Li, ki)
  f = fD(Q, D, A, nu, eps);
  dHs = (ks + f*Ls/D) * Q^2/(2*g*A^2);
  dHi = (ki + f*Li/D) * Q^2/(2*g*A^2);
  H = Pi/gamma + (zi - zs) + dHs + dHi;
endfunction

Pi_list = [1e5, 3e5];
for k = 1:2
  Pi = Pi_list(k);
  g_of_Q = @(Q) interp1(Qb, Hb, Q, "pchip") - H_inst(Q, Pi, gamma, zi, zs, D, A, g, nu, eps, Ls, ks, Li, ki);
  Qpf = fzero(g_of_Q, 0.12);
  Hpf = interp1(Qb, Hb, Qpf, "pchip");
  fprintf('Pi = %.0e Pa -> Q = %.4f m3/s , H = %.2f m\n', Pi, Qpf, Hpf);
end
