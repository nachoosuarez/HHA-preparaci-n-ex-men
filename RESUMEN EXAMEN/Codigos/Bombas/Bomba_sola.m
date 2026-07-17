% Bomba_sola.m â€” calcula el punto de funcionamiento de UNA bomba Ãºnica
% contra una instalaciÃ³n con tramo de succiÃ³n + tramo de impulsiÃ³n
% (con pÃ©rdidas de carga distribuidas por Colebrook y localizadas por k).
% Entradas: g, rho, nu, rugosidades (epsilon1/2), geometrÃ­a de succiÃ³n
% (Ls,Ds,z1,p1,ks) e impulsiÃ³n (Li,D1,z2,p2,ki,Dt), y la curva de la
% bomba como vectores Q, H, eta, NPSHr (del catÃ¡logo del fabricante).
% Salidas: grÃ¡fico H-Q de bomba vs. instalaciÃ³n, punto de funcionamiento
% (Qpf,Hpf), eficiencia y potencia en ese punto.
% Usar cuando: sistema de bombeo con una sola bomba y un Ãºnico punto de
% operaciÃ³n (no hay bombas en serie/paralelo). Requiere colebrook.m.
clc; clear; close all;
figure(1); clf; hold on; grid on;

%========================
% DATOS
%========================
g = 9.81;
ro = 997;
nu = 1e-6;
epsilon1 = 0.00005;
epsilon2 = 0.00005;

% Succión
Ls = 15;
Ds = 0.15;
z1 = -4;
p1 = 0;
ks = 1;

% Cota bomba
zB = 0;

% Impulsión
Li = 600;
D1 = 0.15;
z2 = 30;
p2 = 0;
ki = 5;
Dt = 0.05;

%========================
% BOMBA
%========================
Q = [0.00 0.01 0.02 0.03 0.04 0.05 0.06 0.07];
H = [65.0 64.0 60.0 54.0 48.0 41.0 31.0 18.0];
eta = [0 35 56 68 67 60 46 26];
NPSHr = [3.2 3.4 3.7 4.4 5.3 6.8 8.5 10.8];

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
% Si quiero sacar la altura a la que llega la bomba 
%Me tienen que dar un manometro esa presion va *1000*9.8
%Dsp lo que hago es ir al script de la bomba y poner
%En succión los datos como van
%En impulsion pongo:
%Largo=0
%Ki=0
%z altura bomba
%P2 la del manometro 
%Corro y saco Q_inst y lo meto en la ecuación:
%(Z_bomba+P/ro+ Q^2/2gA^2)= Z_quiero + ((f2 L2/D2)+K2)Q^2/2gA^2
%========================================================