clc; clear; close all;
figure(1); clf; hold on; grid on;
% Conversion 1 m.c.a = 1*1000*9.8 
g = 9.81; %m/s2
ro=1000; %densidad del agua en kg/m3
nu = 0.000001;
epsilon1 = 0.00005; %m
epsilon2 = 0.00005; %m

% Succión
Ls = 20; %metros
Ds = 0.11; %metros
z1 = -4; %metros
ks = 6; %coeficiente de perdida de carga localizada (suma de todas la perdidas de carga loc)
p1 = 0; %SI ES TANQUE O CAIDA LIBRE ES 0

% Cota de las bombas
zB = 0.5; %metros

% Impulsión
Li = 0; %metros
Di = 0.08; %metros
%Li2 = 850; %metros
%Di2 = 0.25; %metros
ki = 0; %coeficiente de perdida de carga localizada
z2 = 0.5; %metros
p2 = 196000; %SI ES TANQUE O CAIDA LIBRE ES 0

% Bomba 1
%PASAR EL Q A M3/S (dividido 1000)
Q1 = [0.5 2 4 6 8 10 12 14 16 18 20 22]/1000; %en m3/s
H1 = [26.75 26.4 26.1 25.6 25 24.4 23.7 23.1 22.5 21.4 19.8 18]; %en m
eta1 = [23 51.8 65.6 73.6 78.2 81.7 85.1 88.6 89.7 88.6 86.3 82.8]; %en%
NPSHr1 = [2.7 3.24 3.46 3.78 4.1 4.64 5.29 6.05 6.7 7.34 7.99 8.53]; %en m

% Bomba 2
Q2 = [0.5 2 4 6 8 10 12 14 16 18 20 22]/1000;
H2 = [26.75 26.4 26.1 25.6 25 24.4 23.7 23.1 22.5 21.4 19.8 18];
eta2 = [23 51.8 65.6 73.6 78.2 81.7 85.1 88.6 89.7 88.6 86.3 82.8];
NPSHr2 = [2.7 3.24 3.46 3.78 4.1 4.64 5.29 6.05 6.7 7.34 7.99 8.53];

% Rango total posible del caudal según las curvas reales
Qmin = max([min(Q1), min(Q2)]);

if numel(Q1) == numel(Q2)
    % Misma cantidad de puntos: Qmax = suma de los últimos caudales
    Qmax = Q1(end) + Q2(end);
else
    % Distinta cantidad de puntos: Qmax = último valor del vector más largo
    Qmax = max([Q1(end), Q2(end)]);
end

% Malla caudal
Q = linspace(Qmin, Qmax, 200);

% Interpolación
Hb1 = interp1(Q1,H1,Q,"pchip");
Hb2 = interp1(Q2,H2,Q,"pchip");
Qb = Q1 + Q2;
H_eq = interp1(Qb, H1, Q, "pchip");  % H de bomba equivalente vs Q

% GRÁFICAS, curvas caracteristicas
plot(Q1,H1,"Color",[1 0.5 0],"LineWidth",1.0); %curva bomba 1
plot(Q2,H2,"b-","LineWidth",1.0); %curva bomba 2
plot(Q,H_eq,"Color",[1 0 0],"LineWidth",1.5); %curva bomba equivalente

Hm = zeros(size(Q));
NPSHdisp = zeros(size(Q));
NPSHdisp1=[];
NPSHdisp2=[];

