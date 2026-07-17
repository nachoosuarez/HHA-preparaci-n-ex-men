%% Examen HHA - Julio 2024 - Ejercicio 1
% Canal rectangular infinito, compuerta de fondo en x=0, escalon (Dz=0.5m,
% suave, sin perdidas) en x=200m, continuando indefinidamente aguas abajo.
% Requiere en la misma carpeta: rect_geom.m, Mom_rect.m, froude_rect.m,
% Eesp_rect.m, critico_rect.m, manning_rect.m, rect.m, critico.m
clear all
close all

%% Datos
b  = 10;      % ancho (m)
S0 = 0.001;   % pendiente de fondo
n  = 0.015;   % n de Manning
Q  = 70;      % caudal (m3/s)
a  = 0.8;     % apertura de la compuerta (m), compuerta ideal (Cc=1 => y aguas abajo = a)
dz = 0.5;     % elevacion suave del fondo en el escalon (m)
Lgate_step = 200; % distancia compuerta -> escalon (m)
g = 9.8;

%% 1) Tirante critico y normal -> clasificacion M o S
yc = critico_rect(b,Q);
par_n = [Q b S0 n];
yn = fsolve(@(y) manning_rect(y,par_n), (Q*n/(b*S0^0.5))^(3/5));
if yn > yc
  tipo = 'M';
else
  tipo = 'S';
end
printf('yc = %.4f m ; yn = %.4f m ; canal tipo %s\n', yc, yn, tipo);

%% 2) Compuerta: aguas abajo y2=a (compuerta ideal, sin perdidas ni contraccion)
[E2,~] = Eesp_rect(a,b,Q);
% tirante subcritico conjugado en energia (aguas arriba de la compuerta)
y1_gate = fsolve(@(y) Eesp_rect(y,b,Q)-E2, yn);
printf('Aguas arriba de la compuerta (M1, remanso): y1 = %.4f m (E = %.4f m)\n', y1_gate, E2);
printf('Aguas abajo de la compuerta (vena contraida): y2 = a = %.4f m (E = %.4f m)\n', a, E2);

%% 3) Escalon: E1(antes) = dz + E2(despues); aguas abajo del escalon y=yn (flujo ~normal, sigue indefinido)
[Em_yn,~] = Eesp_rect(yn,b,Q);
E1_step = dz + Em_yn;
y1_step = fsolve(@(y) Eesp_rect(y,b,Q)-E1_step, yn*1.2);
printf('Antes del escalon (x=200m): y = %.4f m (E=%.4f m) ; despues del escalon: y=yn=%.4f m\n', y1_step, E1_step, yn);

%% 4) Curva M3 (supercritica) aguas abajo de la compuerta, x: 0 -> 200
par = [Q b S0 n yc];
opt_sup = odeset('Events', @(x,y) critico(x,y,par), 'MaxStep', 0.5);
[x_sup,y_sup] = ode23(@(x,y) rect(x,y,par), [1e-4 Lgate_step], a, opt_sup);

%% 5) Curva M1 (subcritica) aguas arriba del escalon, integrada desde x=200 hacia x=0
opt_sub = odeset('MaxStep', 0.5);
[x_sub,y_sub] = ode23(@(x,y) rect(x,y,par), [Lgate_step 1e-4], y1_step, opt_sub);
% reordenar creciente en x para poder interpolar
[x_sub_s, idx] = sort(x_sub);
y_sub_s = y_sub(idx);

%% 6) Resalto: buscar x donde el conjugado de la rama supercritica iguala la rama subcritica
function d = brecha_conjugado(xq, x_sup, y_sup, x_sub_s, y_sub_s, b, Q)
  ysup_x = interp1(x_sup, y_sup, xq, 'linear','extrap');
  [~, yconj] = Mom_rect(ysup_x, b, Q);
  ysub_x = interp1(x_sub_s, y_sub_s, xq, 'linear','extrap');
  d = yconj - ysub_x;
end

