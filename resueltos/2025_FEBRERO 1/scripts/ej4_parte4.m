clc; clear; close all;
addpath(pwd);
load('ej4_part1.mat');

% ==== 4a) Tipo de acople ====
% En paralelo: Heq(Q)=H_bomba_individual(Q/2) para cada H (misma H, se suman caudales).
% En serie: Qeq(H)=Q_bomba_individual, se suman las H para el mismo Q.
% Como la curva de la bomba es MUY empinada (cae rapido con Q) y la curva de
% instalacion es relativamente plana en este rango, el acople en PARALELO
% permite un aumento de caudal mucho mayor que en serie (en serie, al ser la
% instalacion poco sensible a H, el aumento de caudal es marginal).
printf('=== Parte 4a: tipo de acople ===\n');
printf('El acople en PARALELO permite mayor aumento de caudal.\n');

% ==== 4b) Nuevo punto de funcionamiento (2 bombas en paralelo) ====
Qmalla2 = linspace(min(Q), 2*max(Q), 4000);
Hb1 = interp1(Q, H, min(Qmalla2,max(Q)), 'pchip'); % curva de 1 bomba (para referencia)

% curva equivalente de 2 bombas iguales en paralelo: Qeq = 2*Q para cada H
Qeq = 2*Q;
Heq = interp1(Qeq, H, Qmalla2, 'pchip');

Hinst2 = zeros(size(Qmalla2));
for i=1:length(Qmalla2)
  Qi = Qmalla2(i); % caudal TOTAL (por la conduccion de succion e impulsion, compartida)
  vs = Qi/As; Re_s = vs*Ds/nu; fs = colebrook(Re_s, eps_s/Ds);
  dHs = fs*Ls/Ds*vs^2/(2*g) + ks*vs^2/(2*g);
  HA = z1 + p1/(rho*g) + vs^2/(2*g) - dHs;

  vi = Qi/Ai; Re_i = vi*Di/nu; fi = colebrook(Re_i, eps_i/Di);
  dHi = fi*Li/Di*vi^2/(2*g) + ki*vi^2/(2*g);
  HB = z2 + pm_gamma_req + vi^2/(2*g) + dHi;

  Hinst2(i) = HB - HA;
end

[~,idx2] = min(abs(Heq-Hinst2));
Qpf2 = Qmalla2(idx2); Hpf2 = Heq(idx2);
Qb_pf = Qpf2/2; % caudal de cada bomba individual

printf('\n=== Parte 4b: punto de funcionamiento (2 bombas en paralelo) ===\n');
printf('Qpf_total = %.4f m3/h = %.6f m3/s\n', Qpf2*3600, Qpf2);
printf('Q por bomba = %.4f m3/h\n', Qb_pf*3600);
printf('Hpf = %.2f m\n', Hpf2);
printf('Factor de aumento de caudal Qparte4/Qparte1 = %.3f\n', Qpf2/Qpf);

vs_pf2 = Qpf2/As; Re_s_pf2 = vs_pf2*Ds/nu; fs_pf2 = colebrook(Re_s_pf2, eps_s/Ds);
vi_pf2 = Qpf2/Ai; Re_i_pf2 = vi_pf2*Di/nu; fi_pf2 = colebrook(Re_i_pf2, eps_i/Di);
printf('vs=%.3f m/s Re_s=%.3e fs=%.4f\n', vs_pf2, Re_s_pf2, fs_pf2);
printf('vi=%.3f m/s Re_i=%.3e fi=%.4f\n', vi_pf2, Re_i_pf2, fi_pf2);

eta_b_pf2 = interp1(Q, eta, Qb_pf, 'pchip');
Pb = rho*g*Qb_pf*Hpf2/(eta_b_pf2/100);
Ptot = 2*Pb;
printf('Eficiencia de cada bomba en Q=%.3f m3/h: %.2f %%\n', Qb_pf*3600, eta_b_pf2);
printf('Potencia de cada bomba = %.3f kW ; Potencia total = %.3f kW\n', Pb/1000, Ptot/1000);

% ==== 4c) Cavitacion (2 bombas en paralelo) ====
patm_gamma = 10.33; pvap_gamma = 0.24;
dHs_pf2 = fs_pf2*Ls/Ds*vs_pf2^2/(2*g) + ks*vs_pf2^2/(2*g);
HA_pf2 = z1 + vs_pf2^2/(2*g) - dHs_pf2; % energia (carga total, incl. cinetica) en la brida de succion (comun)
NPSHd2 = (patm_gamma-pvap_gamma) + HA_pf2 - zB;
NPSHr_b_pf2 = interp1(Q, NPSHr, Qb_pf, 'pchip');

printf('\n=== Parte 4c: cavitacion ===\n');
printf('NPSHdisp (bomba 1 = bomba 2, con Q_total por la succion) = %.3f m\n', NPSHd2);
printf('NPSHreq (cada bomba, con su Q individual=%.3f m3/h) = %.3f m\n', Qb_pf*3600, NPSHr_b_pf2);
if NPSHd2 > NPSHr_b_pf2
  printf('NPSHdisp > NPSHreq => las bombas NO cavitan\n');
else
  printf('NPSHdisp < NPSHreq => las bombas CAVITAN\n');
end

figure('visible','off');
plot(Q*3600, H, 'b-o','LineWidth',1.3); hold on;
plot(Qeq*3600, H, 'Color',[1 0.5 0],'LineWidth',1.5);
plot(Qmalla2*3600, Hinst2, 'm-','LineWidth',1.5);
plot(Qpf2*3600, Hpf2, 'ko','MarkerFaceColor','k','MarkerSize',7);
plot(Qb_pf*3600, Hpf2, 'ks','MarkerFaceColor','g','MarkerSize',6);
legend('Bomba individual (B1=B2)','2 Bombas en paralelo (Beq)','Instalacion','Punto de funcionamiento (total)','Punto de funcionamiento (c/bomba)','Location','northeast');
xlabel('Q [m^3/h]'); ylabel('H [m]');
title('Ejercicio 4 Parte 4 - Dos bombas en paralelo');
grid on;
print('ej4_HQ_parte4.png','-dpng','-r150');
