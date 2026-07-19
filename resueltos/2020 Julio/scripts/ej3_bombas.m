% ej3_bombas.m -- Examen HHA 7/jul/2020, Ejercicio 3
% Tres bombas identicas en paralelo, con succion e impulsion COMUNES,
% entre un tanque inferior (succion) y un tanque elevado (descarga
% sumergida). Punto de funcionamiento, potencias, cavitacion y nivel
% minimo del tanque inferior sin cavitar.
clear all
addpath('.');
g = 9.81; ro = 1000; nu = 1e-6;
patm_pvap = 10.09; % (patm-pvap)/gamma, agua ~20 C (10.33-0.24)

%% ==== DATOS DE ENTRADA ====
zT1 = -3;      % cota superficie libre tanque de succion (m)
zB  = 1;       % cota de las bombas (m)
zT2 = 14;      % cota superficie libre tanque elevado (m), descarga sumergida

Ds = 0.100; Ls = 7;  epsS = 0.02e-3; ks = 2;   % succion comun
Di = 0.100; Li = 20; epsI = 0.02e-3; ki = 5;   % impulsion comun

Nbombas = 3;
Qcat = [0 1.5 3.0 4.5 6.0 7.5 9.0 10.5]/1000;      % m3/s (por bomba)
Hcat = [26.0 25.7 25.0 23.3 21.5 19.0 16.0 11.0];  % m
etacat = [0 30 53 64 67 65 58 43];                 % %
NPSHrcat = [1.3 1.6 2.1 2.8 3.6 4.5 5.5 6.6];       % m

As = pi*Ds^2/4; Ai = pi*Di^2/4;

%% ==== curva de instalacion y curva equivalente (3 bombas en paralelo) ====
function [Hm,f_s,f_i,vs,vi] = instalacion(Qtot,Ds,Ls,epsS,ks,Di,Li,epsI,ki,zT1,zT2,g,nu)
  As = pi*Ds^2/4; Ai = pi*Di^2/4;
  vs = Qtot/As; vi = Qtot/Ai;
  Res = vs*Ds/nu; Rei = vi*Di/nu;
  f_s = colebrook(max(Res,2300), epsS/Ds);
  f_i = colebrook(max(Rei,2300), epsI/Di);
  dHs = (ks + f_s*Ls/Ds)*vs^2/(2*g);
  dHi = (ki + f_i*Li/Di)*vi^2/(2*g);
  Hm = (zT2 - zT1) + dHs + dHi;
end

Qtot_mesh = linspace(0.001, Nbombas*Qcat(end), 300);
Hinst = zeros(size(Qtot_mesh));
for i=1:length(Qtot_mesh)
  Hinst(i) = instalacion(Qtot_mesh(i),Ds,Ls,epsS,ks,Di,Li,epsI,ki,zT1,zT2,g,nu);
end

Qeq = Nbombas*Qcat;  % curva equivalente: mismo H, Q escalado x3 (bombas identicas)
Heq_mesh = interp1(Qeq, Hcat, Qtot_mesh, 'pchip');

% punto de funcionamiento: interseccion Hinst(Q) = Heq(Q)
diffH = Heq_mesh - Hinst;
idxsign = find(diffH(1:end-1).*diffH(2:end) <= 0, 1);
Qpf = fzero(@(Q) interp1(Qeq,Hcat,Q,'pchip') - instalacion(Q,Ds,Ls,epsS,ks,Di,Li,epsI,ki,zT1,zT2,g,nu), ...
            [Qtot_mesh(idxsign), Qtot_mesh(idxsign+1)]);
Hpf = interp1(Qeq, Hcat, Qpf, 'pchip');
Qpf_porbomba = Qpf/Nbombas;
[~,f_s_pf,f_i_pf,vs_pf,vi_pf] = instalacion(Qpf,Ds,Ls,epsS,ks,Di,Li,epsI,ki,zT1,zT2,g,nu);

printf('=== Punto de funcionamiento ===\n');
printf('Qtotal = %.5f m3/s = %.3f L/s\n', Qpf, Qpf*1000);
printf('Q por bomba = %.5f m3/s = %.3f L/s\n', Qpf_porbomba, Qpf_porbomba*1000);
printf('H = %.3f m\n', Hpf);
printf('f succion = %.5f , f impulsion = %.5f\n', f_s_pf, f_i_pf);
printf('v succion = %.3f m/s , v impulsion = %.3f m/s\n', vs_pf, vi_pf);

