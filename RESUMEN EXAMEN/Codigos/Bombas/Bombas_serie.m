% Bombas_serie.m — calcula el punto de funcionamiento de DOS bombas
% iguales o distintas conectadas en SERIE (mismo caudal, cargas H1+H2 se
% suman) contra una instalación con succión + impulsión.
% Entradas: geometría de succión/impulsión (L,D,z,p,k,epsilon), y curvas
% de catálogo Q1,H1,eta1,NPSHr1 y Q2,H2,eta2,NPSHr2 de cada bomba.
% Salidas: gráfico H-Q (bombas individuales, curva serie equivalente,
% instalación), punto de funcionamiento, chequeo de cavitación (NPSHdisp
% vs NPSHr) para cada bomba, y potencias/eficiencias en el PF.
% Usar cuando: dos bombas trabajan en serie (se suman las alturas a
% igual caudal). Requiere colebrook.m.
clc; clear; close all;
figure(1); clf; hold on; grid on;

g = 9.81; %m/s2
ro=1000; %densidad del agua en kg/m3
nu = 0.000001;
epsilon1 = 0.00005; %m
epsilon2 = 0.00005; %m

% Succión
Ls = 20; %metros
Ds = 0.08; %metros
z1 = -0.5; %metros
ks = 6; %coeficiente de perdida de carga localizada (suma de todas la perdidas de carga loc)
p1 = 0; %SI ES TANQUE O CAIDA LIBRE ES 0

% Cota de las bombas
zB = 0.2; %metros

% Impulsión
Li = 75; %metros
Di = 0.08; %metros
%Li2 = 850; %metros
%Di2 = 0.25; %metros
ki = 4.5; %coeficiente de perdida de carga localizada
z2 = 12; %metros
p2 = 120000; %SI ES TANQUE O CAIDA LIBRE ES 0

% Bomba 1
% para pasar Q de l/s a m3/s divido entre 1000 el vector (/1000 al final)
Q1 = [0.25 1 2 3 4 5 6 7 8 9 10 11]/1000; %en m3/s
H1 = [17.4 17.2 17 16.6 16.3 15.9 15.4 15 14.6 13.9 12.9 11.7]; % en m
eta1 = [23.2 52.2 66.1 74.2 78.9 82.4 85.8 89.3 87 83.5]; % en %
NPSHr1 = [3 3.6 3.8 4.2 4.6 5.2 5.9 6.7 7.4 8.2 8.9 9.5]; %en m

% Bomba 2
Q2 = [0.25 1 2 3 4 5 6 7 8 9 10 11]/1000;
H2 = [17.4 17.2 17 16.6 16.3 15.9 15.4 15 14.6 13.9 12.9 11.7];
eta2 = [23.2 52.2 66.1 74.2 78.9 82.4 85.8 89.3 87 83.5];
NPSHr2 = [3 3.6 3.8 4.2 4.6 5.2 5.9 6.7 7.4 8.2 8.9 9.5];

% Rango total posible del caudal según las curvas reales
Qmin = max([min(Q1), min(Q2)]);
Qmax = min([max(Q1), max(Q2)]);   % solo hasta donde AMBAS bombas tienen datos

% Malla caudal
Q = linspace(Qmin, Qmax, 200);

% Interpolación
Hb1 = interp1(Q1,H1,Q,"pchip");
Hb2 = interp1(Q2,H2,Q,"pchip");
Hb = Hb1 + Hb2;

% GRÁFICAS
plot(Q1,H1,"Color",[1 0.5 0],"LineWidth",1.0);
plot(Q2,H2,"b-","LineWidth",1.0);
plot(Q,Hb,"Color",[1 0 0],"LineWidth",1.5);

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
    % OJO: se resta vs^2/(2*g) porque HA (linea 87) ya es carga TOTAL
    % (piezometrica+cinetica) y ese termino se cancela algebraicamente en
    % la definicion de NPSH (ver nota igual en Bomba_sola.m; bug detectado
    % y corregido resolviendo 2023 dic Ej.4 contra la solucion oficial).
    NPSHdisp1 = [NPSHdisp1 10.1 + HA - zB - vs^2/(2*g)];       % bomba 1 curva verde oscuro
    NPSHdisp2 = [NPSHdisp2 10.1 + HA - zB - vs^2/(2*g) + Hb1(i)]; % bomba 2 curva celeste

endfor
plot(Q, Hm, 'm-', 'LineWidth', 1.2);

% Punto de funcionamiento
diffH = abs(Hb - Hm);
[~, idx] = min(diffH);

Qpf = Q(idx);
Hpf = Hb(idx);

plot(Qpf, Hpf, 'o', 'MarkerSize', 6, ...
    "MarkerFaceColor",[0.5 0 1], "MarkerEdgeColor","none");

% Líneas punteadas
H1pf = interp1(Q1, H1, Qpf, "pchip");
H2pf = interp1(Q2, H2, Qpf, "pchip");

plot([Qpf Qpf], [0 Hpf], 'k--', 'LineWidth', 1.0, 'HandleVisibility','off');
plot([0 Qpf], [Hpf Hpf], 'k--', 'LineWidth', 0.8, 'HandleVisibility','off');
plot([0 Qpf], [H1pf H1pf], 'k--', 'LineWidth', 0.8, 'HandleVisibility','off');
plot([0 Qpf], [H2pf H2pf], 'k--', 'LineWidth', 0.8, 'HandleVisibility','off');