for i = 1:length(Q)

    As = pi*(Ds^2)/4;
    Ai = pi*(Di^2)/4;
    %Ai2 = pi*(Di2^2)/4;

    % Succión
    vs = Q(i)/As;
    Re1 = vs*Ds/nu;
    f1 = colebrook(Re1,epsilon1/Ds);
    deltadistS = f1 * Ls * vs^2 / (2*Ds*g);
    deltalocS = (ks* (vs^2) / (2*g));
    deltaS =deltadistS + deltalocS;
    HA = z1 + (p1/(ro*g)) + ((vs^2)/(2*g)) - deltaS; %carga antes de entrar a la bomba

    % Impulsión tramo 1
    vi = Q(i)/Ai;
    Re2 = vi*Di/nu;
    f2 = colebrook(Re2,epsilon1/Di);
    deltadistI = f2 * Li * vi^2 / (2*Di*g);
    deltalocI = (ki* (vi^2) / (2*g));
    deltaI = deltadistI + deltalocI;

    %Por si hay un trapo con otro diametro o epsilon ya sea impusion o succion
    % Impulsión tramo 2
    %vi2 = Q(i)/Ai2;
    %Re3 = vi2*Di2/nu;
    %f3 = colebrook(Re3,epsilon2/Di2);
    %deltadistI2 = f3 * Li2 * vi2^2 / (2*Di2*g);
    %deltalocI2 = (ki* (vi^2) / (2*g));
    %deltaI2 = deltadeltadistI1 + deltadistI2 + deltalocI2;

    %si tengo una tobera a la entrada o salida cambia la velocidad en el termino cinetico de carga HA o HB
    %Agrego una  nueva area de tobera

    HB = z2 + (p2/(ro*g)) + ((vi^2)/(2*g)) + deltaI; %carga despues de la bomba
    % Instalación
    Hm(i) = HB - HA;

    % NPSH disponible para las bombas
    NPSHdisp1 = [NPSHdisp1 10.1 + HA - zB];       % bomba 1 curva verde oscuro
    NPSHdisp2 = [NPSHdisp2 10.1 + HA - zB]; % bomba 2 curva celeste

endfor
plot(Q, Hm, 'm-', 'LineWidth', 1.2);   % curva de instalación

% Punto de funcionamiento: intersección H_eq(Q) = Hm(Q)
diffH = abs(H_eq - Hm);
[~, idx] = min(diffH);

Qpf = Q(idx);        % caudal en el PF
Hpf = H_eq(idx);     % (o Hm(idx), son prácticamente iguales)

plot(Qpf, Hpf, 'o', 'MarkerSize', 6, ...
    "MarkerFaceColor",[0.5 0 1], "MarkerEdgeColor","none");

% Caudal de cada bomba a la carga de funcionamiento Hpf
Q1_pf = interp1(H1, Q1, Hpf, "pchip");   % caudal bomba 1 en Hpf
Q2_pf = interp1(H2, Q2, Hpf, "pchip");   % caudal bomba 2 en Hpf

% Líneas punteadas
% vertical para el caudal total (equivalente + instalación)
plot([Qpf Qpf], [0 Hpf], 'k--', 'LineWidth', 1.0, 'HandleVisibility','off');

% verticales para cada bomba individual
plot([Q1_pf Q1_pf], [0 Hpf], 'k--', 'LineWidth', 0.8, 'HandleVisibility','off');
plot([Q2_pf Q2_pf], [0 Hpf], 'k--', 'LineWidth', 0.8, 'HandleVisibility','off');

% línea horizontal a la carga de funcionamiento
plot([0 max(Q)], [Hpf Hpf], 'k--', 'LineWidth', 0.8, 'HandleVisibility','off');

xlabel("Caudal Q [m³/s]");
ylabel("Carga H [m]");

%Resultados
fprintf("Q funcionamiento = %.4f m3/s\n", Qpf);
fprintf("H funcionamiento = %.2f m\n", Hpf);
fprintf("Q en curva Bomba 1 (Q1_pf) = %.4f m3/s\n", Q1_pf);
fprintf("Q en curva Bomba 2 (Q2_pf) = %.4f m3/s\n", Q2_pf);

%----------------------------------%
%Nos fijamos si las bombas cavitan
% Graficar NPSH disponible
plot(Q, NPSHdisp1, '-', 'Color',[0 0.5 0],'LineWidth',1.2);
plot(Q, NPSHdisp2, '-', 'Color',[0 0.75 1],'LineWidth',1.2);

% Graficar NPSHr (requerido) de las bombas
plot(Q1, NPSHr1, '--', 'Color',[0 0.5 0],'LineWidth',1.0);
plot(Q2, NPSHr2, '--', 'Color',[0 0.75 1],'LineWidth',1.0);

legend("Bomba 1","Bomba 2","Serie","Instalación","Punto de funcionamiento", ...
       "NPSHdisp Bomba 1","NPSHdisp Bomba 2","NPSHr Bomba 1","NPSHr Bomba 2");

