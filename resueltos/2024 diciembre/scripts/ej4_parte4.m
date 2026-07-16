%% EJERCICIO 4 - Parte 4 (Examen HHA diciembre 2024)
% Restringir la velocidad de salida de la impulsion a V < 1.4 m/s, cerrando
% la valvula tipo esclusa. Se busca la posicion que permita bombear el
% MAYOR caudal posible cumpliendo la restriccion.
%
% Requiere en la misma carpeta: colebrook.m
clc; clear; close all;
g = 9.81; ro = 1000; nu = 1e-6;

eps1 = 0.002e-3; eps2 = 0.002e-3;
z1 = -5;  Ls = 10;  Ds = 0.06;  ks = 5;
zA = 0;
z2 = 18;  Li = 100; Di = 0.06;
kv_abierta = 0.1;               % coeficiente de la valvula, totalmente abierta
k2_base = 4 - kv_abierta;        % = 3.9: perdida de la impulsion SIN la valvula

Q_tab    = [0.125 0.5 1 1.5 2 2.5 3 3.5 4 4.5 5 5.5]/1000;
H_tab    = [31.4 31.3 31.1 30.8 30.5 30.1 29.7 29.2 28.6 28.0 26.9 25.2];
eta_tab  = [23 52 66 74 78 82 85 88 89 88 86 83];
NPSHr_tab= [1.50 1.60 1.75 1.90 2.05 2.30 2.65 3.00 3.35 3.65 4.00 4.30];

Qmalla = linspace(min(Q_tab), max(Q_tab), 4000);
Hb = interp1(Q_tab, H_tab, Qmalla, 'pchip');

As = pi*Ds^2/4;
Ai = pi*Di^2/4;

function [Qpf,Hpf,f1pf,f2pf,Vexit,Hm] = punto_func(kv, k2_base, Qmalla, Hb, ...
                                          z1,Ls,Ds,ks,z2,Li,Di,g,nu,eps1,eps2)
  As = pi*Ds^2/4; Ai = pi*Di^2/4;
  Hm = zeros(size(Qmalla));
  for i=1:length(Qmalla)
    Qi = Qmalla(i);
    vs = Qi/As; Re1 = vs*Ds/nu; f1 = colebrook(Re1, eps1/Ds);
    hs = (ks + f1*Ls/Ds) * vs^2/(2*g);
    Ha = z1 - hs;
    vi = Qi/Ai; Re2 = vi*Di/nu; f2 = colebrook(Re2, eps2/Di);
    k2 = k2_base + kv;
    hi = (k2 + f2*Li/Di) * vi^2/(2*g);
    Hm(i) = (z2 + vi^2/(2*g)) - Ha + hi;
  end
  [~,idx] = min(abs(Hb-Hm));
  Qpf = Qmalla(idx); Hpf = Hb(idx);
  vs = Qpf/As; Re1=vs*Ds/nu; f1pf=colebrook(Re1,eps1/Ds);
  vi = Qpf/Ai; Re2=vi*Di/nu; f2pf=colebrook(Re2,eps2/Di);
  Vexit = vi;
endfunction

%% a) Probar las posiciones de valvula dadas por el enunciado
posiciones = {'Abierta','1/4 cerrada','1/2 cerrada','3/4 cerrada'};
kvs = [0.1 0.3 2.1 27];
printf('=== PARTE 4a: busqueda de la posicion de valvula ===\n');
printf('Restriccion: V_salida < 1.4 m/s\n\n');
Qs = zeros(1,4); Hs = zeros(1,4); Vs = zeros(1,4);
for j=1:4
  [Qpf,Hpf,~,~,Vexit] = punto_func(kvs(j), k2_base, Qmalla, Hb, z1,Ls,Ds,ks,z2,Li,Di,g,nu,eps1,eps2);
  Qs(j)=Qpf; Hs(j)=Hpf; Vs(j)=Vexit;
  if Vexit < 1.4, estado = 'CUMPLE'; else estado = 'no cumple'; end
  printf('%-14s (kv=%5.2f): Q=%.3f L/s, H=%.3f m, V_salida=%.3f m/s -> %s\n', ...
         posiciones{j}, kvs(j), Qpf*1000, Hpf, Vexit, estado);
end

% La posicion que cumple con el MAYOR caudal es la primera (menos cerrada)
% cuyo V_salida ya es < 1.4 m/s
j_elegida = find(Vs<1.4, 1, 'first');
printf('\n=> Posicion elegida: %s (kv=%.2f) -> el maximo caudal posible\n', ...
       posiciones{j_elegida}, kvs(j_elegida));
printf('   que cumple la restriccion de velocidad.\n');