%% ==== potencias ====
eta_pf = interp1(Qcat, etacat, Qpf_porbomba, 'pchip');
P_unit = ro*g*Qpf_porbomba*Hpf/(eta_pf/100);   % W, por bomba
P_total = Nbombas*P_unit;
printf('\n=== Potencias ===\n');
printf('Eficiencia de cada bomba en el PF = %.2f %%\n', eta_pf);
printf('Potencia de cada bomba = %.3f kW\n', P_unit/1000);
printf('Potencia del sistema (3 bombas)   = %.3f kW\n', P_total/1000);

%% ==== cavitacion ====
% NPSH disponible: comun a las 3 bombas, con el caudal TOTAL en la
% succion comun (bomba en aspiracion, zB>zT1)
dHs_pf = (ks + f_s_pf*Ls/Ds)*vs_pf^2/(2*g);
NPSHdisp_pf = patm_pvap - (zB - zT1) - dHs_pf;
NPSHreq_pf = interp1(Qcat, NPSHrcat, Qpf_porbomba, 'pchip');
printf('\n=== Cavitacion (en el punto de funcionamiento) ===\n');
printf('NPSH disponible = %.3f m\n', NPSHdisp_pf);
printf('NPSH requerido (a Q por bomba)= %.3f m\n', NPSHreq_pf);
if NPSHdisp_pf > NPSHreq_pf
  printf('=> Las bombas NO cavitan\n');
else
  printf('=> Las bombas SI cavitan\n');
end

%% ==== nivel minimo del tanque inferior sin cavitar ====
% Al bajar zT1, sube Hm(Q) (mayor desnivel estatico) => el PF se mueve a
% menor Q; a la vez baja el NPSHdisp (mayor desnivel de succion). Se
% busca el zT1 limite (minimo) tal que, en el NUEVO punto de
% funcionamiento correspondiente, NPSHdisp(zT1,Q)=NPSHreq(Q) exactamente.
function res = residuo_zT1(zT1_try, Ds,Ls,epsS,ks,Di,Li,epsI,ki,zT2,g,nu,Nbombas,Qeq,Hcat,Qcat,NPSHrcat,zB,patm_pvap)
  Qmesh = linspace(0.001, Nbombas*Qcat(end), 300);
  Hinst_ = zeros(size(Qmesh));
  for i=1:length(Qmesh)
    Hinst_(i) = instalacion(Qmesh(i),Ds,Ls,epsS,ks,Di,Li,epsI,ki,zT1_try,zT2,g,nu);
  end
  Heq_ = interp1(Qeq, Hcat, Qmesh, 'pchip');
  diffH_ = Heq_ - Hinst_;
  idxsign_ = find(diffH_(1:end-1).*diffH_(2:end) <= 0, 1);
  if isempty(idxsign_)
    res = NaN; return;
  end
  Qpf_ = fzero(@(Q) interp1(Qeq,Hcat,Q,'pchip') - instalacion(Q,Ds,Ls,epsS,ks,Di,Li,epsI,ki,zT1_try,zT2,g,nu), ...
              [Qmesh(idxsign_), Qmesh(idxsign_+1)]);
  [~,f_s_,~,vs_,~] = instalacion(Qpf_,Ds,Ls,epsS,ks,Di,Li,epsI,ki,zT1_try,zT2,g,nu);
  dHs_ = (ks + f_s_*Ls/Ds)*vs_^2/(2*g);
  NPSHdisp_ = patm_pvap - (zB - zT1_try) - dHs_;
  Qpb_ = Qpf_/Nbombas;
  NPSHreq_ = interp1(Qcat, NPSHrcat, Qpb_, 'pchip');
  res = NPSHdisp_ - NPSHreq_;
end

zT1_min = fzero(@(z) residuo_zT1(z, Ds,Ls,epsS,ks,Di,Li,epsI,ki,zT2,g,nu,Nbombas,Qeq,Hcat,Qcat,NPSHrcat,zB,patm_pvap), zT1);

% resultado final con zT1_min
Qmesh = linspace(0.001, Nbombas*Qcat(end), 300);
Hinst_f = zeros(size(Qmesh));
for i=1:length(Qmesh)
  Hinst_f(i) = instalacion(Qmesh(i),Ds,Ls,epsS,ks,Di,Li,epsI,ki,zT1_min,zT2,g,nu);
