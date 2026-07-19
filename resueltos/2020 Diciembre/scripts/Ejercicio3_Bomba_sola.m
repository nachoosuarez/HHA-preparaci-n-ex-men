% Ejercicio3_Bomba_sola.m
% HHA 22/12/2020 - Ejercicio 3 (variante "A": kv=20)
%
% Una bomba eleva agua desde un tanque inferior (zT1=-1 m) a uno superior
% (zT2=70 m), con la bomba a cota zB=1 m. Succion e impulsion del mismo
% diametro D=300 mm, rugosidad eps=0.02 mm. Succion: Ls=2 m, ks=1.
% Impulsion: Li=500 m, ki=5 (codos/piezas) + una valvula a medio cerrar
% con kv=20 (Parte 1-3) que después se regula para bajar el caudal a
% Q=150 L/s (Parte 4-5).
%
% Adaptado de RESUMEN EXAMEN/Codigos/Bombas/Bomba_sola.m (mismo patron:
% succion+impulsion con perdidas Colebrook+localizadas, NPSHdisp con la
% resta de vs^2/2g porque z1 es una superficie libre de tanque).
% Requiere colebrook.m en el mismo directorio.

clc; clear; close all;

%========================
% DATOS
%========================
g = 9.81;
ro = 1000;
nu = 1e-6;
eps = 0.00002;     % 0.02 mm

% Succion
Ls = 2;
Ds = 0.3;
z1 = -1;      % zT1
p1 = 0;
ks = 1;

% Cota bomba
zB = 1;

% Impulsion
Li = 500;
Di = 0.3;
z2 = 70;      % zT2
p2 = 0;
ki_piezas = 5;
Dt = 0.3;     % mismo diametro, descarga sumergida

% Curva de la bomba (catalogo)
Qc    = [0 0.048 0.096 0.144 0.192 0.24 0.288 0.336];
Hc    = [104 103 100 94 86 76 64 44];
etac  = [0 0.33 0.58 0.70 0.74 0.72 0.64 0.47]*100;  % a %
NPSHrc= [1.73 2.13 2.8 3.73 4.8 6 7.33 8.8];

function [Qpf,Hpf,eta_pf,f_i,f_s,NPSHdisp_pf,NPSHr_pf] = punto_funcionamiento(kv, Qc,Hc,etac,NPSHrc, ...
                          g,ro,nu,eps,Ls,Ds,z1,p1,ks,zB,Li,Di,z2,p2,ki_piezas,Dt)
  ki = ki_piezas + kv;
  Qmalla = linspace(min(Qc), max(Qc), 400);
  Hb = interp1(Qc, Hc, Qmalla, "pchip");
  Hm = zeros(size(Qmalla));
  NPSHdisp = zeros(size(Qmalla));
  fs_v = zeros(size(Qmalla));
  fi_v = zeros(size(Qmalla));

  As = pi*Ds^2/4;
  Ai = pi*Di^2/4;
  At = pi*Dt^2/4;

  for i = 1:length(Qmalla)
    Qi = Qmalla(i);
    vs = Qi/As;
    Re1 = vs*Ds/nu;
    f1 = colebrook(Re1, eps/Ds);
    fs_v(i) = f1;
    deltaS = f1*Ls*vs^2/(2*Ds*g) + ks*vs^2/(2*g);
    HA = z1 + p1/(ro*g) + vs^2/(2*g) - deltaS;

    vi = Qi/Ai;
    Re2 = vi*Di/nu;
    f2 = colebrook(Re2, eps/Di);
    fi_v(i) = f2;
    deltaI = f2*Li*vi^2/(2*Di*g) + ki*vi^2/(2*g);
    vt = Qi/At;
    HB = z2 + p2/(ro*g) + vt^2/(2*g) + deltaI;

    Hm(i) = HB - HA;
    NPSHdisp(i) = 10.1 + HA - zB - vs^2/(2*g);
  end

  [~, idx] = min(abs(Hb - Hm));
  Qpf = Qmalla(idx);
  Hpf = Hb(idx);
  eta_pf = interp1(Qc, etac, Qpf, "pchip");
  f_s = fs_v(idx);
  f_i = fi_v(idx);
  NPSHdisp_pf = NPSHdisp(idx);
  NPSHr_pf = interp1(Qc, NPSHrc, Qpf, "pchip");