xlabel("Caudal Q [m³/s]");
ylabel("Carga H [m]");
title("Ejercicio 5","fontsize",20);

%Resultados
fprintf("Q funcionamiento = %.4f m3/s\n", Qpf);
fprintf("H funcionamiento = %.2f m\n", Hpf);
fprintf("H en curva Bomba 1 (H1pf) = %.2f m\n", H1pf);
fprintf("H en curva Bomba 2 (H2pf) = %.2f m\n", H2pf);

%Nos fijamos si las bombas cavitan
% Graficar NPSH disponible
plot(Q, NPSHdisp1, '-', 'Color',[0 0.5 0],'LineWidth',1.2);
plot(Q, NPSHdisp2, '-', 'Color',[0 0.75 1],'LineWidth',1.2);

% Graficar NPSHr (requerido) de las bombas
plot(Q1, NPSHr1, '--', 'Color',[0 0.5 0],'LineWidth',1.0);
plot(Q2, NPSHr2, '--', 'Color',[0 0.75 1],'LineWidth',1.0);

legend("Bomba 1","Bomba 2","Serie","Instalación","Punto de funcionamiento", ...
       "NPSHdisp Bomba 1","NPSHdisp Bomba 2","NPSHr Bomba 1","NPSHr Bomba 2");

%Chequeo de cavitación y nueva cota del tanque de succión

%Chequeo para bomba 1
% NPSH disponible de la bomba 1 en el punto de funcionamiento
NPSHdisp1_pf = NPSHdisp1(idx);

% NPSH requerido de la bomba 1 en el punto de funcionamiento
NPSHr1_pf = interp1(Q1, NPSHr1, Qpf, "pchip");

if NPSHdisp1_pf < NPSHr1_pf

    fprintf("La bomba 1 CAVITA \n");

else
    fprintf("La bomba 1 NO cavita\n");
end
% chequeo para bomba 2
% NPSH disponible de la bomba 2 en el punto de funcionamiento
NPSHdisp2_pf = NPSHdisp2(idx);

% NPSH requerido de la bomba 2 en el punto de funcionamiento
NPSHr2_pf = interp1(Q2, NPSHr2, Qpf, "pchip");

if NPSHdisp2_pf < NPSHr2_pf
    fprintf("La bomba 2 CAVITA \n");

else
    fprintf("La bomba 2 NO cavita \n");
end

%======================
% RESUMEN NPSH
%======================
fprintf("\n----- RESUMEN NPSH -----\n");
fprintf("NPSHdisp Bomba 1 (PF)   = %.3f m\n", NPSHdisp1_pf);
fprintf("NPSHdisp Bomba 2 (PF)   = %.3f m\n", NPSHdisp2_pf);
fprintf("NPSHr   Bomba 1 (PF)    = %.3f m\n", NPSHr1_pf);
fprintf("NPSHr   Bomba 2 (PF)    = %.3f m\n", NPSHr2_pf);
fprintf("-------------------------\n\n");

%------------------------------%
%POTENCIA
% GRAFICO DE EFICIENCIAS EN OTRA FIGURA
figure(2); clf; hold on; grid on;

% Calcular eficiencias en Qpf
eta1_pf = interp1(Q1, eta1, Qpf, "pchip");
eta2_pf = interp1(Q2, eta2, Qpf, "pchip");

plot(Q, interp1(Q1, eta1, Q, "pchip"), 'Color',[1 0.5 0], 'LineWidth',1.2);
plot(Q, interp1(Q2, eta2, Q, "pchip"), 'b-', 'LineWidth',1.2);

xlabel("Caudal Q [m³/s]");
ylabel("Eficiencia [%]");
title("Ejercicio 5","fontsize",20);

legend("Eficiencia Bomba 1", "Eficiencia Bomba 2", "location", "southeast");


% LÍNEAS PUNTEADAS PARA EL PF

plot(Qpf, eta1_pf, 'o', 'MarkerSize', 4, "MarkerFaceColor",[1 0.5 0], "MarkerEdgeColor","none", "HandleVisibility", "off");
plot(Qpf, eta2_pf, 'o', 'MarkerSize', 4, "MarkerFaceColor",'b', "MarkerEdgeColor","none", "HandleVisibility", "off");

plot([Qpf Qpf], [0 max(eta1_pf,eta2_pf)], 'k--', 'LineWidth', 0.8, "HandleVisibility","off");

plot([0 Qpf], [eta1_pf eta1_pf], 'k--', 'LineWidth', 0.8, "HandleVisibility","off");
plot([0 Qpf], [eta2_pf eta2_pf], 'k--', 'LineWidth', 0.8, "HandleVisibility","off");

%Resultados
fprintf("Eficiencia Bomba 1 en Qpf = %.2f %%\n", eta1_pf);
fprintf("Eficiencia Bomba 2 en Qpf = %.2f %%\n", eta2_pf);

%Calculo de potencias
% Potencias en W
P1 = (ro * g * Qpf * H1pf) / (eta1_pf/100);
P2 = (ro * g * Qpf * H2pf) / (eta2_pf/100);
Ptotal = P1 + P2;

% Conversión a kW
P1_kW = P1 / 1000;
P2_kW = P2 / 1000;
Ptotal_kW = Ptotal / 1000;

fprintf("Potencia Bomba 1 = %.3f kW\n", P1_kW);
fprintf("Potencia Bomba 2 = %.3f kW\n", P2_kW);
fprintf("Potencia Total   = %.3f kW\n", Ptotal_kW);


