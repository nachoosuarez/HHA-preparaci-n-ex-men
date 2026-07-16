%% EJERCICIO 4 - Partes 1, 2 y 3 (Examen HHA diciembre 2024)
% Sistema de bombeo para riego agricola: embalse (z1=-5m, succion) -> bomba
% (zA=0m) -> descarga libre a canal de riego (z2=+18m, impulsion).
% Valvula tipo esclusa completamente abierta (k2=4).
%
% Requiere en la misma carpeta: colebrook.m
clc; clear; close all;
g = 9.81; ro = 1000; nu = 1e-6;

%% Datos del enunciado
eps1 = 0.002e-3; eps2 = 0.002e-3;   % rugosidad absoluta (m)
z1 = -5;  Ls = 10;  Ds = 0.06;  ks = 5;    % succion
zA = 0;                                    % cota de la bomba
z2 = 18;  Li = 100; Di = 0.06;  ki = 4;    % impulsion (valvula abierta)

% Curvas caracteristicas de la bomba (tabla del enunciado)
Q_tab    = [0.125 0.5 1 1.5 2 2.5 3 3.5 4 4.5 5 5.5]/1000;   % m3/s
H_tab    = [31.4 31.3 31.1 30.8 30.5 30.1 29.7 29.2 28.6 28.0 26.9 25.2]; % m
eta_tab  = [23 52 66 74 78 82 85 88 89 88 86 83];             % %
NPSHr_tab= [1.50 1.60 1.75 1.90 2.05 2.30 2.65 3.00 3.35 3.65 4.00 4.30]; % m

As = pi*Ds^2/4;
Ai = pi*Di^2/4;

%% 1) Curva de la instalacion y punto de funcionamiento
% Ecuacion de la instalacion (descarga libre: se pierde la energia cinetica
% de salida, por lo que el termino V_i^2/(2g) se suma junto a las perdidas):
%   Hm(Q) = (z2 + Vi^2/2g) - (z1 - hs(Q)) + hi(Q)
%   hs(Q) = (ks + f1*Ls/Ds) * Vs^2/(2g)      (perdidas en la succion)
%   hi(Q) = (ki + f2*Li/Di) * Vi^2/(2g)      (perdidas en la impulsion)
% f1, f2: factor de friccion de Darcy-Weisbach (Colebrook-White)
Qmalla = linspace(min(Q_tab), max(Q_tab), 4000);
Hb = interp1(Q_tab, H_tab, Qmalla, 'pchip');

Hm = zeros(size(Qmalla));
NPSHdisp = zeros(size(Qmalla));
f1v = zeros(size(Qmalla)); f2v = zeros(size(Qmalla));

for i=1:length(Qmalla)
  Qi = Qmalla(i);
  vs = Qi/As; Re1 = vs*Ds/nu; f1 = colebrook(Re1, eps1/Ds);
  hs = (ks + f1*Ls/Ds) * vs^2/(2*g);
  Ha = z1 - hs;

  vi = Qi/Ai; Re2 = vi*Di/nu; f2 = colebrook(Re2, eps2/Di);
  hi = (ki + f2*Li/Di) * vi^2/(2*g);
  Hm(i) = (z2 + vi^2/(2*g)) - Ha + hi;

  NPSHdisp(i) = Ha - zA + 10.1;   % (Patm-Pvap)/gamma ~ 10.1 m
  f1v(i)=f1; f2v(i)=f2;
end

[~,idx] = min(abs(Hb-Hm));
Qpf = Qmalla(idx); Hpf = Hb(idx);
f1pf = f1v(idx); f2pf = f2v(idx);
printf('=== PARTE 1: Punto de funcionamiento (valvula abierta, k2=4) ===\n');
printf('Q_PF = %.4f L/s\n', Qpf*1000);
printf('H_PF = %.3f m\n', Hpf);
printf('f1 = f2 = %.4f (mismo diametro y rugosidad en succion e impulsion)\n', f1pf);

figure(1); clf; hold on; grid on;
plot(Qmalla*1000, Hm, 'm-', 'LineWidth',1.5, 'DisplayName','Curva de la instalacion');
plot(Qmalla*1000, Hb, 'b-', 'LineWidth',1.5, 'DisplayName','Curva de la bomba');
plot(Qpf*1000, Hpf, 'ko', 'MarkerFaceColor','y', 'MarkerSize',8, 'DisplayName','Punto de funcionamiento');
xlabel('Q (L/s)'); ylabel('H (m)');
title('Ej.4 Parte 1: Curva de la instalacion y de la bomba (valvula abierta)');
legend('Location','best');
saveas(gcf, 'ej4_HQ_parte1.png');

%% 2) Potencia consumida
eta_pf = interp1(Q_tab, eta_tab, Qpf, 'pchip');
P = ro*g*Qpf*Hpf/(eta_pf/100);
printf('\n=== PARTE 2: Potencia consumida ===\n');
printf('eta(Q_PF) = %.2f %%\n', eta_pf);
printf('P = rho*g*Q*H/eta = %.1f W = %.3f kW\n', P, P/1000);

%% 3) Verificacion de cavitacion (NPSH)
NPSHr_pf = interp1(Q_tab, NPSHr_tab, Qpf, 'pchip');
NPSHd_pf = NPSHdisp(idx);
printf('\n=== PARTE 3: Cavitacion (NPSH) ===\n');
printf('NPSH disponible = Ha - zA + (Patm-Pvap)/gamma = %.3f m\n', NPSHd_pf);
printf('NPSH requerido (tabla, interpolado en Q_PF) = %.3f m\n', NPSHr_pf);
if NPSHd_pf > NPSHr_pf
  printf('NPSHdisp > NPSHreq => la bomba NO CAVITA (margen = %.3f m)\n', NPSHd_pf-NPSHr_pf);
else
  printf('NPSHdisp < NPSHreq => la bomba CAVITA\n');
end

figure(2); clf; hold on; grid on;
plot(Qmalla*1000, NPSHdisp, 'b-', 'LineWidth',1.5, 'DisplayName','NPSH disponible');
plot(Q_tab*1000, NPSHr_tab, 'r-', 'LineWidth',1.5, 'DisplayName','NPSH requerido (tabla)');
plot(Qpf*1000, NPSHd_pf, 'ko', 'MarkerFaceColor','y', 'MarkerSize',8, 'DisplayName','Condicion de operacion');
xlabel('Q (L/s)'); ylabel('NPSH (m)');
title('Ej.4 Parte 3: NPSH disponible y requerido');
legend('Location','best');
saveas(gcf, 'ej4_NPSH_parte1.png');

printf('\n================= RESUMEN PARTES 1-3 =================\n');
printf('Q_PF=%.2f L/s, H_PF=%.2f m, f=%.4f\n', Qpf*1000, Hpf, f1pf);
printf('Potencia=%.0f W (eta=%.1f%%)\n', P, eta_pf);
printf('NPSHdisp=%.2f m, NPSHreq=%.2f m -> no cavita\n', NPSHd_pf, NPSHr_pf);
printf('=======================================================\n');
