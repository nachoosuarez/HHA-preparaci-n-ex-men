clc; clear; close all;

g = 9.81;%m/s2
ro=997; %densidad del agua en kg/m3
nu = 0.000001;
epsilon = 0.00015;
L1 = 2;
L2 = 10;
L3 = 75;
L4 = 6;

z1 = -5;
zb=0;
z2 = 10;
D1 = 0.102;
D2 = 0.102;

%Valores ya hallados
Qpf=59.47/60/60; %m3/s
Hpf=20.18; %m
n=75;

Hm = [];
NPSHdisp=[];
NPSHmod= [];
Q = [1:120]/3600;% Caudales (m3/s)

for i = 1:length(Q)

  A1 = pi * (D1^2) / 4;
  A2 = pi * (D2^2) / 4;

  %Tramo A
  v1 = Q(i) / A1;
  deltalocA = (0.5 * (v1^2) / (2*g)) + (0.9 * (v1^2) / (2*g));
  Re1 = v1 * D1 / nu;
  f1 = colebrook(Re1, epsilon/D1);
  deltadistA = f1 * (L1 + L2) * (v1^2) / (2*D1*g);
  delta1 = deltalocA + deltadistA;
  Ha = z1 - delta1;

  %  Tramo B
  v2 = Q(i) / A2;
  deltalocB = (1 * (v2^2) / (2*g)) + 2 * (0.9 * (v2^2) / (2*g));
  Re2 = v2 * D2 / nu;
  f2 = colebrook(Re2, epsilon/D2);
  deltadistB = f2 * (L3 + L4) * (v2^2) / (2*D2*g);
  delta2 = deltalocB + deltadistB;
  Hb = z2 + delta2;

  % Carga de la bomba
  Hm = [Hm Hb - Ha];
  %NPSH Disponible
  NPSHdisp=[NPSHdisp Ha-zb+10.1];
end

Pcons=ro*g*Qpf*Hpf/n; %Potencia consumida (W)
% Graficar curva de instalaci n y de la bomba
figure(1)
hold on; grid on;
%Curva de instalacion azul
plot(Q*3600, Hm, 'b-o', 'LineWidth', 1.5);   %   Hinst
% Curva NPSH disp
plot(Q*3600, NPSHdisp, 'c-o', 'LineWidth', 1.5);    %  NPSHdisp

% Curva caracter stica de la bomba rojo

Qb=[0 10 20 30 40 50 60 70 80 90 100 110 120];
Hb=[22 21.9 21.8 21.5 21.10 20.8 20.15 19.20 18.25 17.15 15.8 13.9 11.5];

% Qb = [0 40 80 120];     % ( m /h)
% Hb = [22.5 21.5 18.5 11.5];    % m

plot(Qb, Hb, 'r-*', 'LineWidth', 1.5);   %   Hbomba
hold on;

%Curva eficiencia dato
Qn=[40 45 47.5 60 73.5 80 87.5 100 103.5 110 120];
Hn=[2.3 4.2 5 8 10 10.8 11 10.5 10 8.9 5.5];
plot(Qn, Hn, 'y-*', 'LineWidth', 1.5);   %   Eficiencia

% Curva NPSH requerrido
Q_NPSHrec = [0 5 10 15 20 25 30 35 40 47.5 60 80 100 120]; % m3/h
NPSHrec = [1.10 1.15 1.20 1.22 1.24 1.26 1.28 1.25 1.40 1.60 2.00 2.60 3.50 5.00];
plot(Q_NPSHrec,NPSHrec, 'g-*', 'LineWidth', 1.5);   %   NPSHrec
hold on;

% L nea vertical en Q = 45.07 m^3/h punto funcionamiento
Qcrit = 59.47;            % m^3/h
yl = ylim();              % l mites actuales del eje y

h_v = plot([Qcrit Qcrit], [yl(1) yl(2)], 'k--', 'LineWidth', 2);

% L nea vertical en Q = 33.357 m^3/h punto funcionamiento
Qcrit = 43;            % m^3/h
yl = ylim();              % l mites actuales del eje y

h_v = plot([Qcrit Qcrit], [yl(1) yl(2)], 'r--', 'LineWidth', 2);

%Texto Grafica
xlabel('Caudal Q [m /h]');
ylabel('Carga H [m]');
title('Curva de instalaci n y curvas caracter sticas de la bomba');
legend('Curva de instalaci n', 'NPSHdisp','Curva de la bomba','Eficiencia', 'NPSHrec','Qpf','Location', 'northeast');
axis([0 130 0 25]);