end

%========================
% PARTES 1-3: kv=20
%========================
kv1 = 20;
[Qpf1,Hpf1,eta1,fi1,fs1,NPSHd1,NPSHr1] = punto_funcionamiento(kv1, Qc,Hc,etac,NPSHrc, ...
                       g,ro,nu,eps,Ls,Ds,z1,p1,ks,zB,Li,Di,z2,p2,ki_piezas,Dt);

fprintf('=== PARTE 1: punto de funcionamiento (kv=%d) ===\n', kv1);
fprintf('Q  = %.4f m3/s\n', Qpf1);
fprintf('H  = %.2f m\n', Hpf1);
fprintf('f succion  = %.4f\n', fs1);
fprintf('f impulsion = %.4f\n', fi1);

P1 = ro*g*Qpf1*Hpf1/(eta1/100);
fprintf('\n=== PARTE 2: potencia ===\n');
fprintf('eta = %.2f %%\n', eta1);
fprintf('Potencia = rho*g*Q*H/eta = %.2f kW\n', P1/1000);

fprintf('\n=== PARTE 3: cavitacion ===\n');
fprintf('NPSHdisp = %.3f m\n', NPSHd1);
fprintf('NPSHreq  = %.3f m\n', NPSHr1);
if NPSHd1 < NPSHr1
  fprintf('=> CAVITA\n');
else
  fprintf('=> NO cavita (margen = %.2f m)\n', NPSHd1-NPSHr1);
end

%========================
% PARTES 4-5: regular valvula a Q=150 L/s
%========================
Qtarget = 0.15;
% Q(kv) es monotona decreciente (mas kv => mas perdida => menos caudal):
% se busca por biseccion en vez de barrido lineal (mucho mas rapido).
function Qj = Q_de_kv(kv, Qc,Hc,etac,NPSHrc,g,ro,nu,eps,Ls,Ds,z1,p1,ks,zB,Li,Di,z2,p2,ki_piezas,Dt)
  [Qj,~,~,~,~,~,~] = punto_funcionamiento(kv, Qc,Hc,etac,NPSHrc, ...
                       g,ro,nu,eps,Ls,Ds,z1,p1,ks,zB,Li,Di,z2,p2,ki_piezas,Dt);
end
kv_lo = 1; kv_hi = 200;
for iter = 1:40
  kv_mid = (kv_lo+kv_hi)/2;
  Qmid = Q_de_kv(kv_mid, Qc,Hc,etac,NPSHrc,g,ro,nu,eps,Ls,Ds,z1,p1,ks,zB,Li,Di,z2,p2,ki_piezas,Dt);
  if Qmid > Qtarget
    kv_lo = kv_mid;   % falta mas perdida para bajar Q
  else
    kv_hi = kv_mid;
  end
end
kv2 = (kv_lo+kv_hi)/2;

[Qpf2,Hpf2,eta2,fi2,fs2,NPSHd2,NPSHr2] = punto_funcionamiento(kv2, Qc,Hc,etac,NPSHrc, ...
                       g,ro,nu,eps,Ls,Ds,z1,p1,ks,zB,Li,Di,z2,p2,ki_piezas,Dt);

fprintf('\n=== PARTE 4: nuevo punto de funcionamiento (Q objetivo=0.15 m3/s) ===\n');
fprintf('kv necesario = %.2f\n', kv2);
fprintf('Q  = %.4f m3/s\n', Qpf2);
fprintf('H  = %.2f m\n', Hpf2);
fprintf('f succion  = %.4f\n', fs2);
fprintf('f impulsion = %.4f\n', fi2);

fprintf('\n=== PARTE 5: cavitacion con kv=%.1f ===\n', kv2);
fprintf('NPSHdisp = %.3f m\n', NPSHd2);
fprintf('NPSHreq  = %.3f m\n', NPSHr2);
if NPSHd2 < NPSHr2
  fprintf('=> CAVITA\n');
else
  fprintf('=> NO cavita (margen = %.2f m)\n', NPSHd2-NPSHr2);
end
fprintf('(La valvula esta en el tramo de impulsion => NPSHdisp NO depende de kv;\n');
fprintf(' cambia solo porque el punto de funcionamiento se desplaza a menor Q.)\n');
