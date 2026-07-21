% Ejercicio4_bombas_serie.m — Examen 7/feb/2019, Ejercicio 4.
% Sistema de bombeo urbano: tanque de succion (cota -1m, abierto) hacia
% tanque de impulsion elevado (cota +50m, abierto). Succion D=100mm
% L=2m ks=1; impulsion D=75mm L=60m ki=3; rugosidad 0.05mm ambas
% tuberias. Bombas identicas (tabla Q-H-eta-NPSHr del enunciado),
% ubicables en cota 0m. Se pide: 1) numero minimo de bombas y
% configuracion viable; 2) punto de funcionamiento, potencia y chequeo
% de cavitacion. Adaptado de RESUMEN EXAMEN/Codigos/Bombas/Bombas_serie.m
% (mismo enfoque: iterar Q, calcular curva de instalacion vs. curva de
% bombas en serie, buscar interseccion). Requiere colebrook.m.
clc; clear;

g = 9.81;
ro = 1000;
nu = 0.000001;
epsilon = 0.00005; % m (0.05 mm), ambas tuberias

% Succion
Ls = 2;      % m
Ds = 0.100;  % m
z1 = -1;     % cota tanque de succion (m)
ks = 1;
p1 = 0;      % tanque abierto

% Cota de las bombas
zB = 0;      % ambas bombas ubicadas en cota 0 m

% Impulsion
Li = 60;     % m
Di = 0.075;  % m
ki = 3;
z2 = 50;     % cota tanque de impulsion (m)
p2 = 0;      % tanque abierto

% Curva de catalogo de la bomba (identica para ambas)
Qcat = [0.0 2.5 5.0 7.5 10.0 12.5 15.0]/1000; % m3/s
Hcat = [39 38 35 31 26 20 13];                 % m
etacat = [0 45 66 70 67 57 40];                % %
NPSHrcat = [4.0 4.5 5.3 6.5 8.0 10.0 13.0];    % m

%% ---------- Parte 1: numero minimo de bombas ----------
Dz_estatico = z2 - z1;
printf('Desnivel estatico a vencer: z2-z1 = %.0f - (%.0f) = %.1f m\n', z2, z1, Dz_estatico);
printf('Carga maxima de UNA bomba (Q=0): H=%.0f m < %.1f m => 1 sola bomba NO alcanza\n', Hcat(1), Dz_estatico);
printf('Carga maxima de 2 bombas en SERIE (Q=0): 2*%.0f=%.0f m > %.1f m => 2 en serie SI alcanzan\n', Hcat(1), 2*Hcat(1), Dz_estatico);
printf('(en paralelo la carga maxima sigue siendo %.0f m < %.1f m: no alcanza sin importar cuantas)\n', Hcat(1), Dz_estatico);
printf('=> CONFIGURACION: minimo 2 bombas EN SERIE\n\n');

%% ---------- Parte 2: punto de funcionamiento ----------
Q = linspace(0.0001, max(Qcat), 400);
Hb1 = interp1(Qcat,Hcat,Q,'pchip');
Hb_serie = 2*Hb1; % 2 bombas iguales en serie: se suman las cargas a igual Q

As = pi*Ds^2/4;
Ai = pi*Di^2/4;

Hinst = zeros(size(Q));
NPSHdisp1 = zeros(size(Q));
NPSHdisp2 = zeros(size(Q));
for i = 1:length(Q)
  vs = Q(i)/As;
  Re_s = vs*Ds/nu;
  fs = colebrook(Re_s, epsilon/Ds);
  deltaS = fs*Ls/Ds*vs^2/(2*g) + ks*vs^2/(2*g);
  HA = z1 + p1/(ro*g) + vs^2/(2*g) - deltaS; % carga antes de la 1ra bomba

  vi = Q(i)/Ai;
  Re_i = vi*Di/nu;
  fi = colebrook(Re_i, epsilon/Di);
  deltaI = fi*Li/Di*vi^2/(2*g) + ki*vi^2/(2*g);
  HB = z2 + p2/(ro*g) + vi^2/(2*g) + deltaI; % carga despues de la 2da bomba (salida al tanque)

  Hinst(i) = HB - HA;

  NPSHdisp1(i) = 10.1 + HA - zB - vs^2/(2*g);            % bomba 1 (primera en serie)
  NPSHdisp2(i) = 10.1 + HA - zB - vs^2/(2*g) + Hb1(i);   % bomba 2 (tras ganar Hb1)
end

[~, idx] = min(abs(Hb_serie - Hinst));
Qpf = Q(idx);
Hpf_serie = Hb_serie(idx);
Hpf_1bomba = Hb1(idx);
eta_pf = interp1(Qcat, etacat, Qpf, 'pchip');
NPSHr_pf = interp1(Qcat, NPSHrcat, Qpf, 'pchip');

printf('Q funcionamiento = %.5f m3/s = %.3f L/s\n', Qpf, Qpf*1000);
printf('H instalacion (=H bombas serie) en el PF = %.2f m\n', Hpf_serie);
printf('H por cada bomba (igual, en serie) = %.2f m\n', Hpf_1bomba);
printf('Rendimiento de cada bomba en el PF = %.1f %%\n', eta_pf);
printf('NPSHr de cada bomba en el PF = %.2f m\n\n', NPSHr_pf);

%% ---------- Potencias ----------
P1 = ro*g*Qpf*Hpf_1bomba/(eta_pf/100);
P2 = P1; % bombas identicas, mismo Q, mismo H, mismo eta
Ptotal = P1+P2;
printf('Potencia consumida por cada bomba = %.3f kW\n', P1/1000);
printf('Potencia consumida por el sistema (2 bombas) = %.3f kW\n\n', Ptotal/1000);

%% ---------- Cavitacion ----------
NPSHd1_pf = NPSHdisp1(idx);
NPSHd2_pf = NPSHdisp2(idx);
printf('NPSHdisp Bomba 1 (primera en serie, la mas comprometida) = %.3f m\n', NPSHd1_pf);
printf('NPSHdisp Bomba 2 (segunda en serie) = %.3f m\n', NPSHd2_pf);
printf('NPSHr (ambas, en el PF) = %.3f m\n', NPSHr_pf);
if NPSHd1_pf < NPSHr_pf
  printf('=> La bomba 1 CAVITA\n');
else
  printf('=> La bomba 1 NO cavita (NPSHdisp=%.2f > NPSHr=%.2f)\n', NPSHd1_pf, NPSHr_pf);
end
if NPSHd2_pf < NPSHr_pf
  printf('=> La bomba 2 CAVITA\n');
else
  printf('=> La bomba 2 NO cavita (NPSHdisp=%.2f > NPSHr=%.2f)\n', NPSHd2_pf, NPSHr_pf);
end
