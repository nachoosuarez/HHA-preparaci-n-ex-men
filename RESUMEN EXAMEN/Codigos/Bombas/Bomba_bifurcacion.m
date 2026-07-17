% Bomba_bifurcacion.m — calcula el punto de funcionamiento de UNA bomba
% unica que alimenta, despues de un nodo de bifurcacion, N tuberias
% IDENTICAS en paralelo que descargan por separado (p.ej. a la
% atmosfera, con o sin tobera). A diferencia de Bombas_paralelo.m (dos
% BOMBAS en paralelo), aca hay una sola bomba y lo que se ramifica es la
% RED DE TUBERIAS aguas abajo: por simetria, cada rama transporta Q/N
% del caudal total que pasa por la bomba.
%
% Entradas: geometria de succion (Ls,Ds,ks) e impulsion hasta el nodo
% de bifurcacion (Li,Di,ki,kv), geometria de UNA rama tras el nodo
% (Lr,Dr,kr) y de su tobera de salida (Dt, si descarga libre; poner
% Dt=Dr y kt=0 si no hay tobera y descarga sumergida/con presion p2),
% numero de ramas identicas N, cotas (zA bomba, z1 reservorio, z2
% salida de cada rama), y la curva de la bomba (Q,H,eta,NPSHr).
% Salidas: grafico H-Q, punto de funcionamiento (Qpf,Hpf), velocidades
% y factores de friccion en cada tramo, eficiencia, potencia, NPSHdisp.
%
% Usar cuando: una bomba unica alimenta una red que se bifurca en ramas
% IDENTICAS (mismo L,D,k,cota,tobera en cada una) — el caudal se reparte
% por igual entre todas. Si las ramas NO son identicas, este script no
% aplica: hay que plantear un sistema de ecuaciones (fsolve) igual que
% en "bombas en paralelo con succiones independientes" (ver
% RESUMEN_TEORICO.md S:C5), pero aca serian ramas de tuberia, no bombas.
% Ejemplo completo de uso, con datos reales:
% resueltos/2023 Julio/scripts/Ejercicio4_bombeo_bifurcacion.m
% Requiere colebrook.m en el mismo directorio.
clc; clear; close all;
figure(1); clf; hold on; grid on;

%% ==== EDITAR ACA (datos del enunciado) ====
g   = 9.81;
rho = 1000;
nu  = 1e-6;
eps = 0.00005;    % rugosidad absoluta (m), todas las tuberias

% Succion (reservorio -> bomba)
Ls = 15;   Ds = 0.05;  ks = 6;
% Impulsion (bomba -> nodo de bifurcacion), incluye la valvula si la hay
Li = 450;  Di = 0.05;  ki = 4;  kv = 5;
% UNA rama (nodo -> salida), N ramas identicas en total
N  = 2;
Lr = 30;   Dr = 0.032; kr = 2;
Dt = 0.025;           % diametro de la tobera de salida de cada rama (Dt=Dr si no hay tobera)
z1 = -4;              % cota del reservorio (superficie libre)
z2 = 1.5;             % cota de salida de cada rama
zA = 0.8;             % cota de la bomba
p2 = 0;               % presion manometrica en la salida (0 si es descarga libre a la atmosfera)

% Curva de la bomba (tabla del catalogo)
Q_tab     = [0.075 0.30 0.60 0.90 1.2  1.5  1.8  2.1  2.4  2.7  3.0]/1000; % m3/s
H_tab     = [24.1  23.7 23.2 23   22.5 21.5 20.8 20.3 19.3 17.8 16.2];      % m
eta_tab   = [9     25.2 42.3 52.2 61.2 65.7 67.5 69.3 70.2 69.3 67.5];      % %
NPSHr_tab = [2     2.2  2.5  2.7  3    3.4  3.8  4.5  5    5.6  6.2];       % m
%% ============================================

As = pi*Ds^2/4;  Ai = pi*Di^2/4;  Ar = pi*Dr^2/4;  At = pi*Dt^2/4;

Qmalla = linspace(min(Q_tab), max(Q_tab), 4000);
Hb = interp1(Q_tab, H_tab, Qmalla, 'pchip');
Hinst = zeros(size(Qmalla));
NPSHdisp = zeros(size(Qmalla));
patm_pvap = 10.33 - 0.24;  % m.c.a. (agua a 20 C): (Patm-Pvap)/gamma

for i = 1:numel(Qmalla)
    Qi = Qmalla(i);

    vs = Qi/As;
    Res = vs*Ds/nu;
    fs = colebrook(Res, eps/Ds);
    dHs = (fs*Ls/Ds + ks)*vs^2/(2*g);
    NPSHdisp(i) = (z1 - dHs) - zA + patm_pvap;

    vi = Qi/Ai;
    Rei = vi*Di/nu;
    fi = colebrook(Rei, eps/Di);

    Qr = Qi/N;               % caudal de UNA rama (Q total / N ramas identicas)
    vr = Qr/Ar;
    Rer = vr*Dr/nu;
    fr = colebrook(Rer, eps/Dr);

    vt = Qr/At;               % velocidad de salida por la tobera de esa rama

    H1 = z1;
    H2 = p2/(rho*g) + vt^2/(2*g) + z2;

    Hinst(i) = H2 - H1 ...
             + (fs*Ls/Ds + ks)*vs^2/(2*g) ...
             + (fi*Li/Di + ki + kv)*vi^2/(2*g) ...
             + (fr*Lr/Dr + kr)*vr^2/(2*g);
end

[~, idx] = min(abs(Hb - Hinst));
Qpf = Qmalla(idx);
Hpf = Hb(idx);
eta_pf = interp1(Q_tab, eta_tab, Qpf, 'pchip');
NPSHreq_pf = interp1(Q_tab, NPSHr_tab, Qpf, 'pchip');
NPSHdisp_pf = NPSHdisp(idx);
Pot = rho*g*Qpf*Hpf/(eta_pf/100);

vs_pf = Qpf/As; vi_pf = Qpf/Ai; vr_pf = (Qpf/N)/Ar; vt_pf = (Qpf/N)/At;

fprintf('----- PUNTO DE FUNCIONAMIENTO -----\n');
fprintf('Qpf = %.4f l/s ; Hpf = %.3f m\n', Qpf*1000, Hpf);
fprintf('v succion = %.4f m/s ; v impulsion = %.4f m/s\n', vs_pf, vi_pf);
fprintf('v en UNA rama = %.4f m/s ; v en la tobera de esa rama = %.4f m/s\n', vr_pf, vt_pf);
fprintf('Eficiencia = %.2f %% ; Potencia = %.1f W\n', eta_pf, Pot);
fprintf('NPSHdisp = %.3f m ; NPSHreq = %.3f m -> %s\n', NPSHdisp_pf, NPSHreq_pf, ...
        merge(NPSHdisp_pf < NPSHreq_pf, 'CAVITA', 'no cavita'));

plot(Qmalla*1000, Hb, 'b-', 'LineWidth', 1.5, 'DisplayName', 'Curva de la bomba H(Q)');
plot(Qmalla*1000, Hinst, 'm-', 'LineWidth', 1.5, 'DisplayName', 'Curva de la instalacion H_{inst}(Q)');
plot(Qpf*1000, Hpf, 'ko', 'MarkerFaceColor', 'k', 'DisplayName', 'Punto de funcionamiento');
xlabel('Q (l/s)'); ylabel('H (m)');
legend('Location', 'northeast');
title('Bomba unica + bifurcacion en N ramas identicas');