end
Heq_f = interp1(Qeq, Hcat, Qmesh, 'pchip');
diffH_f = Heq_f - Hinst_f;
idxsign_f = find(diffH_f(1:end-1).*diffH_f(2:end) <= 0, 1);
Qpf_min = fzero(@(Q) interp1(Qeq,Hcat,Q,'pchip') - instalacion(Q,Ds,Ls,epsS,ks,Di,Li,epsI,ki,zT1_min,zT2,g,nu), ...
            [Qmesh(idxsign_f), Qmesh(idxsign_f+1)]);
[~,f_s_min,~,vs_min,~] = instalacion(Qpf_min,Ds,Ls,epsS,ks,Di,Li,epsI,ki,zT1_min,zT2,g,nu);
Hpf_min = interp1(Qeq, Hcat, Qpf_min, 'pchip');

% redondeo a precision 0.05 m, HACIA EL LADO SEGURO (no cavitar): subir
zT1_min_seguro = ceil(zT1_min/0.05)*0.05;

printf('\n=== Nivel minimo del tanque inferior sin cavitar ===\n');
printf('zT1_min (exacto)  = %.4f m\n', zT1_min);
printf('zT1_min (redondeo 0.05 m, lado seguro) = %.2f m\n', zT1_min_seguro);
printf('En ese nivel limite: Qtotal = %.5f m3/s = %.3f L/s, H = %.3f m, f_succion=%.5f\n', ...
        Qpf_min, Qpf_min*1000, Hpf_min, f_s_min);

%% ==== graficos ====
figure(1); clf; hold on; grid on;
plot(Qcat*1000, Hcat, 'o-', 'Color',[1 0.5 0], 'LineWidth',1.2);
plot(Qeq*1000, Hcat, 'b-', 'LineWidth',1.5);
plot(Qtot_mesh*1000, Hinst, 'm-', 'LineWidth',1.5);
plot(Qpf*1000, Hpf, 'o', 'MarkerSize',8, 'MarkerFaceColor',[0.5 0 1], 'MarkerEdgeColor','none');
plot([Qpf Qpf]*1000, [0 Hpf], 'k--','HandleVisibility','off');
plot([0 Qpf]*1000, [Hpf Hpf], 'k--','HandleVisibility','off');
xlabel('Q (L/s)'); ylabel('H (m)');
legend('Curva de 1 bomba','Curva equivalente (3 en paralelo)','Curva de instalacion', ...
       'Punto de funcionamiento','Location','northeast');
title('Ejercicio 3 -- 3 bombas en paralelo: punto de funcionamiento');
print('ej3_HQ.png','-dpng','-r120');

figure(2); clf; hold on; grid on;
NPSHdisp_curve = zeros(size(Qtot_mesh));
for i=1:length(Qtot_mesh)
  [~,f_s_i,~,vs_i,~] = instalacion(Qtot_mesh(i),Ds,Ls,epsS,ks,Di,Li,epsI,ki,zT1,zT2,g,nu);
  dHs_i = (ks + f_s_i*Ls/Ds)*vs_i^2/(2*g);
  NPSHdisp_curve(i) = patm_pvap - (zB-zT1) - dHs_i;
end
plot(Qtot_mesh*1000, NPSHdisp_curve, 'g-', 'LineWidth',1.5);
plot(Qcat*1000, NPSHrcat, 'r--', 'LineWidth',1.5);
plot(Qpf_porbomba*1000, NPSHreq_pf, 'o', 'MarkerSize',7,'MarkerFaceColor','r','MarkerEdgeColor','none');
plot(Qpf*1000, NPSHdisp_pf, 'o', 'MarkerSize',7,'MarkerFaceColor',[0 0.5 0],'MarkerEdgeColor','none');
xlabel('Q (L/s)'); ylabel('NPSH (m)');
legend('NPSH disponible (vs Qtotal, succion comun)','NPSH requerido (vs Q por bomba)', ...
       'NPSHreq en el PF','NPSHdisp en el PF','Location','northeast');
title('Ejercicio 3 -- NPSH disponible vs requerido');
print('ej3_NPSH.png','-dpng','-r120');
printf('\nGraficos guardados: ej3_HQ.png, ej3_NPSH.png\n');
