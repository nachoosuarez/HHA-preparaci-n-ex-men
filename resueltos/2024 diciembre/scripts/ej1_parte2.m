%% EJERCICIO 1 - PARTE 2 (Examen HHA diciembre 2024)
% Igual que la Parte 1, pero ahora el Lago B sube a h_LB = 2.3 m sobre el
% fondo del canal. Esto impone un control aguas abajo (subcritico) que no
% existia en la Parte 1, generando un resalto hidraulico en el tramo 2.
%
% Requiere en la misma carpeta: trap_geom.m, eq_yc.m, eq_yn.m, froude_trap.m,
% manning_trap.m, critico.m, rect.m, tirantes_yn_yc.m, Mom_trap.m
clear all; close all; clc;
g = 9.8;

%% Datos (identicos a Parte 1, cambia solo h_LB)
b   = 1.2; m1 = 1; m2 = 0.5; n = 0.012; S0 = 0.01;
L1  = 300; L2 = 300; hLA = 1.80;
hLB = 2.3;   % NUEVO nivel del Lago B (m sobre el fondo)

%% 1) El caudal no cambia: el control sigue siendo critico en la entrada
% (el Lago B esta lo suficientemente lejos y el resalto absorbe el efecto
% del remanso, sin llegar a ahogar la entrada). Se reutiliza el resultado
% de la Parte 1.
function e = sistema1(x,b,m,hLA,g)
  Q = x(1); yc = x(2);
  [B,A] = trap_geom(yc,b,m);
  e(1) = (Q^2*B)/(g*A^3) - 1;
  e(2) = hLA - yc - Q^2/(2*g*A^2);
endfunction
sol = fsolve(@(x) sistema1(x,b,m1,hLA,g), [10; 1.3]);
Q   = sol(1);
yc1 = sol(2);
[yn1,~]    = tirantes_yn_yc(Q,n,m1,b,S0);
[yn2,yc2]  = tirantes_yn_yc(Q,n,m2,b,S0);
printf('Q = %.3f m3/s (igual que Parte 1)\n', Q);
printf('Tramo1: yc1=%.4f, yn1=%.4f | Tramo2: yc2=%.4f, yn2=%.4f\n', yc1,yn1,yc2,yn2);
printf('h_LB = %.2f m > yc2 = %.4f m -> el Lago B impone un control SUBCRITICO\n', hLB, yc2);

%% 2) Tramo 1: identico a la Parte 1 (el resalto se forma en tramo 2, lejos de aca)
par1 = [Q b S0 n yc1 m1];
opt1 = odeset('Events', @(x,y) critico(x,y,par1));
[x1,y1] = ode23(@(x,y) rect(x,y,par1), [0 L1], yc1-0.001, opt1);
yend1 = y1(end);

function e = eq_energia(y,b,m,Q,E,g)
  [~,A] = trap_geom(y,b,m);
  e = y + Q^2/(2*g*A^2) - E;
endfunction
[~,A1e] = trap_geom(yend1,b,m1);
E1 = yend1 + Q^2/(2*g*A1e^2);
y2_ini = fsolve(@(y) eq_energia(y,b,m2,Q,E1,g), 1.2);
printf('Transicion a tramo 2 con y = %.4f m (identico a Parte 1)\n', y2_ini);

%% 3) Tramo 2, rama SUPERCRITICA (S2): igual que Parte 1, corriente abajo desde y2_ini
par2 = [Q b S0 n yc2 m2];
optS = odeset('Events', @(x,y) critico(x,y,par2));
[xS,yS] = ode23(@(x,y) rect(x,y,par2), [0 L2], y2_ini, optS);

%% 4) Tramo 2, rama SUBCRITICA (S1): impuesta por el Lago B, y(x=300)=hLB,
% se integra hacia aguas arriba (control aguas abajo)
optB = odeset('Events', @(x,y) critico(x,y,par2));
[xB,yB] = ode23(@(x,y) rect(x,y,par2), [L2 0], hLB, optB);
[xB,idxs] = sort(xB); yB = yB(idxs);
printf('Curva S1 (remanso del Lago B) existe entre x=%.2f m y x=%.2f m (tramo2)\n', min(xB), max(xB));
printf('  => se agota (llega a yc2) a %.2f m aguas arriba del Lago B\n', L2-min(xB));

