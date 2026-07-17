% Ejercicio4_bombeo_bifurcacion.m — Examen HHA 24/jul/2023, Ejercicio 4.
%
% Instalacion de riego: reservorio (R) -> succion (1) -> bomba (zA=0.8m)
% -> impulsion (2, con valvula reguladora kv) -> nodo de bifurcacion (T)
% -> DOS tuberias identicas (3) y (4) que descargan a la atmosfera a
% traves de toberas (diametro Dt=25mm) a cota z2=1.5 m.
%
% Requiere, en esta misma carpeta (copia del toolkit canonico
% RESUMEN EXAMEN/Codigos/Bombas): colebrook.m.
%
% METODO (ver RESUMEN_TEORICO.md S:C1, C2, C3, C4):
% - Parte 1 (z1=-6m, Q=1.5 l/s dado, sin necesidad de hallar el punto de
%   funcionamiento): se evalua NPSHdisp con la ecuacion de la succion
%   UNICAMENTE (C4: NPSHdisp no depende de la impulsion ni de la
%   bifurcacion) y se compara contra NPSHreq interpolado de la tabla de
%   la bomba en Q=1.5 l/s.
% - Parte 2 (z1=-4m, kv=5): la curva de la instalacion combina la
%   ecuacion de perdida de carga del reservorio (R) al nodo (T) [succion
%   + impulsion, con el caudal TOTAL Q] con la ecuacion de perdida de
%   carga de (T) a la salida de una tobera [con el caudal Q/2, ya que
%   las dos ramas son identicas y se reparten el caudal por igual]. El
%   punto de funcionamiento es la interseccion con la curva de la bomba
%   (interpolada con pchip).

clc; clear; close all;
warning('off','all');

%% ==== EDITAR ACA (datos del enunciado) ====
g   = 9.81;
rho = 1000;
nu  = 1e-6;
eps = 0.00005;      % rugosidad absoluta, 0.05 mm (todas las tuberias)

% Succion (1)
L1 = 15;   D1 = 0.05;  k1 = 6;
% Impulsion (2), hasta la bifurcacion (T)
L2 = 450;  D2 = 0.05;  k2 = 4;
% Ramas (3) y (4), identicas
L3 = 30;   D3 = 0.032; k3 = 2;
Dt = 0.025;          % diametro de las toberas
z2 = 1.5;            % cota de descarga de las toberas (m)
zA = 0.8;            % cota de la bomba (m)

% Curva de la bomba (tabla del enunciado; se dejan 11 puntos, Q=0.075..3.0
% l/s, porque el ultimo valor de H a Q=3.3 l/s no es legible en el
% escaneo del examen y el punto de funcionamiento cae bien dentro del
% rango cubierto por estos 11 puntos)
Q_tab    = [0.075 0.30 0.60 0.90 1.2  1.5  1.8  2.1  2.4  2.7  3.0]/1000; % m3/s
H_tab    = [24.1  23.7 23.2 23   22.5 21.5 20.8 20.3 19.3 17.8 16.2];      % m
eta_tab  = [9     25.2 42.3 52.2 61.2 65.7 67.5 69.3 70.2 69.3 67.5];      % %
NPSHr_tab= [2     2.2  2.5  2.7  3    3.4  3.8  4.5  5    5.6  6.2];       % m
%% ============================================

A1 = pi*D1^2/4;  A3 = pi*D3^2/4;  AT = pi*Dt^2/4;

fprintf('=================== PARTE 1: z1=-6 m, Q=1.5 l/s (dato) ===================\n');
z1 = -6;
Qc = 1.5/1000; % m3/s

v1 = Qc/A1;
Re1 = v1*D1/nu;
f1 = colebrook(Re1, eps/D1);
dH_succ = (f1*L1/D1 + k1)*v1^2/(2*g);
fprintf('v1 = %.4f m/s ; Re1 = %.3e ; f1 = %.4f\n', v1, Re1, f1);
fprintf('Perdida de carga en la succion: dH_succ = (f1*L1/D1+k1)*v1^2/2g = %.4f m\n', dH_succ);

% NPSHdisp: HA = z1 - dH_succ (sin sumar v1^2/2g de nuevo, se cancela
% algebraicamente con el termino cinetico de la propia definicion de NPSH,
% ver RESUMEN_TEORICO.md S:C4 "trampa comun")
patm_pvap = 10.33 - 0.24; % m.c.a. (agua a 20 C)
NPSHdisp = (z1 - dH_succ) - zA + patm_pvap;
fprintf('NPSHdisp = (z1 - dH_succ) - zA + (Patm-Pvap)/gamma = (%.2f-%.4f)-%.2f+%.2f = %.3f m\n', ...
        z1, dH_succ, zA, patm_pvap, NPSHdisp);

