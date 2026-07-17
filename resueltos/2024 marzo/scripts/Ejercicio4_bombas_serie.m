% Ejercicio4_bombas_serie.m — Examen HHA 1 de marzo 2024, Ejercicio 4
% Instalación de bombeo: reservorio (z1=-2.2m) -> tanque elevado presurizado
% (z2=+10m, p2=170 kPa). Succión y impulsión de igual diámetro D=103mm,
% fundición (epsilon=0.12mm). Bombas iguales, ubicadas a zA=+0.3m.
% Adaptado de RESUMEN EXAMEN/Codigos/Bombas/Bombas_serie.m (mismo método,
% datos propios de este examen). Requiere colebrook.m en el mismo path.
clc; clear; close all;

g = 9.81;      % m/s2
ro = 1000;     % kg/m3
nu = 1e-6;     % m2/s (agua)
epsilon = 0.00012; % m (fundición)

% ---- Datos succión ----
Ls = 20;    % m
Ds = 0.103; % m
z1 = -2.2;  % m
ks = 6;
p1 = 0;     % reservorio abierto a la atmósfera

% ---- Cota de las bombas ----
zA = 0.3;   % m

% ---- Datos impulsión ----
Li = 850;   % m
Di = 0.103; % m
ki = 5.5;
z2 = 10;    % m
p2 = 170000; % Pa (170 kPa)

% ---- Curva de catálogo de UNA bomba ----
Qb = [0 1.25 2.5 3.75 5 6.25 7.5 8.75 10 11.25 12.5 13.75 15 16.25 17.5 18.75 20]/1000; % m3/s
Hb = [23.6 26.3 28.1 28.8 29.0 28.6 27.9 26.7 25.8 24.4 23.2 22.4 21.3 20.1 19.0 17.5 15.3]; % m
etab = [0 12 24 35 45 52 60 65 68 71 73 75 76 77 78 75 68]; % %
NPSHrb = [3.1 3.4 3.6 3.9 4.1 4.4 4.7 5.0 5.3 5.7 6.1 7.0 7.5 7.9 8.3 8.9 9.6]; % m

% ==== Parte 1: ¿alcanza con 1 bomba (paralelo no ayuda a subir H) o hace falta serie? ====
Hestatica = (z2 - z1) + p2/(ro*g);
fprintf("Carga estática a vencer: Hestatica = %.2f m\n", Hestatica);
fprintf("Carga máxima que entrega UNA bomba (máximo de la curva): %.2f m\n", max(Hb));
if max(Hb) < Hestatica
    fprintf("-> Una sola bomba (o varias en PARALELO, que no suman H) no alcanza.\n");
    fprintf("-> Hace falta acoplar bombas en SERIE.\n");
end

% ==== Parte 2: punto de funcionamiento con 2 bombas iguales en SERIE ====
As = pi*Ds^2/4;
Ai = pi*Di^2/4;

Q = linspace(0.001, min(max(Qb),0.020), 400); % m3/s, rango de la curva de catálogo
Hserie = 2*interp1(Qb, Hb, Q, "pchip");        % 2 bombas en serie: H se suma a igual Q

Hm = zeros(size(Q));
for i = 1:length(Q)
    vs = Q(i)/As;
    Re_s = vs*Ds/nu;
    fs = colebrook(Re_s, epsilon/Ds);
    dHs = (fs*Ls/Ds + ks) * vs^2/(2*g);
    HA = z1 + p1/(ro*g) - dHs;   % carga en la brida de succión

    vi = Q(i)/Ai;
    Re_i = vi*Di/nu;
    fi = colebrook(Re_i, epsilon/Di);
    dHi = (fi*Li/Di + ki) * vi^2/(2*g);
    HB = z2 + p2/(ro*g) + dHi;   % carga en la brida de impulsión (descarga en tanque presurizado)

    Hm(i) = HB - HA;
end

diffH = abs(Hserie - Hm);
[~, idx] = min(diffH);
Qpf = Q(idx);
Hpf_total = Hserie(idx);
Hpf_bomba = Hpf_total/2; % cada bomba entrega la mitad de la H total (serie, misma Q)

eta_pf = interp1(Qb, etab, Qpf, "pchip");
NPSHr_pf = interp1(Qb, NPSHrb, Qpf, "pchip");

fprintf("\n--- Punto de funcionamiento (2 bombas en serie) ---\n");
fprintf("Q_PF = %.4f m3/s (%.2f l/s)\n", Qpf, Qpf*1000);
fprintf("H_PF por bomba = %.2f m  (H total = %.2f m)\n", Hpf_bomba, Hpf_total);
fprintf("eta_PF = %.2f %%\n", eta_pf);

% Reynolds y f en la condición de operación (para reportar)
vs_pf = Qpf/As; Re_s_pf = vs_pf*Ds/nu; fs_pf = colebrook(Re_s_pf, epsilon/Ds);
vi_pf = Qpf/Ai; Re_i_pf = vi_pf*Di/nu; fi_pf = colebrook(Re_i_pf, epsilon/Di);
fprintf("v_succion=v_impulsion = %.3f m/s (D1=D2)\n", vs_pf);
fprintf("f_succion = %.4f , f_impulsion = %.4f (Re=%.0f, eps/D=%.4f)\n", fs_pf, fi_pf, Re_s_pf, epsilon/Ds);

% Potencia
P_bomba = ro*g*Qpf*Hpf_bomba/(eta_pf/100); % W, cada bomba
P_total = 2*P_bomba;
fprintf("\nPotencia por bomba = %.3f kW\n", P_bomba/1000);
fprintf("Potencia total del sistema = %.3f kW\n", P_total/1000);

% ==== Parte 3: cavitación (NPSH disponible vs requerido) ====
% NPSHdisp depende solo de la succión, con el Q total (=Qpf, una sola línea de succión)
HA_pf = z1 + p1/(ro*g) - (fs_pf*Ls/Ds + ks)*vs_pf^2/(2*g);
patm_g = 10.1; % m.c.a. incluye ya -pvapor/g en la convención Hteorico
NPSHdisp_pf = HA_pf - zA + patm_g;
fprintf("\n--- Cavitación ---\n");
fprintf("NPSH disponible = %.2f m\n", NPSHdisp_pf);
fprintf("NPSH requerido (interpolado en Qpf) = %.2f m\n", NPSHr_pf);
if NPSHdisp_pf > NPSHr_pf
    fprintf("-> NPSHdisp > NPSHreq: NO CAVITA\n");
else
    fprintf("-> NPSHdisp < NPSHreq: CAVITA\n");
end

% ==== Parte 4: longitud máxima de succión manteniendo Ltot=870m ====
Ltot = 870;
% El punto de funcionamiento no cambia (mismos diametros/material, Ltot fijo,
% perdidas localizadas fijas) => Qpf, vs_pf, fs_pf y NPSHr_pf son los mismos.
% Se despeja L1 tal que NPSHdisp(L1) = NPSHr_pf
% NPSHdisp = z1 + p1/(ro g) - (fs*L1/Ds + ks)*vs^2/2g - zA + patm_g = NPSHr_pf
rhs = z1 + p1/(ro*g) - zA + patm_g - NPSHr_pf;
% rhs = (fs*L1/Ds + ks)*vs^2/(2g)
L1_max = (rhs*2*g/vs_pf^2 - ks) * Ds/fs_pf;
fprintf("\n--- Longitud máxima de succión ---\n");
fprintf("L1_max = %.1f m  (L2 = Ltot - L1_max = %.1f m)\n", L1_max, Ltot - L1_max);
