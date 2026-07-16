% Ejercicio 4 - Parte 3: minima presion en Ti para que la bomba no cavite.
% NPSH disponible solo depende de Q (y de la succion), no de Pi. Se busca el
% caudal limite Qlim donde NPSHd(Q)=NPSHr(Q); para Q>Qlim cavita. La minima
% presion Pi es la que hace que el punto de funcionamiento sea exactamente
% Q=Qlim (mayor Pi => curva de instalacion mas alta => menor Q operado).
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

Patm_menos_Pv_sobre_gamma = 10.09;

function f = fD(Q, D, A, nu, eps)
  v = Q/A;
  Re = v*D/nu;
  f = colebrook(Re, eps/D);
endfunction

NPSHd_fun = @(Q) Patm_menos_Pv_sobre_gamma + zs - zB - ...
  (ks + fD(Q,D,A,nu,eps)*Ls/D) * Q^2/(2*g*A^2);

NPSHr_fun = @(Q) interp1(Qb, NPSHr_tab, Q, "pchip");

Qlim = fzero(@(Q) NPSHd_fun(Q) - NPSHr_fun(Q), 0.12);
Hlim = interp1(Qb, Hb, Qlim, "pchip");
f_lim = fD(Qlim, D, A, nu, eps);

dHs = (ks + f_lim*Ls/D) * Qlim^2/(2*g*A^2);
dHi = (ki + f_lim*Li/D) * Qlim^2/(2*g*A^2);

Pi_min = gamma * (Hlim - (zi - zs) - dHs - dHi);

fprintf('Qlim = %.4f m3/s (NPSHd = NPSHr = %.2f m)\n', Qlim, NPSHd_fun(Qlim));
fprintf('f en Qlim = %.4f\n', f_lim);
fprintf('H bomba en Qlim = %.2f m\n', Hlim);
fprintf('Pi minima = %.3e Pa\n', Pi_min);
