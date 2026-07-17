%% Examen HHA - Julio 2024 - Ejercicio 4
% Sistema de bombeo entre dos tanques A (succion) y B (impulsion, entrega
% ahogada dentro del tanque B, sin velocidad de salida libre).
% Requiere en la misma carpeta: colebrook.m
clear all
close all

%% Datos
zA = 10;      % cota superficie libre tanque A (m)
zB = 50;      % cota superficie libre tanque B (m)
zbomba = 13;  % cota de la bomba (m)
D  = 0.30;    % diametro interno, igual en succion e impulsion (m)
eps = 0.001e-3; % rugosidad absoluta (m)
Ls = 30;      % longitud succion (m)
Li = 300;     % longitud impulsion (m)
Ltot = Ls+Li; % mismo D en todo el recorrido -> se puede sumar
nu = 1e-6;    % viscosidad cinematica del agua (m2/s)
g  = 9.8;
gamma = 9800;

A = pi*D^2/4;
K = eps/D;    % rugosidad relativa

%% Curvas caracteristicas de la bomba (tabla del enunciado)
Q_tab    = [0 0.05 0.10 0.15 0.20 0.25 0.30 0.35 0.40 0.45];
H_tab    = [55.9 55.7 54.9 53.4 51.8 50 48.1 46.4 45 44.1];
NPSHr_tab= [1.6 1.7 1.8 1.9 2.0 2.2 2.4 2.7 2.9 3.2];
eta_tab  = [57 66 73 78 81 82 81 79 75 68]/100;

%% 1) Punto de funcionamiento: H_instalacion(Q) = H_bomba(Q)
% H_inst(Q) = (zB-zA) + f(Q)*(Ltot/D)*V^2/(2g)   (misma tuberia, sin perdidas localizadas)
function H = H_inst(Q, zA, zB, Ltot, D, A, K, nu, g)
  if Q<=0
    H = zB-zA;
    return
  end
  V = Q/A;
  Re = V*D/nu;
  f = colebrook(Re, K);
  H = (zB-zA) + f*(Ltot/D)*V^2/(2*g);
end

Qv = linspace(0.001,0.45,3000);
Hinst_v = arrayfun(@(Q) H_inst(Q,zA,zB,Ltot,D,A,K,nu,g), Qv);
Hbomba_v = interp1(Q_tab, H_tab, Qv, 'linear');
diffv = Hinst_v - Hbomba_v;
isign = find(sign(diffv(1:end-1)) ~= sign(diffv(2:end)), 1);
Qpf = fzero(@(Q) H_inst(Q,zA,zB,Ltot,D,A,K,nu,g) - interp1(Q_tab,H_tab,Q,'linear'), ...
            [Qv(isign) Qv(isign+1)]);
Hpf = interp1(Q_tab, H_tab, Qpf, 'linear');
Vpf = Qpf/A;
Repf = Vpf*D/nu;
fpf = colebrook(Repf, K);
eta_pf = interp1(Q_tab, eta_tab, Qpf, 'linear');
NPSHr_pf = interp1(Q_tab, NPSHr_tab, Qpf, 'linear');

printf('Punto de funcionamiento: Q = %.4f m3/s ; H = %.3f m\n', Qpf, Hpf);
printf('f = %.4f ; Re = %.3e ; V = %.3f m/s ; eta = %.3f ; NPSHreq = %.3f m\n', fpf, Repf, Vpf, eta_pf, NPSHr_pf);

%% Potencia consumida
Pot = gamma*Qpf*Hpf/eta_pf;
printf('Potencia = gamma*Q*H/eta = %.0f W = %.2f kW\n', Pot, Pot/1000);

%% 2) NPSH disponible y verificacion de cavitacion
Patm_Pvap_gamma = 10.33 - 0.24;  % (Patm-Pvap)/gamma, agua a temp. ambiente (valor usual del curso)
hs_pf = fpf*(Ls/D)*Vpf^2/(2*g);  % perdida de carga solo en la succion
NPSHd_pf = Patm_Pvap_gamma - (zbomba-zA) - hs_pf;
printf('\nhs (succion) = %.4f m\n', hs_pf);
printf('NPSHd = (Patm-Pvap)/gamma - (zbomba-zA) - hs = %.4f m\n', NPSHd_pf);
printf('NPSHreq = %.4f m => %s (margen = %.3f m)\n', NPSHr_pf, ...
  merge(NPSHd_pf>NPSHr_pf,'NO CAVITA','CAVITA'), NPSHd_pf-NPSHr_pf);

%% 3) Cota maxima de la bomba sin cavitar (mismo Q, mismas longitudes)
zbomba_max = zA + Patm_Pvap_gamma - hs_pf - NPSHr_pf;
printf('\nCota maxima de la bomba sin cavitar: zbomba_max = %.3f m\n', zbomba_max);

%% Graficos
figure(1); clf; hold on
plot(Qv*1000, Hinst_v, '-r', 'LineWidth', 2)
plot(Q_tab*1000, H_tab, 'o-b', 'LineWidth', 2)
plot(Qpf*1000, Hpf, 'ok', 'MarkerFaceColor','k','MarkerSize',8)
xlabel('Q (L/s)'); ylabel('H (m)')
legend('Curva de la instalacion','Curva de la bomba','Punto de funcionamiento','Location','northeast')
title('Ejercicio 4 - Punto de funcionamiento')
grid on
print('ej4_HQ.png','-dpng','-r120')

figure(2); clf; hold on
NPSHd_v = Patm_Pvap_gamma - (zbomba-zA) - arrayfun(@(Q) colebrook(Q/A*D/nu, K)*(Ls/D)*(Q/A)^2/(2*g), Qv);
NPSHr_v = interp1(Q_tab, NPSHr_tab, Qv, 'linear');
plot(Qv*1000, NPSHd_v, '-b', 'LineWidth', 2)
plot(Qv*1000, NPSHr_v, '-r', 'LineWidth', 2)
plot(Qpf*1000, NPSHd_pf, 'ok', 'MarkerFaceColor','b','MarkerSize',8)
plot(Qpf*1000, NPSHr_pf, 'ok', 'MarkerFaceColor','r','MarkerSize',8)
xlabel('Q (L/s)'); ylabel('NPSH (m)')
legend('NPSH disponible','NPSH requerido','Condicion de operacion (disp.)','Condicion de operacion (req.)','Location','northeast')
title('Ejercicio 4 - NPSH disponible vs. requerido')
grid on
print('ej4_NPSH.png','-dpng','-r120')

printf('\n--- RESUMEN ---\n');
printf('Q = %.4f m3/s = %.1f L/s ; H = %.2f m ; f = %.4f ; eta = %.1f %%\n', Qpf, Qpf*1000, Hpf, fpf, eta_pf*100);
printf('Potencia = %.2f kW\n', Pot/1000);
printf('NPSHd = %.2f m ; NPSHreq = %.2f m => %s\n', NPSHd_pf, NPSHr_pf, merge(NPSHd_pf>NPSHr_pf,'NO CAVITA','CAVITA'));
printf('Cota maxima de la bomba sin cavitar = %.2f m\n', zbomba_max);
