% Bomba_sola.m — calcula el punto de funcionamiento de UNA bomba única
% contra una instalación con tramo de succión + tramo de impulsión
% (con pérdidas de carga distribuidas por Colebrook y localizadas por k).
% Entradas: g, rho, nu, rugosidades (epsilon1/2), geometría de succión
% (Ls,Ds,z1,p1,ks) e impulsión (Li,D1,z2,p2,ki,Dt), y la curva de la
% bomba como vectores Q, H, eta, NPSHr (del catálogo del fabricante).
% Salidas: gráfico H-Q de bomba vs. instalación, punto de funcionamiento
% (Qpf,Hpf), eficiencia y potencia en ese punto.
% Usar cuando: sistema de bombeo con una sola bomba y un único punto de
% operación (no hay bombas en serie/paralelo). Requiere colebrook.m.
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

% Succi�n
Ls = 15;
Ds = 0.15;
z1 = -4;
p1 = 0;
ks = 1;

% Cota bomba
zB = 0;

% Impulsi�n
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
% C�LCULOS
%========================
for i = 1:length(Qmalla)

    Qi = Qmalla(i);

    As = pi*Ds^2/4;
    Ai = pi*D1^2/4;
    At = pi*Dt^2/4;

    %---- Succi�n
    vs = Qi/As;
    Re1 = vs*Ds/nu;
    f1 = colebrook(Re1, epsilon1/Ds);

    deltadistS = f1 * Ls * vs^2 / (2*Ds*g);
    deltalocS  = ks * vs^2 / (2*g);
    deltaS = deltadistS + deltalocS;

    HA = z1 + p1/(ro*g) + vs^2/(2*g) - deltaS;

    %---- Impulsi�n
    vi = Qi/Ai;
    Re2 = vi*D1/nu;
    f2 = colebrook(Re2, epsilon1/D1);

    deltadistI = f2 * Li * vi^2 / (2*D1*g);
    deltalocI  = ki * vi^2 / (2*g);
    deltaI = deltadistI + deltalocI;

    vt = Qi/At;
    HB = z2 + p2/(ro*g) + vt^2/(2*g) + deltaI;

    %---- Curva de la instalaci�n
    Hm(i) = HB - HA;

    %---- NPSH disponible
    % OJO: HA (linea 79) es la carga TOTAL (piezometrica+cinetica) en la
    % brida de succion, con su termino vs^2/(2g). En la definicion de NPSH
    % ese mismo termino cinetico se vuelve a sumar (NPSH=p/gamma+v^2/2g-
    % pvap/gamma) y por Bernoulli se CANCELA algebraicamente contra el que
    % ya trae HA -- por eso hay que restarlo aca para no contarlo dos
    % veces (bug detectado y corregido resolviendo 2023 dic Ej.4, cruzando
    % contra la solucion oficial: con el termino duplicado daba NPSHdisp
    % 0.4 m mas alto que el valor oficial).
    % OJO 2: esta resta de vs^2/(2g) vale SOLO si z1 es una superficie
    % libre grande (v~0 real, pero HA le suma igual vs^2/2g "de mas" por
    % comodidad). Si en cambio z1 es un MANOMETRO dentro de la propia
    % caneria de succion (velocidad real Vs alli, no una superficie
    % libre), HA=z1+p1/(rho g)+vs^2/2g-deltaS ya cuenta la energia una
    % sola vez correctamente y NO hay que restar vs^2/(2g) de nuevo (ver
    % RESUMEN_TEORICO.md, C4, "distinguir la trampa de arriba de un
    % manometro dentro de la propia caneria" -- 2022 dic, Ej.4: restando
    % de mas da NPSHdisp=9.05m, sin restar da 9.80m, que es el oficial).
    NPSHdisp(i) = 10.1 + HA - zB - vs^2/(2*g);

endfor

%========================
% FIGURA 1 � H-Q y ?-Q
%========================
plot(Qmalla, Hb, 'b-', 'LineWidth', 1.5, ...
     'DisplayName','Curva caracter�stica de la bomba (H-Q)');

plot(Qmalla, Hm, 'm-', 'LineWidth', 1.3, ...
     'DisplayName','Curva de la instalaci�n (H-Q)');

% Punto de funcionamiento
[~, idx] = min(abs(Hb - Hm));
Qpf = Qmalla(idx);
Hpf = Hb(idx);

plot(Qpf, Hpf, 'bo', 'MarkerSize', 7, ...
     'MarkerFaceColor','b', ...
     'DisplayName','Punto de funcionamiento');

% Proyecciones punteadas H-Q
plot([Qpf Qpf], [0 Hpf], 'k--', 'LineWidth', 1.0, ...
     'DisplayName','Proyecci�n vertical PF (H-Q)');

plot([0 Qpf], [Hpf Hpf], 'k--', 'LineWidth', 0.8, ...
     'DisplayName','Proyecci�n horizontal PF (H-Q)');

% Curva de eficiencia
plot(Q, eta, '-', 'Color',[1 0.5 0], 'LineWidth',1.3, ...
     'DisplayName','Curva de eficiencia (?-Q)');

% Proyecciones punteadas ?-Q
eta_pf = interp1(Q, eta, Qpf, "pchip");

plot([Qpf Qpf], [0 eta_pf], 'k--', 'LineWidth', 0.8, ...
     'DisplayName','Proyecci�n vertical PF (?-Q)');

plot([0 Qpf], [eta_pf eta_pf], 'k--', 'LineWidth', 0.8, ...
     'DisplayName','Proyecci�n horizontal PF (?-Q)');

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
% CAVITACI�N
%========================
NPSHdisp_pf = NPSHdisp(idx);
NPSHr_pf = interp1(Q, NPSHr, Qpf, "pchip");

if NPSHdisp_pf < NPSHr_pf
    fprintf('La bomba CAVITA\n');
else
    fprintf('La bomba NO cavita\n');
end

%========================================================
% FIGURA 2 � NPSH - Q
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
     'DisplayName','Condici�n de operaci�n');

% Proyecciones punteadas
plot([Qpf Qpf], [0 NPSHdisp_pf], 'k--', 'LineWidth', 1.0, ...
     'DisplayName','Proyecci�n vertical PF');

plot([0 Qpf], [NPSHdisp_pf NPSHdisp_pf], 'k--', 'LineWidth', 0.8, ...
     'DisplayName','Proyecci�n horizontal PF');

xlabel('Caudal Q [m^3/s]');
ylabel('NPSH [m]');
legend('Location','eastoutside');





%========================================================
% Datos para el examen:
% Si quiero sacar la altura a la que llega la bomba 
%Me tienen que dar un manometro esa presion va *1000*9.8
%Dsp lo que hago es ir al script de la bomba y poner
%En succi�n los datos como van
%En impulsion pongo:
%Largo=0
%Ki=0
%z altura bomba
%P2 la del manometro 
%Corro y saco Q_inst y lo meto en la ecuaci�n:
%(Z_bomba+P/ro+ Q^2/2gA^2)= Z_quiero + ((f2 L2/D2)+K2)Q^2/2gA^2
%========================================================