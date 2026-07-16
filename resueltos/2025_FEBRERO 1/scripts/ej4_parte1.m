clc; clear; close all;
addpath(pwd);

% ==== DATOS ====
g = 9.8; rho = 1000; nu = 1e-6;

% Succion (tanque Ts, cota +4m -> bomba, cota 0m)
Ls = 10; Ds = 0.040; eps_s = 0.003e-3; ks = 4; z1 = 4; p1 = 0;

% Cota de la bomba
zB = 0;

% Impulsion (bomba -> punto D, cota +20m, manometro pm/g=20m minimo)
Li = 5000; Di = 0.200; eps_i = 0.003e-3; ki = 5; z2 = 20;
pm_gamma_req = 20; % m.c.a., minimo requerido en el punto D

% Curva de la bomba
Q_h = [0 2.4 3 3.5 4.2 4.8 5.4 6 6.6 7.5 8.4 9.6 10.8 12 15]; % m3/h
Q = Q_h/3600; % m3/s
H = [70 66.5 65.5 65 64 63 62 60.5 59 57 55 52 49.5 46.5 36];
eta = [10.5 21.75 25.5 28.3 30.5 33 34.8 36 37.2 40.2 40.6 41.85 43.5 44.7 43.3];
NPSHr = [1.5 1.5 1.5 1.5 1.5 1.5 1.55 1.6 1.7 1.85 2 2.4 2.75 3.25 5];

As = pi*Ds^2/4; Ai = pi*Di^2/4;

% ==== Malla de caudal e instalacion (con pm/g FIJO en el minimo requerido) ====
Qmalla = linspace(min(Q), max(Q), 2000);
Hb = interp1(Q, H, Qmalla, 'pchip');

Hinst = zeros(size(Qmalla));
for i=1:length(Qmalla)
  Qi = Qmalla(i);
  vs = Qi/As; Re_s = vs*Ds/nu; fs = colebrook(Re_s, eps_s/Ds);
  dHs = fs*Ls/Ds*vs^2/(2*g) + ks*vs^2/(2*g);
  HA = z1 + p1/(rho*g) + vs^2/(2*g) - dHs;

  vi = Qi/Ai; Re_i = vi*Di/nu; fi = colebrook(Re_i, eps_i/Di);
  dHi = fi*Li/Di*vi^2/(2*g) + ki*vi^2/(2*g);
  HB = z2 + pm_gamma_req + vi^2/(2*g) + dHi;

  Hinst(i) = HB - HA;
end

% ==== Punto de funcionamiento (interseccion bomba/instalacion) ====
[~,idx] = min(abs(Hb-Hinst));
Qpf = Qmalla(idx); Hpf = Hb(idx);
Qpf_h = Qpf*3600;

vs_pf = Qpf/As; Re_s_pf = vs_pf*Ds/nu; fs_pf = colebrook(Re_s_pf, eps_s/Ds);
vi_pf = Qpf/Ai; Re_i_pf = vi_pf*Di/nu; fi_pf = colebrook(Re_i_pf, eps_i/Di);

printf('=== Parte 1b: maximo caudal con pm/g>=20m ===\n');
printf('Qpf = %.4f m3/h = %.6f m3/s\n', Qpf_h, Qpf);
printf('Hpf = %.2f m\n', Hpf);
printf('vs = %.3f m/s, Re_s=%.3e, fs=%.4f\n', vs_pf, Re_s_pf, fs_pf);
printf('vi = %.3f m/s, Re_i=%.3e, fi=%.4f\n', vi_pf, Re_i_pf, fi_pf);

save('-mat','ej4_part1.mat','g','rho','nu','Ls','Ds','eps_s','ks','z1','p1','zB', ...
     'Li','Di','eps_i','ki','z2','pm_gamma_req','Q','H','eta','NPSHr','As','Ai', ...
     'Qpf','Hpf','Qpf_h','vs_pf','vi_pf','fs_pf','fi_pf');

% ==== Grafico ====
figure('visible','off');
plot(Q_h, H, 'b-o','LineWidth',1.5); hold on;
plot(Qmalla*3600, Hinst, 'm-','LineWidth',1.5);
plot(Qpf_h, Hpf, 'ko','MarkerFaceColor','k','MarkerSize',7);
plot([0 Qpf_h],[Hpf Hpf],'k--'); plot([Qpf_h Qpf_h],[0 Hpf],'k--');
legend('Bomba','Instalacion (pm/g=20m fijo)','Punto de funcionamiento','Location','northeast');
xlabel('Q [m^3/h]'); ylabel('H [m]');
title('Ejercicio 4 Parte 1 - Maximo caudal con presion minima');
grid on;
print('ej4_HQ_parte1.png','-dpng','-r150');