%% 5) Posicion del resalto: interseccion entre el conjugado de la rama
% supercritica y la rama subcritica (S1)
yconj = NaN(size(xS));
for i=1:length(xS)
  if xS(i) >= min(xB) && xS(i) <= max(xB)
    [~,yc_] = Mom_trap(yS(i),b,m2,Q);
    yconj(i) = yc_;
  end
end
yB_interp = interp1(xB,yB,xS,'linear');
diffy = yconj - yB_interp;
mask = ~isnan(diffy);
xS_m = xS(mask); diffy_m = diffy(mask);
idx = find(diffy_m(1:end-1).*diffy_m(2:end) <= 0);
i = idx(1);
xA_=xS_m(i); xB_=xS_m(i+1);
fA=diffy_m(i); fB=diffy_m(i+1);
x_resalto = xA_ - fA*(xB_-xA_)/(fB-fA);
y_antes    = interp1(xS,yS,x_resalto,'linear');
y_despues  = interp1(xB,yB,x_resalto,'linear');
printf('\n>>> RESALTO en x = %.2f m (tramo2, a %.2f m del Lago A total) <<<\n', x_resalto, L1+x_resalto);
printf('    y1 (antes, supercritico) = %.4f m\n', y_antes);
printf('    y2 (despues, subcritico) = %.4f m\n', y_despues);

%% Grafico del perfil completo
xg1 = x1; zw1 = y1 - xg1*S0;
xS_plot = xS(xS<=x_resalto); yS_plot = yS(xS<=x_resalto);
xB_plot = xB(xB>=x_resalto); yB_plot = yB(xB>=x_resalto);
zwS = yS_plot - (xS_plot+L1)*S0;
zwB = yB_plot - (xB_plot+L1)*S0;

figure(1); clf; hold on; grid on;
plot([0 L1+L2], [0 -(L1+L2)*S0], 'k-', 'LineWidth',2);
plot(xg1, zw1, 'b-', 'LineWidth',2);
plot(xg1(end)+xS_plot, zwS, 'b-', 'LineWidth',2);
plot(xg1(end)+xB_plot, zwB, 'm-', 'LineWidth',2);
plot([L1+x_resalto L1+x_resalto], [y_antes-(x_resalto+L1)*S0, y_despues-(x_resalto+L1)*S0], 'r-','LineWidth',2);
plot(L1+L2, hLB-(L1+L2)*S0, 'ko','MarkerFaceColor','y','MarkerSize',8);
xlabel('x (m) - distancia desde Lago A'); ylabel('cota (m) respecto al fondo en x=0');
title('Ej.1 Parte 2: Perfil con resalto, h_{LB}=2.3 m');
legend('Fondo canal','Sup. libre (supercritico)','Sup. libre tramo2 (supercritico)', ...
       'Sup. libre tramo2 (subcritico, remanso Lago B)','Resalto hidraulico','Nivel Lago B','Location','southoutside');
saveas(gcf, 'ej1_perfil_parte2.png');

printf('\n================= RESUMEN PARTE 2 =================\n');
printf('Q = %.3f m3/s (igual que Parte 1, control critico en la entrada)\n', Q);
printf('Tramo 1 (0-300m): S2, identico a Parte 1, yc1=%.3f -> %.3f m\n', yc1, yend1);
printf('Tramo 2 (300-600m): S2 hasta x=%.2f m (dist. desde Lago A), luego RESALTO\n', L1+x_resalto);
printf('  Resalto: y1=%.3f m -> y2=%.3f m\n', y_antes, y_despues);
printf('Tramo 2 final: S1 (remanso) desde y=%.3f hasta hLB=%.2f m en el Lago B\n', y_despues, hLB);
printf('=====================================================\n');
