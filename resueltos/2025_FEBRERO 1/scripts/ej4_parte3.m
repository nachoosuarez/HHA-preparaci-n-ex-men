clc; clear; close all;
addpath(pwd);
load('ej4_part1.mat');

patm_gamma = 10.33; % m.c.a. (Teorico Fig 30)
pvap_gamma = 0.24;  % m.c.a., agua a temperatura ambiente (Teorico Fig 30)

vs_pf = Qpf/As;
dHs_pf = fs_pf*Ls/Ds*vs_pf^2/(2*g) + ks*vs_pf^2/(2*g);
HA_pf = z1 + vs_pf^2/(2*g) - dHs_pf; % energia (carga total, incl. cinetica) en la brida de succion

NPSHd = (patm_gamma - pvap_gamma) + HA_pf - zB;
NPSHr_pf = interp1(Q, NPSHr, Qpf, 'pchip');

printf('=== Parte 3: cavitacion ===\n');
printf('dHs (perdida succion) = %.4f m\n', dHs_pf);
printf('HA (energia antes de la bomba) = %.4f m\n', HA_pf);
printf('NPSHdisp = (patm-pvap)/g + HA - zB = %.3f m\n', NPSHd);
printf('NPSHreq (interp tabla en Qpf) = %.3f m\n', NPSHr_pf);
if NPSHd > NPSHr_pf
  printf('NPSHdisp > NPSHreq => la bomba NO cavita\n');
else
  printf('NPSHdisp < NPSHreq => la bomba CAVITA\n');
end
