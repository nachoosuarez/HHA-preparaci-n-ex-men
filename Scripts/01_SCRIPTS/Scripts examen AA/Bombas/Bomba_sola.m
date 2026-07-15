clc; clear; close all;
figure(1); clf; hold on; grid on;

%Datos
g = 9.81; %m/s2
ro=997; %densidad del agua en kg/m3
nu = 0.000001;
epsilon1 = 0.00001; %m
epsilon2 = 0.00001; %m

% Succión
Ls = 20; %metros
Ds = 0.045; %metros
z1 = 0; %metros
p1=1e+5; %en caso de estar en tanque abierto poner 0, el e significa x10
ks = 6;

% Cota de la bomba
zB = 1; %metros

% Impulsión
Li = 80; %metros
D1 = 0.045; %metros
z2 = 15; %metros
p2=0; %SI ES DESCARGA LIBRE O TANQUE ES 0
ki = 5;
Dt=0.03; % m

% Bomba (datos)
%IMPORTANTE Q EN M3/S
Q = [0.00025   0.001   0.002   0.003   0.004   0.005   0.006   0.007   0.008   0.009   0.010   0.011];
H  = [50.83 50.16 49.59 48.64 47.5 46.36 45.03 43.89 42.75 40.66 37.62 34.2];
eta   = [23 51.75 65.55 73.6 78.2 81.65 85.1 88.55 89.7 88.55 86.25 82.8];
NPSHr = [2.7 3.2 3.5 3.8 4.1 4.6 5.3 6.1 6.7 7.3 8 8.5];

% Malla caudal PARA INSTALACIÓN (mismo rango que la bomba)
Qmalla = linspace(min(Q), max(Q), 200);

% Interpolación curva de la bomba en la malla
Hb = interp1(Q, H, Qmalla, "pchip");

Hm = zeros(size(Qmalla));
NPSHdisp = [];

for i = 1:length(Qmalla)

    Qi = Qmalla(i);

    As = pi*(Ds^2)/4;
    Ai = pi*(D1^2)/4;
    At = pi*(Dt^2)/4; %area tobera

    % Succión
    vs = Qi/As;
    Re1 = vs*Ds/nu;
    f1 = colebrook(Re1,epsilon1/Ds);
    deltadistS = f1 * Ls * vs^2 / (2*Ds*g);
    deltalocS = (ks* (vs^2) / (2*g));
    deltaS = deltadistS+ deltalocS;
    HA = z1 + (p1/(ro*g)) + ((vs^2)/(2*g)) - deltaS;

    % Impulsión tramo 1
    vi = Qi/Ai;
    Re2 = vi*D1/nu;
    f2 = colebrook(Re2,epsilon1/D1);
    deltalocI = (ki* (vi^2) / (2*g));
    deltadistI = f2 * Li * vi^2 / (2*D1*g);
    deltaI = deltadistI+ deltalocI;

    vt = Qi/At; % velocidad en la tobera
    HB = z2 + (p2/(ro*g)) + ((vt^2)/(2*g)) + deltaI;

    % Instalación
    Hm(i) = HB - HA;

    % NPSH disponible para la bomba
    NPSHdisp = [NPSHdisp 10.1 + HA - zB];

endfor

% ----- GRÁFICAS -----
plot(Qmalla, Hb, "LineWidth", 1.5);        % curva de la bomba
plot(Qmalla, Hm, 'm-', 'LineWidth', 1.2);  % curva de la instalación

% Punto de funcionamiento
diffH = abs(Hb - Hm);
[~, idx] = min(diffH);

Qpf = Qmalla(idx);
Hpf = Hb(idx);

plot(Qpf, Hpf, 'o', 'MarkerSize', 6, ...
    "MarkerFaceColor",[0.5 0 1], "MarkerEdgeColor","none");

% Líneas punteadas
Hpf = interp1(Q, H, Qpf, "pchip");

plot([Qpf Qpf], [0 Hpf], 'k--', 'LineWidth', 1.0, 'HandleVisibility','off');
plot([0 Qpf], [Hpf Hpf], 'k--', 'LineWidth', 0.8, 'HandleVisibility','off');

xlabel("Caudal Q [m³/s]");
ylabel("Carga H [m]");

%Resultados
fprintf("Q funcionamiento = %.4f (mismas unidades que Q)\n", Qpf);
fprintf("H funcionamiento = %.2f m\n", Hpf);
fprintf("H en curva Bomba  (Hpf) = %.2f m\n", Hpf);

%POTENCIA
% GRAFICO DE EFICIENCIAS

% Calcular eficiencia en Qpf
eta_pf = interp1(Q, eta, Qpf, "pchip");   % [%]

% Curva de eficiencias (sin etiquetas)
plot(Q, eta, 'Color',[1 0.5 0], 'LineWidth',1.2);

% LÍNEAS PUNTEADAS PARA EL PF
plot(Qpf, eta_pf, 'o', 'MarkerSize', 4, ...
     "MarkerFaceColor",[1 0.5 0], "MarkerEdgeColor","none", "HandleVisibility","off");

plot([Qpf Qpf], [0 eta_pf], 'k--', 'LineWidth', 0.8, "HandleVisibility","off");
plot([0 Qpf],  [eta_pf eta_pf], 'k--', 'LineWidth', 0.8, "HandleVisibility","off");

% Resultados de eficiencia
fprintf("Eficiencia bomba en Qpf = %.2f %%\n", eta_pf);

% Calculo de potencia
P = (ro * g * Qpf * Hpf) / (eta_pf/100);   % [W]

fprintf("Potencia al eje = %.2f kW\n", P/1000);

%----------------------------------------------------------%
%--Chequeo de cavitación--

% NPSH disponible de la bomba  en el punto de funcionamiento
NPSHdisp_pf = NPSHdisp(idx);

% NPSH requerido de la bomba en el punto de funcionamiento
NPSHr_pf = interp1(Q, NPSHr, Qpf, "pchip");

if NPSHdisp_pf < NPSHr_pf

    fprintf("La bomba 1 CAVITA \n");


else
    fprintf("La bomba 1 NO cavita\n");

end