xs = linspace(0.01, min(max(x_sup), Lgate_step-0.01), 4000);
ds = arrayfun(@(xq) brecha_conjugado(xq, x_sup, y_sup, x_sub_s, y_sub_s, b, Q), xs);
isign = find(sign(ds(1:end-1)) ~= sign(ds(2:end)), 1);
x_jump = fzero(@(xq) brecha_conjugado(xq, x_sup, y_sup, x_sub_s, y_sub_s, b, Q), [xs(isign) xs(isign+1)]);
y1_jump = interp1(x_sup, y_sup, x_jump, 'linear','extrap');
[~, y2_jump] = Mom_rect(y1_jump, b, Q);
printf('RESALTO en x = %.2f m (aguas abajo de la compuerta): y1 = %.4f m -> y2 = %.4f m\n', x_jump, y1_jump, y2_jump);

%% 7) Fuerza sobre la compuerta (control de volumen entre y1_gate y a)
[M1g,~] = Mom_rect(y1_gate, b, Q);
[M2g,~] = Mom_rect(a, b, Q);
gamma = 9800;
F_compuerta = gamma*(M1g - M2g);
printf('Fuerza sobre la compuerta = %.0f N = %.3g N\n', F_compuerta, F_compuerta);

%% 8) Fuerza sobre el escalon (control de volumen entre y1_step y yn)
[M1e,~] = Mom_rect(y1_step, b, Q);
[M2e,~] = Mom_rect(yn, b, Q);
F_escalon = gamma*(M1e - M2e);
printf('Fuerza sobre el escalon = %.0f N = %.3g N\n', F_escalon, F_escalon);

%% Grafico del perfil de la superficie libre
figure(1); clf; hold on
% Cota de fondo referida al fondo en x=0 (subida en el escalon)
zb = @(x) -S0*x + (x>=Lgate_step)*dz;
xx_up = linspace(-150,0,200);          % aguas arriba de la compuerta (M1 hacia yn)
% aproximacion: curva M1 aguas arriba de la compuerta tiende a yn lejos
par_up = [Q b S0 n yc];
opt_up = odeset('MaxStep',0.5);
[xu,yu] = ode23(@(x,y) rect(x,y,par_up), [0 -150], y1_gate, opt_up);
plot(xu, -S0*xu + yu, 'b-','LineWidth',2)      % aguas arriba compuerta (x<0)
plot([0 0], [-0.1 y1_gate-S0*0], 'k-','LineWidth',3) % compuerta (simbolica)
plot(x_sup, -S0*x_sup + y_sup, 'r-','LineWidth',2)   % M3 supercritica
plot([x_jump x_jump],[-S0*x_jump+y1_jump -S0*x_jump+y2_jump],'m--','LineWidth',2) % resalto
plot(x_sub_s(x_sub_s>=x_jump), -S0*x_sub_s(x_sub_s>=x_jump)+y_sub_s(x_sub_s>=x_jump),'b-','LineWidth',2) % M1 tras resalto
plot([Lgate_step Lgate_step],[-S0*Lgate_step+y1_step -S0*Lgate_step+dz+yn],'k-','LineWidth',3) % escalon
xd = linspace(Lgate_step, Lgate_step+150,200);
plot(xd, -S0*Lgate_step+dz+yn -S0*(xd-Lgate_step), 'b-','LineWidth',2) % aguas abajo, ~normal
plot([-150 Lgate_step+150],[-S0*(-150) -S0*(Lgate_step+150)+dz],'k:') % referencia fondo aprox (discontinua en el escalon)
xlabel('x (m)'); ylabel('cota (m), referida al fondo en x=0');
title('Ejercicio 1 - Perfil de la superficie libre (compuerta + escalon)');
legend('remanso M1 aguas arriba compuerta','compuerta','M3 (supercritico)','resalto hidraulico','M1 tras el resalto','escalon','aguas abajo (~y_n)','Location','southoutside','Orientation','horizontal')
grid on
print('ej1_perfil.png','-dpng','-r120')

printf('\n--- RESUMEN ---\n');
printf('Tipo de canal: %s (yc=%.3f m, yn=%.3f m)\n', tipo, yc, yn);
printf('y aguas arriba compuerta = %.3f m ; y aguas abajo compuerta (vena contraida) = %.3f m\n', y1_gate, a);
printf('Resalto en x=%.2f m: %.3f m -> %.3f m\n', x_jump, y1_jump, y2_jump);
printf('y antes del escalon (x=200m) = %.3f m ; y despues del escalon = yn = %.3f m\n', y1_step, yn);
printf('Fuerza sobre la compuerta = %.3g N\n', F_compuerta);
printf('Fuerza sobre el escalon   = %.3g N\n', F_escalon);
