% Ejercicio4_bombas_paralelo.m — Examen HHA 11/dic/2023, Ejercicio 4.
%
% Trasvase de agua entre dos cuerpos de agua con DOS BOMBAS IGUALES
% acopladas en PARALELO, con succión e impulsión ÚNICAS y compartidas
% (se separan sólo en el acople de las bombas, sin pérdida ahí). Se pide
% el punto de funcionamiento, la potencia consumida por el sistema y por
% cada bomba, y verificar cavitación (NPSHdisp vs NPSHreq).
%
% MÉTODO (ver RESUMEN_TEORICO.md §C1-C4):
% - Bombas iguales en paralelo => trabajan con la MISMA H y Qtotal=2*Qcu;
%   la "bomba equivalente" tiene Hbeq(Qtot) = H_bomba(Qtot/2) (misma
%   curva de catálogo, evaluada a la mitad del caudal total).
% - Curva de instalación: Hm = (z1-z0) + ΔH(succión) + ΔH(impulsión),
%   con succión e impulsión ÚNICAS (usa el caudal TOTAL, no el de cada
%   bomba, porque ambos tramos son compartidos).
% - NPSHdisp = HA - zA + (patm-pvap)/γ, con HA = z0 - ΔH(succión)
%   (SIN sumar el término cinético de la succión: se cancela
%   algebraicamente con el que ya trae la propia definición de NPSH — ver
%   nota en RESUMEN_TEORICO.md §C4, bug corregido en el toolkit Bombas/
%   resolviendo este mismo ejercicio). Se evalúa con el caudal TOTAL
%   (succión compartida) pero se compara contra el NPSHreq de CADA bomba
%   interpolado en su caudal INDIVIDUAL (mitad del total).
%
% Requiere, en esta misma carpeta: colebrook.m (copia del toolkit
% canónico RESUMEN EXAMEN/Codigos/Bombas/, ya corregido).

clc; clear; close all;
warning('off','all');

%% ==== EDITAR ACÁ (datos del enunciado) ====
g = 9.81; ro = 1000; nu = 1e-6;   % agua a 20°C

z0 = -4;      % cota superficie libre lago fuente (m)
zA = 0.5;     % cota de las bombas (m)
z1 = 30;      % cota superficie libre lago destino (m)

L1 = 50;      D1 = 0.300;  eps1 = 0.007e-3;  k1 = 6;   % succión (única, compartida)
L2 = 15000;   D2 = 0.600;  eps2 = 0.1e-3;    k2 = 8;   % impulsión (única, compartida)

% Curva de catálogo (una bomba; las dos son iguales)
Qcat = [0 251 328 425 508 579 641 679 712 735]/3600;   % m3/s
Hcat = [52.3 50.4 48.5 44.38 39.5 35.2 31 26.6 21.8 16.2];
etacat = [0 55 65 72 74 72 68 62 52 41];                % %
NPSHreqcat = [1.25 1.4 1.55 1.7 1.85 2.1 2.35 2.8 3.15 3.5];
%% ============================================

As = pi*D1^2/4; Ai = pi*D2^2/4;
fprintf('Asucc = %.4f m2 ; Aimp = %.4f m2\n', As, Ai);

function Hm = curva_instalacion(Qtot, z0,z1,L1,D1,eps1,k1,L2,D2,eps2,k2, g,nu, As,Ai)
    vs = Qtot/As; Re1 = vs*D1/nu; f1 = colebrook(Re1, eps1/D1);
    dHs = (f1*L1/D1 + k1) * vs^2/(2*g);
    vi = Qtot/Ai; Re2 = vi*D2/nu; f2 = colebrook(Re2, eps2/D2);
    dHi = (f2*L2/D2 + k2) * vi^2/(2*g);
    Hm = (z1 - z0) + dHs + dHi;
end

% ---- Punto de funcionamiento: Hbeq(Qtot) = H_bomba(Qtot/2) = Hm(Qtot) ----
Qtot_grid = linspace(1e-4, 2*Qcat(end), 4000);
Hbeq = interp1(Qcat, Hcat, Qtot_grid/2, 'pchip');
Hm_grid = arrayfun(@(Q) curva_instalacion(Q, z0,z1,L1,D1,eps1,k1,L2,D2,eps2,k2, g,nu, As,Ai), Qtot_grid);
[~, idx] = min(abs(Hbeq - Hm_grid));
Qtot_pf = fzero(@(Q) interp1(Qcat,Hcat,Q/2,'pchip') - curva_instalacion(Q, z0,z1,L1,D1,eps1,k1,L2,D2,eps2,k2, g,nu, As,Ai), Qtot_grid(idx));
Hpf = interp1(Qcat, Hcat, Qtot_pf/2, 'pchip');
Qb = Qtot_pf/2;   % caudal de CADA bomba

fprintf('\n--- PUNTO DE FUNCIONAMIENTO ---\n');
fprintf('Qtotal (bomba equivalente) = %.4f m3/s = %.1f m3/h\n', Qtot_pf, Qtot_pf*3600);
fprintf('H funcionamiento = %.2f m\n', Hpf);
fprintf('Caudal de cada bomba Qb1=Qb2 = %.4f m3/s = %.1f m3/h\n', Qb, Qb*3600);

% ---- Potencia ----
eta_b = interp1(Qcat, etacat, Qb, 'pchip');
Pb = ro*g*Qb*Hpf/(eta_b/100);      % W, cada bomba
Ptot = 2*Pb;
fprintf('\n--- POTENCIA ---\n');
fprintf('Eficiencia de cada bomba en Qb = %.2f %%\n', eta_b);
fprintf('Potencia de cada bomba = %.2f kW\n', Pb/1000);
fprintf('Potencia total del sistema = %.2f kW\n', Ptot/1000);

% ---- NPSH ----
vs_pf = Qtot_pf/As; Re1_pf = vs_pf*D1/nu; f1_pf = colebrook(Re1_pf, eps1/D1);
dHs_pf = (f1_pf*L1/D1 + k1) * vs_pf^2/(2*g);
HA = z0 - dHs_pf;                          % SIN termino cinetico (ver nota arriba)
NPSHdisp = HA - zA + 10.1;                 % (patm-pvap)/gamma ~ 10.1 mca
NPSHreq_b = interp1(Qcat, NPSHreqcat, Qb, 'pchip');

fprintf('\n--- CAVITACION ---\n');
fprintf('f succion = %.4f ; Vsucc = %.3f m/s ; dHsucc = %.3f m\n', f1_pf, vs_pf, dHs_pf);
fprintf('HA = z0 - dHsucc = %.3f m\n', HA);
fprintf('NPSHdisp = HA - zA + 10.1 = %.3f m\n', NPSHdisp);
fprintf('NPSHreq (interp en Qb=%.4f m3/s) = %.3f m\n', Qb, NPSHreq_b);
if NPSHdisp > NPSHreq_b
    fprintf('NPSHdisp > NPSHreq => las bombas NO cavitan (margen %.3f m)\n', NPSHdisp-NPSHreq_b);
else
    fprintf('NPSHdisp < NPSHreq => las bombas CAVITAN\n');
end

fprintf('\n=====================================================\n');
fprintf('RESUMEN: Qtot=%.3f m3/s (Qb=%.3f m3/s c/u) | H=%.2f m | Ptot=%.2f kW (%.2f kW c/u) | NPSHdisp=%.2f m > NPSHreq=%.2f m => no cavitan\n', ...
        Qtot_pf, Qb, Hpf, Ptot/1000, Pb/1000, NPSHdisp, NPSHreq_b);
