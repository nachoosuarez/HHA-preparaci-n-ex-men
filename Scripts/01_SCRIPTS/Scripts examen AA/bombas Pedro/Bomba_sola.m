clc; clear; close all;
figure(1); clf; hold on; grid on;

%========================
% DATOS
%========================
g = 9.81;
ro = 997;
nu = 1e-6;
epsilon1 = 0.000002;
epsilon2 = 0.000002;

% Succión
Ls = 10;
Ds = 0.06;
z1 = -5;
p1 = 0;
ks = 5;

% Cota bomba
zB = 0;

% Impulsión
Li = 100;
D1 = 0.06;
z2 = 18;
p2 = 0;
ki = 27;
Dt = 0.06;

%========================
% BOMBA
%========================
Q = [0.125 0.5 1 1.5 2 2.5 3 3.5 4 4.5 5 5.5]/1000;
H = [31.40 31.30 31.10 30.80 30.50 30.10 29.70 ...
     29.20 28.60 28.00 26.90 25.20];
eta = [23 52 66 74 78 82 85 88 89 88 86 83];
NPSHr = [1.50 1.60 1.75 1.90 2.05 2.30 2.65 ...
         3.00 3.35 3.65 4.00 4.30];

%========================
% MALLA DE CAUDAL
%========================
Qmalla = linspace(min(Q), max(Q), 200);

Hb = interp1(Q, H, Qmalla, "pchip");

Hm = zeros(size(Qmalla));
NPSHdisp = zeros(size(Qmalla));

%========================
% CÁLCULOS
%========================
for i = 1:length(Qmalla)

    Qi = Qmalla(i);

    As = pi*Ds^2/4;
    Ai = pi*D1^2/4;
    At = pi*Dt^2/4;

    %---- Succión
    vs = Qi/As;
    Re1 = vs*Ds/nu;
    f1 = colebrook(Re1, epsilon1/Ds);

    deltadistS = f1 * Ls * vs^2 / (2*Ds*g);
    deltalocS  = ks * vs^2 / (2*g);
    deltaS = deltadistS + deltalocS;

    HA = z1 + p1/(ro*g) + vs^2/(2*g) - deltaS;

    %---- Impulsión
    vi = Qi/Ai;
    Re2 = vi*D1/nu;
    f2 = colebrook(Re2, epsilon1/D1);

    deltadistI = f2 * Li * vi^2 / (2*D1*g);
    deltalocI  = ki * vi^2 / (2*g);
    deltaI = deltadistI + deltalocI;

    vt = Qi/At;
    HB = z2 + p2/(ro*g) + vt^2/(2*g) + deltaI;

    %---- Curva de la instalación
    Hm(i) = HB - HA;

    %---- NPSH disponible
    NPSHdisp(i) = 10.1 + HA - zB;

endfor

%========================
% FIGURA 1 – H-Q y ?-Q
%========================
plot(Qmalla, Hb, 'b-', 'LineWidth', 1.5, ...
     'DisplayName','Curva característica de la bomba (H-Q)');

plot(Qmalla, Hm, 'm-', 'LineWidth', 1.3, ...
     'DisplayName','Curva de la instalación (H-Q)');

% Punto de funcionamiento
[~, idx] = min(abs(Hb - Hm));
Qpf = Qmalla(idx);
Hpf = Hb(idx);

plot(Qpf, Hpf, 'bo', 'MarkerSize', 7, ...
     'MarkerFaceColor','b', ...
     'DisplayName','Punto de funcionamiento');

% Proyecciones punteadas H-Q
plot([Qpf Qpf], [0 Hpf], 'k--', 'LineWidth', 1.0, ...
     'DisplayName','Proyección vertical PF (H-Q)');

plot([0 Qpf], [Hpf Hpf], 'k--', 'LineWidth', 0.8, ...
     'DisplayName','Proyección horizontal PF (H-Q)');

% Curva de eficiencia
plot(Q, eta, '-', 'Color',[1 0.5 0], 'LineWidth',1.3, ...
     'DisplayName','Curva de eficiencia (?-Q)');

% Proyecciones punteadas ?-Q
eta_pf = interp1(Q, eta, Qpf, "pchip");

plot([Qpf Qpf], [0 eta_pf], 'k--', 'LineWidth', 0.8, ...
     'DisplayName','Proyección vertical PF (?-Q)');

plot([0 Qpf], [eta_pf eta_pf], 'k--', 'LineWidth', 0.8, ...
     'DisplayName','Proyección horizontal PF (?-Q)');

xlabel('Caudal Q [m^3/s]');
ylabel('Carga H [m] / Eficiencia ? [%]');
legend('Location','eastoutside');

%========================
% RESULTADOS
%========================
fprintf('Q funcionamiento = %.5f m3/s\n', Qpf);
fprintf('H funcionamiento = %.2f m\n', Hpf);
fprintf('Eficiencia en Qpf = %.2f %%\n', eta_pf);

P = ro*g*Qpf*Hpf/(eta_pf/100);
fprintf('Potencia al eje = %.2f kW\n', P/1000);

%========================
% CAVITACIÓN
%========================
NPSHdisp_pf = NPSHdisp(idx);
NPSHr_pf = interp1(Q, NPSHr, Qpf, "pchip");

if NPSHdisp_pf < NPSHr_pf
    fprintf('La bomba CAVITA\n');
else
    fprintf('La bomba NO cavita\n');
end

%========================================================
% FIGURA 2 – NPSH - Q
%========================================================
figure(2); clf; hold on; grid on;

% Curva NPSH disponible
plot(Qmalla, NPSHdisp, 'b-', 'LineWidth', 1.5, ...
     'DisplayName','NPSH disponible');

% Curva NPSH requerido
plot(Q, NPSHr, 'r-', 'LineWidth', 1.5, ...
     'DisplayName','NPSH requerido');

% Punto de funcionamiento
plot(Qpf, NPSHdisp_pf, 'bo', 'MarkerSize', 7, ...
     'MarkerFaceColor','b', ...
     'DisplayName','Condición de operación');

% Proyecciones punteadas
plot([Qpf Qpf], [0 NPSHdisp_pf], 'k--', 'LineWidth', 1.0, ...
     'DisplayName','Proyección vertical PF');

plot([0 Qpf], [NPSHdisp_pf NPSHdisp_pf], 'k--', 'LineWidth', 0.8, ...
     'DisplayName','Proyección horizontal PF');

xlabel('Caudal Q [m^3/s]');
ylabel('NPSH [m]');
legend('Location','eastoutside');





%========================================================
% Datos para el examen:

%========================================================