NPSHreq = interp1(Q_tab, NPSHr_tab, Qc, 'pchip');
fprintf('NPSHreq (interpolado en Q=1.5 l/s) = %.3f m\n', NPSHreq);

if NPSHdisp < NPSHreq
    fprintf('NPSHdisp (%.2f m) < NPSHreq (%.2f m)  =>  LA BOMBA CAVITA\n', NPSHdisp, NPSHreq);
else
    fprintf('NPSHdisp (%.2f m) > NPSHreq (%.2f m)  =>  la bomba NO cavita\n', NPSHdisp, NPSHreq);
end

fprintf('\nAlternativas para evitar la cavitacion (aumentar NPSHdisp):\n');
fprintf('  1) Disminuir la cota de la bomba (zA).\n');
fprintf('  2) Aumentar la carga a la entrada de la bomba (operar con nivel del reservorio mas alto).\n');
fprintf('  3) Disminuir las perdidas en la succion (aumentar D1 y/o disminuir k1).\n');


fprintf('\n=================== PARTE 2: z1=-4 m, kv=5 ===================\n');
z1 = -4;
kv = 5;

Qmalla = linspace(0.0001, 0.0033, 4000); % m3/s (cubre todo el rango de la tabla)
Hb = interp1(Q_tab, H_tab, Qmalla, 'pchip');
Hinst = zeros(size(Qmalla));

for i = 1:numel(Qmalla)
    Qi = Qmalla(i);

    v1i = Qi/A1;
    Re1i = v1i*D1/nu;
    f1i = colebrook(Re1i, eps/D1);
    v2i = v1i; % misma D, mismo caudal (succion e impulsion, D1=D2)
    Re2i = Re1i;
    f2i = f1i;

    Qi3 = Qi/2; % cada rama lleva la mitad del caudal total
    v3i = Qi3/A3;
    Re3i = v3i*D3/nu;
    f3i = colebrook(Re3i, eps/D3);

    vTi = Qi3/AT;

    H1 = z1;
    H2 = vTi^2/(2*g) + z2;

    Hinst(i) = H2 - H1 ...
             + (f1i*L1/D1 + k1)*v1i^2/(2*g) ...
             + (f2i*L2/D2 + k2 + kv)*v2i^2/(2*g) ...
             + (f3i*L3/D3 + k3)*v3i^2/(2*g);
end

[~, idx] = min(abs(Hb - Hinst));
Qpf = Qmalla(idx);
Hpf = Hb(idx);
fprintf('Punto de funcionamiento (interseccion curva bomba / curva instalacion):\n');
fprintf('  Qpf = %.4f l/s ; Hpf = %.3f m\n', Qpf*1000, Hpf);

% Detalle de terminos en el punto de funcionamiento
v1pf = Qpf/A1; Re1pf = v1pf*D1/nu; f1pf = colebrook(Re1pf, eps/D1);
Qpf3 = Qpf/2; v3pf = Qpf3/A3; Re3pf = v3pf*D3/nu; f3pf = colebrook(Re3pf, eps/D3);
vTpf = Qpf3/AT;
fprintf('  v1=v2 = %.4f m/s ; Re1=Re2 = %.3e ; f1=f2 = %.4f\n', v1pf, Re1pf, f1pf);
fprintf('  v3=v4 = %.4f m/s ; Re3=Re4 = %.3e ; f3=f4 = %.4f\n', v3pf, Re3pf, f3pf);
fprintf('  vT (tobera) = %.4f m/s\n', vTpf);

eta_pf = interp1(Q_tab, eta_tab, Qpf, 'pchip');
Pot = rho*g*Qpf*Hpf/(eta_pf/100);
fprintf('\nEficiencia en Qpf: eta = %.2f %%\n', eta_pf);
fprintf('Potencia consumida: Pot = rho*g*Qpf*Hpf/eta = %.1f W\n', Pot);

%% Grafico H-Q
figure(1); clf; hold on; grid on;
plot(Qmalla*1000, Hb, 'b-', 'LineWidth', 1.5, 'DisplayName', 'Curva de la bomba H(Q)');
plot(Qmalla*1000, Hinst, 'm-', 'LineWidth', 1.5, 'DisplayName', 'Curva de la instalacion H_{inst}(Q)');
plot(Qpf*1000, Hpf, 'ko', 'MarkerFaceColor','k', 'DisplayName', 'Punto de funcionamiento');
xlabel('Q (l/s)'); ylabel('H (m)');
legend('Location', 'northeast');
title('Ejercicio 4 Parte 2 - Curva de instalacion vs. curva de la bomba');