%% b) Nuevo punto de funcionamiento y grafico H-Q comparativo
kv_sel = kvs(j_elegida);
[Qpf4,Hpf4,f1pf4,f2pf4,Vexit4,Hm4] = punto_func(kv_sel, k2_base, Qmalla, Hb, z1,Ls,Ds,ks,z2,Li,Di,g,nu,eps1,eps2);
printf('\n=== PARTE 4b: nuevo punto de funcionamiento ===\n');
printf('Q4 = %.4f L/s, H4 = %.3f m, f1=f2=%.4f, V_salida=%.3f m/s\n', ...
       Qpf4*1000, Hpf4, f1pf4, Vexit4);

% Curva de la instalacion original (valvula abierta) para comparar
[Qpf1,Hpf1,~,~,~,Hm1] = punto_func(kv_abierta, k2_base, Qmalla, Hb, z1,Ls,Ds,ks,z2,Li,Di,g,nu,eps1,eps2);

figure(1); clf; hold on; grid on;
plot(Qmalla*1000, Hb, 'b-', 'LineWidth',1.5, 'DisplayName','Curva de la bomba');
plot(Qmalla*1000, Hm1, 'm-', 'LineWidth',1.5, 'DisplayName','Instalacion (valvula abierta)');
plot(Qmalla*1000, Hm4, 'g-', 'LineWidth',1.5, 'DisplayName',sprintf('Instalacion (%s)', posiciones{j_elegida}));
plot(Qpf1*1000, Hpf1, 'ko', 'MarkerFaceColor','m', 'MarkerSize',8, 'DisplayName','PF original (abierta)');
plot(Qpf4*1000, Hpf4, 'ko', 'MarkerFaceColor','g', 'MarkerSize',8, 'DisplayName',sprintf('PF nuevo (%s)', posiciones{j_elegida}));
xlabel('Q (L/s)'); ylabel('H (m)');
title('Ej.4 Parte 4: Curva de la instalacion regulando la valvula');
legend('Location','best');
saveas(gcf, 'ej4_HQ_parte4.png');

%% c) Riesgo de cavitacion en la nueva condicion
vs4 = Qpf4/As; Re1_4=vs4*Ds/nu; f1_4=colebrook(Re1_4,eps1/Ds);
hs4 = (ks+f1_4*Ls/Ds)*vs4^2/(2*g);
Ha4 = z1 - hs4;
NPSHdisp4 = Ha4 - zA + 10.1;
NPSHreq4 = interp1(Q_tab, NPSHr_tab, Qpf4, 'pchip');

% valores originales (valvula abierta) para comparar
vs1 = Qpf1/As; Re1_1=vs1*Ds/nu; f1_1=colebrook(Re1_1,eps1/Ds);
hs1 = (ks+f1_1*Ls/Ds)*vs1^2/(2*g);
Ha1 = z1 - hs1;
NPSHdisp1 = Ha1 - zA + 10.1;
NPSHreq1 = interp1(Q_tab, NPSHr_tab, Qpf1, 'pchip');

printf('\n=== PARTE 4c: riesgo de cavitacion ===\n');
printf('Condicion original (valvula abierta): NPSHdisp=%.3f m, NPSHreq=%.3f m, margen=%.3f m\n', ...
       NPSHdisp1, NPSHreq1, NPSHdisp1-NPSHreq1);
printf('Condicion nueva (%s):    NPSHdisp=%.3f m, NPSHreq=%.3f m, margen=%.3f m\n', ...
       posiciones{j_elegida}, NPSHdisp4, NPSHreq4, NPSHdisp4-NPSHreq4);
if (NPSHdisp4-NPSHreq4) > (NPSHdisp1-NPSHreq1)
  printf('=> El margen aumenta: MENOR riesgo de cavitacion que en la condicion original.\n');
  printf('   (NPSHdisp no cambia por la valvula, solo depende de la succion; y como\n');
  printf('   Q4 < Q1, tanto NPSHdisp sube levemente como NPSHreq baja notoriamente.)\n');
else
  printf('=> El margen disminuye: MAYOR riesgo de cavitacion.\n');
end

printf('\n================= RESUMEN PARTE 4 =================\n');
printf('Posicion de valvula: %s (kv=%.2f)\n', posiciones{j_elegida}, kv_sel);
printf('Q4=%.2f L/s, H4=%.2f m, V_salida=%.2f m/s (<1.4 m/s)\n', Qpf4*1000, Hpf4, Vexit4);
printf('Cavitacion: margen aumenta de %.2f m a %.2f m -> MENOR riesgo\n', ...
       NPSHdisp1-NPSHreq1, NPSHdisp4-NPSHreq4);
printf('=====================================================\n');