%Chequeo de cavitación

% NPSH disponible en el PF (son iguales)
NPSHdisp_pf = interp1(Q, NPSHdisp1, Qpf, "pchip");

% NPSH requerido de cada bomba en su caudal de funcionamiento
NPSHr1_pf = interp1(Q1, NPSHr1, Q1_pf, "pchip");
NPSHr2_pf = interp1(Q2, NPSHr2, Q2_pf, "pchip");

%Chequeo para bomba 1
if NPSHdisp_pf < NPSHr1_pf

    fprintf("La bomba 1 CAVITA \n");

else
    fprintf("La bomba 1 NO cavita\n");
end
% chequeo para bomba 2

if NPSHdisp_pf < NPSHr2_pf
    fprintf("La bomba 2 CAVITA \n");

else
    fprintf("La bomba 2 NO cavita \n");
end

%======================
% RESUMEN NUMÉRICO
%======================
fprintf("\n----- RESUMEN NPSH -----\n");
fprintf("NPSH disponible en PF       = %.3f m\n", NPSHdisp_pf);
fprintf("NPSHr Bomba 1 en Q1_pf      = %.3f m\n", NPSHr1_pf);
fprintf("NPSHr Bomba 2 en Q2_pf      = %.3f m\n", NPSHr2_pf);
fprintf("-------------------------\n\n");

%------------------------------------%
%POTENCIA
% GRAFICO DE EFICIENCIAS EN OTRA FIGURA
figure(2); clf; hold on; grid on;

% Calcular eficiencias en Qpf
eta1_pf = interp1(Q1, eta1, Q1_pf, "pchip");
eta2_pf = interp1(Q2, eta2, Q2_pf, "pchip");

plot(Q1, eta1, 'Color',[1 0.5 0], 'LineWidth',1.2);
plot(Q2, eta2, 'b-',           'LineWidth',1.2);

xlabel("Caudal Q [m³/s]");
ylabel("Eficiencia [%]");

legend("Eficiencia Bomba 1", "Eficiencia Bomba 2", "location", "southeast");

% Eficiencias y cargas en el punto de trabajo
%---------------------------------------------
% Marcar los puntos de funcionamiento en el gráfico
%---------------------------------------------
plot(Q1_pf, eta1_pf, 'o', 'MarkerSize', 4, ...
    "MarkerFaceColor",[1 0.5 0], "MarkerEdgeColor","none", "HandleVisibility","off");

plot(Q2_pf, eta2_pf, 'o', 'MarkerSize', 4, ...
    "MarkerFaceColor",'b', "MarkerEdgeColor","none", "HandleVisibility","off");

% Líneas punteadas para cada bomba, en su propio Q_pf
plot([Q1_pf Q1_pf], [0 eta1_pf], 'k--', 'LineWidth', 0.8, "HandleVisibility","off");
plot([Q2_pf Q2_pf], [0 eta2_pf], 'k--', 'LineWidth', 0.8, "HandleVisibility","off");

plot([0 max(Q1)], [eta1_pf eta1_pf], 'k--', 'LineWidth', 0.8, "HandleVisibility","off");
plot([0 max(Q2)], [eta2_pf eta2_pf], 'k--', 'LineWidth', 0.8, "HandleVisibility","off");

%---------------------------------------------
% Resultados de eficiencias
%---------------------------------------------
fprintf("Eficiencia Bomba 1 en Q1_pf = %.2f %%\n", eta1_pf);
fprintf("Eficiencia Bomba 2 en Q2_pf = %.2f %%\n", eta2_pf);


% Cálculo de potencias (en W)
P1 = (ro * g * Q1_pf * Hpf) / (eta1_pf/100);
P2 = (ro * g * Q2_pf * Hpf) / (eta2_pf/100);
Ptotal = P1 + P2;

% Conversión a kW
P1_kW = P1 / 1000;
P2_kW = P2 / 1000;
Ptotal_kW = Ptotal / 1000;

fprintf("Potencia Bomba 1 = %.3f kW\n", P1_kW);
fprintf("Potencia Bomba 2 = %.3f kW\n", P2_kW);
fprintf("Potencia Total   = %.3f kW\n", Ptotal_kW);


