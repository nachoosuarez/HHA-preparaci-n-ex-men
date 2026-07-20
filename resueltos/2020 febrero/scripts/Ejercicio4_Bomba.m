% Ejercicio4_Bomba.m — Examen HHA 28/feb/2020, Ejercicio 4 (25 pts).
%
% Instalacion que RECIRCULA agua desde y hacia el MISMO tanque, con
% presion en el tanque inferior a la atmosferica (pT=-10 kPa). Descarga
% libre a cota z2=5m en la parte superior del tanque (dentro del mismo
% espacio de aire a presion pT). Nivel de agua en el tanque z1=3m.
% Bomba a cota zA=2m. Succion e impulsion con el MISMO diametro
% D=120mm, rugosidad eps=0.05mm; Ls=0.3m, ks=2 (succion), Li=10m, ki=3
% (impulsion).
%
% Clave fisica (ver RESOLUCION.md): tanto el nivel libre z1 como la
% descarga z2 estan dentro del MISMO espacio de aire cerrado del
% tanque -> p1=p2=pT, se CANCELAN en la ecuacion de energia. La
% velocidad en el nivel libre z1 es ~0 (superficie libre grande).
%
% Adaptado del template canonico Bomba_sola.m (mismo D en succion e
% impulsion => Dt=D). Requiere colebrook.m (mismo directorio).
clc; clear; close all;
addpath(pwd);

%========================
% DATOS
%========================
g = 9.81;
ro = 1000;
nu = 1e-6;
eps = 0.00005; % m (0.05 mm)
D = 0.12;      % m (succion e impulsion, mismo diametro)

% Succion
Ls = 0.3;
ks = 2;
z1 = 3;        % nivel libre en el tanque (m)
pT = -10000;   % Pa, presion del tanque (gauge) -- igual en z1 y z2

% Cota bomba
zA = 2;

% Impulsion
Li = 10;
ki = 3;
z2 = 5;        % descarga libre, DENTRO del mismo tanque (misma pT)

%========================
% CURVA DE LA BOMBA (dato de catalogo, tabla del enunciado)
%========================
Q     = [0     8.2   16.3  24.5  32.7  40.8  49.0]/1000; % m3/s
H     = [5.28  5.24  5.12  4.94  4.68  4.26  3.40];      % m
NPSHr = [1.92  2.04  2.16  2.64  3.36  4.68  6.60];      % m
eta   = [NaN   55.0  66.0  73.7  71.5  63.8  58.3];      % %

A = pi*D^2/4;

%========================
% CURVA DE LA INSTALACION
%========================
Qmalla = linspace(0.0005, max(Q), 400);
Hb = interp1(Q, H, Qmalla, "pchip");
Hinst = zeros(size(Qmalla));

for i = 1:length(Qmalla)
  Qi = Qmalla(i);
  U = Qi/A;
  Re = U*D/nu;
  f = colebrook(Re, eps/D);
  deltaS = (ks + f*Ls/D) * U^2/(2*g);
  deltaI = (ki + f*Li/D) * U^2/(2*g);
  % p1=p2=pT se cancelan; v1~0 (superficie libre grande)
  Hinst(i) = (z2 - z1) + (1 + ks + f*Ls/D + ki + f*Li/D) * U^2/(2*g);
end

%========================
% PUNTO DE FUNCIONAMIENTO
%========================
[~, idx] = min(abs(Hb - Hinst));
Qpf = Qmalla(idx);
Hpf = Hb(idx);
Upf = Qpf/A;
Repf = Upf*D/nu;
fpf = colebrook(Repf, eps/D);
eta_pf = interp1(Q(2:end), eta(2:end), Qpf, "pchip");
NPSHr_pf = interp1(Q, NPSHr, Qpf, "pchip");

fprintf('--- Parte 1: punto de funcionamiento ---\n');
fprintf('Q_PF = %.4f m3/s (%.1f L/s)\n', Qpf, Qpf*1000);
fprintf('H_PF = %.3f m\n', Hpf);
fprintf('Re_PF = %.3e , f_PF = %.4f\n', Repf, fpf);
fprintf('eta_PF = %.2f %%\n\n', eta_pf);

%========================
% Parte 2: potencia consumida
%========================
Pot = ro*g*Qpf*Hpf/(eta_pf/100);
fprintf('--- Parte 2: potencia ---\n');
fprintf('P = rho*g*Q*H/eta = %.1f W = %.3f kW\n\n', Pot, Pot/1000);

%========================
% Parte 3: cavitacion (NPSH disponible vs requerido)
%========================
deltaS_pf = (ks + fpf*Ls/D) * Upf^2/(2*g);
% NPSHdisp: z1 es superficie libre grande (v~0) -> el termino cinetico
% de HA se cancela con el que resta la definicion de NPSH (ver
% RESUMEN_TEORICO.md C4 y el comentario "OJO" de Bomba_sola.m).
patm_menos_pvap = 10.1; % m (constante estandar, agua ~20C, Patm nivel del mar)
NPSHd_pf = z1 + pT/(ro*g) - deltaS_pf - zA + patm_menos_pvap;

fprintf('--- Parte 3: cavitacion ---\n');
fprintf('delta_succion(PF) = %.4f m\n', deltaS_pf);
fprintf('NPSHdisponible = z1 + pT/(rho g) - delta_succion - zA + 10.1 = %.3f m\n', NPSHd_pf);
fprintf('NPSHrequerido(PF) = %.3f m\n', NPSHr_pf);
if NPSHd_pf > NPSHr_pf
  fprintf('NPSHd > NPSHr -> la bomba NO CAVITA\n\n');
else
  fprintf('NPSHd < NPSHr -> la bomba CAVITA\n\n');
end

%========================
% Parte 4: presion minima admisible en el tanque para que no cavite
%========================
% El punto de funcionamiento NO depende de p (p1=p2 se cancelan en la
% curva de instalacion) => Qpf, Upf, deltaS_pf, NPSHr_pf no cambian.
% Se despeja p tal que NPSHdisponible(p) = NPSHrequerido(PF):
%   NPSHr_pf = z1 + p/(rho g) - deltaS_pf - zA + 10.1
p_min = ro*g*( NPSHr_pf - z1 + deltaS_pf + zA - patm_menos_pvap );
fprintf('--- Parte 4: presion minima en el tanque ---\n');
fprintf('p_min = rho*g*(NPSHr_PF - z1 + delta_succion_PF + zA - 10.1) = %.1f Pa = %.2f kPa\n', p_min, p_min/1000);
