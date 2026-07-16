%% Ejercicio 4, Parte 1 - Examen HHA 5 de febrero 2025 (2025_FEBRERO 2)
% Sistema de enfriamiento: lago (zL=0) -> bombas en paralelo (zA=+3m) ->
% tanque elevado (zT=+20m). Punto de funcionamiento del sistema.
clc; clear; close all;
figure(1); clf; hold on; grid on;

g = 9.81;
rho = 1000;
nu = 1e-6;
eps = 0.15e-3;   % rugosidad absoluta (m)
D = 0.2;         % diametro succion e impulsion (m)
A = pi*D^2/4;

% Succion: lago (zL=0, atm) -> bombas (zA=+3m)
Ls = 20; zs = 0; p1 = 0;
ks = 2 + 0.3;    % valvula de pie (kvp=2) + codo (kcodo=0.3)

% Impulsion: bombas (zA=+3m) -> tanque elevado (zT=+20m, atm, descarga sumergida)
Li = 480; zi = 20; p2 = 0;
ki = 0.3 + 1;    % codo (kcodo=0.3) + descarga sumergida (kdesc=1)

zB = 3;          % cota de las bombas

% Curvas de las bombas (Q en L/s -> m3/s)
Q1 = [0.1 7.8 16.2 24.0 31.8 40.2 48.0 55.8]/1000;
H1 = [36.3 35.7 34.5 32.7 30.3 26.6 22.4 16.9];
eta1 = [2 36 59 73 77 72 59 36];
NPSHr1 = [1.60 1.80 2.20 2.90 3.90 5.50 7.30 9.70];

Q2 = [0.1 5.3 10.8 16.0 21.2 26.8 32.0 37.2]/1000;
H2 = [36.3 35.7 34.5 32.7 30.3 26.6 22.4 16.9];
eta2 = [5 41 63 76 83 84 76 54];
NPSHr2 = [0.70 0.90 1.30 1.90 3.00 4.60 6.40 8.80];

Qmin = max([min(Q1), min(Q2)]);
Qmax = Q1(end) + Q2(end);
Q = linspace(Qmin, Qmax, 400);

Hb1 = interp1(Q1,H1,Q,"pchip");
Hb2 = interp1(Q2,H2,Q,"pchip");
Qeq = Q1 + Q2;                       % caudal equivalente (bombas en paralelo, mismo H)
H_eq = interp1(Qeq, H1, Q, "pchip"); % curva de la bomba equivalente (H igual, Q suma)

plot(Q1,H1,"Color",[1 0.5 0],"LineWidth",1.2);
plot(Q2,H2,"b-","LineWidth",1.2);
plot(Q,H_eq,"Color",[1 0 0],"LineWidth",1.6);

Hm = zeros(size(Q));
fs_v = zeros(size(Q));
fi_v = zeros(size(Q));
for i = 1:length(Q)
    v = Q(i)/A;
    Re = v*D/nu;
    f = colebrook(Re, eps/D);
    fs_v(i) = f; fi_v(i) = f;   % misma tuberia (D, eps) en succion e impulsion

    dHs = (ks + f*Ls/D) * v^2/(2*g);
    dHi = (ki + f*Li/D) * v^2/(2*g);

    HA = zs + p1/(rho*g) - dHs;                 % carga antes de la bomba (succion)
    HB = zi + p2/(rho*g) + dHi;                 % carga despues de la bomba (impulsion)
    Hm(i) = HB - HA;                             % curva de instalacion
end
plot(Q, Hm, 'm-', 'LineWidth', 1.4);

% Punto de funcionamiento: interseccion H_eq(Q) = Hm(Q)
diffH = abs(H_eq - Hm);
[~, idx] = min(diffH);
Qpf = Q(idx); Hpf = H_eq(idx);
f_pf = fs_v(idx);

Q1_pf = interp1(H1, Q1, Hpf, "pchip");
Q2_pf = interp1(H2, Q2, Hpf, "pchip");

plot(Qpf, Hpf, 'o', 'MarkerSize', 7, "MarkerFaceColor",[0.5 0 1], "MarkerEdgeColor","none");
plot([Qpf Qpf], [0 Hpf], 'k--', 'LineWidth', 1.0, 'HandleVisibility','off');
plot([Q1_pf Q1_pf], [0 Hpf], 'k--', 'LineWidth', 0.8, 'HandleVisibility','off');
plot([Q2_pf Q2_pf], [0 Hpf], 'k--', 'LineWidth', 0.8, 'HandleVisibility','off');
plot([0 max(Q)], [Hpf Hpf], 'k--', 'LineWidth', 0.8, 'HandleVisibility','off');

xlabel("Caudal Q [m3/s]"); ylabel("Carga H [m]");
legend("Bomba 1","Bomba 2","Equivalente (paralelo)","Instalacion","Punto de funcionamiento","Location","northeast");
title("Ejercicio 4 - Punto de funcionamiento (bombas en paralelo)");
print('ej4_HQ_parte1.png','-dpng','-r120');

fprintf('===== PUNTO DE FUNCIONAMIENTO =====\n');
fprintf('Q total  = %.4f m3/s = %.2f L/s\n', Qpf, Qpf*1000);
fprintf('H        = %.3f m\n', Hpf);
fprintf('Q Bomba1 = %.4f m3/s = %.2f L/s\n', Q1_pf, Q1_pf*1000);
fprintf('Q Bomba2 = %.4f m3/s = %.2f L/s\n', Q2_pf, Q2_pf*1000);
fprintf('f (Darcy, succion=impulsion, mismo D y eps) en PF = %.4f\n', f_pf);

save('ej4_part1.mat','Q','Hm','H_eq','Qpf','Hpf','Q1_pf','Q2_pf','f_pf', ...
     'Q1','H1','eta1','NPSHr1','Q2','H2','eta2','NPSHr2', ...
     'g','rho','nu','eps','D','A','Ls','zs','p1','ks','Li','zi','p2','ki','zB');
