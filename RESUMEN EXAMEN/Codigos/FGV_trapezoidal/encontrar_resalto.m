% encontrar_resalto.m â€” ubica automÃ¡ticamente un RESALTO HIDRÃULICO en
% un canal trapezoidal: calcula el perfil de FGV supercrÃ­tico (FGV1,
% aguas arriba) y el perfil subcrÃ­tico (FGV2, aguas abajo), calcula el
% CONJUGADO (vÃ­a Mom_trap.m) de cada punto de FGV1, y encuentra la
% intersecciÃ³n entre ese conjugado y la curva FGV2 â€” ese punto de
% intersecciÃ³n es la posiciÃ³n x del resalto. Grafica todo (FGV1, FGV2,
% conjugado de FGV1, yc, yn) y reporta x del resalto y los tirantes y1,
% y2 a cada lado. Editar las DATOS DE ENTRADA (Q,b,S,n,m) y las
% condiciones iniciales de cada rama (x_ini/x_end/y_ini) segÃºn el
% problema. Usar cuando: se pide encontrar dÃ³nde ocurre el resalto en un
% canal con un tramo supercrÃ­tico seguido de uno subcrÃ­tico (o
% viceversa), sin conocerlo de antemano. Requiere trap_geom.m, rect.m,
% critico.m, froude_trap.m, manning_trap.m, Mom_trap.m.
function encontrar_resalto

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% RESALTO HIDRÁULICO EN CANAL TRAPEZOIDAL
% Visualización completa:
% - FGV1 (supercrítico)
% - Conjugado de FGV1
% - FGV2 (subcrítico)
% - Líneas de yc y yn
% - Intersección entre conjugado(FGV1) y FGV2
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear all; close all; clc;

%% ------------------------------------------------------------------------
% DATOS DE ENTRADA
%% ------------------------------------------------------------------------
Q = 9.8;      % Caudal (m3/s)
b = 1.3;     % Ancho de fondo (m)
S = 0.00;   % Pendiente del fondo
n = 0.017;    % Manning
m = 2;       % Talud lateral 1V:mH
g = 9.81;

%% ------------------------------------------------------------------------
% TIRANTE CRÍTICO Y NORMAL
%% ------------------------------------------------------------------------
yc0 = (Q^2/(g*b^2))^(1/3);
yc = fsolve(@(y) froude_trap(y,[Q b m]), yc0);

yn0 = (Q*n/(b*sqrt(S)))^(3/5);
yn = fsolve(@(y) manning_trap(y,[Q b S n m]), yn0);

%% ------------------------------------------------------------------------
% FGV1 (supercrítico)
%% ------------------------------------------------------------------------
x_ini1 = 0; x_end1 = 100; y_ini1 = 0.6717;
par1 = [Q b S n yc m];
opt1 = odeset('Events', @(x,y) critico(x,y,par1));
[x1, y1] = ode23(@(x,y) rect(x,y,par1), [x_ini1 x_end1], y_ini1, opt1);

%% ------------------------------------------------------------------------
% FGV2 (subcrítico)
%% ------------------------------------------------------------------------
x_ini2 = 100; x_end2 = 0; y_ini2 = 1.27;
par2 = [Q b S n yc m];
opt2 = odeset('Events', @(x,y) critico(x,y,par2));
[x2, y2] = ode23(@(x,y) rect(x,y,par2), [x_ini2 x_end2], y_ini2, opt2);
[x2, ind2] = sort(x2); y2 = y2(ind2);

%% ------------------------------------------------------------------------
% CONJUGADO DEL FLUJO 1
%% ------------------------------------------------------------------------
y_s1 = NaN(size(y1));
Fr1 = zeros(size(y1));

for i = 1:length(y1)
    [B, A, P, R, yG, D] = trap_geom(y1(i), b, m);
    U = Q/A;
    Fr1(i) = U / sqrt(g*D);
    if Fr1(i) > 1
        [~, yconj] = Mom_trap(y1(i), b, m, Q);
        y_s1(i) = yconj;
    end
end

x_s1 = x1;
mask = ~isnan(y_s1);
x_s1v = x_s1(mask);
y_s1v = y_s1(mask);

%% ------------------------------------------------------------------------
% INTERSECCIÓN ENTRE CONJUGADO(FGV1) Y FGV2
%% ------------------------------------------------------------------------
y2_int = interp1(x2, y2, x_s1v, 'linear');
diff_y = y_s1v - y2_int;
idx = find(diff_y(1:end-1).*diff_y(2:end) <= 0);

if isempty(idx)
    disp('No hay intersección entre el conjugado de FGV1 y FGV2');
    x_inter = NaN; y_inter = NaN;
else
    i = idx(1);
    xA = x_s1v(i); xB = x_s1v(i+1);
    fA = diff_y(i); fB = diff_y(i+1);
    x_inter = xA - fA*(xB - xA)/(fB - fA);
    y_inter = interp1(x_s1v, y_s1v, x_inter, 'linear');
    fprintf('\n>>> Intersección (resalto) en x = %.4f m, y = %.4f m\n', x_inter, y_inter);
end

%% ------------------------------------------------------------------------
% GRÁFICO ÚNICO
%% ------------------------------------------------------------------------
figure(1); clf; hold on; grid on;

plot(x1, y1, 'b-', 'LineWidth', 2);              % FGV1
plot(x_s1v, y_s1v, 'r--', 'LineWidth', 2);       % Conjugado FGV1
plot(x2, y2, 'g-', 'LineWidth', 2);              % FGV2
yline(yc, '--k', 'y_{crítico}', 'LineWidth', 1.5);
yline(yn, '--m', 'y_{normal}', 'LineWidth', 1.5);

if ~isnan(x_inter)
    plot(x_inter, y_inter, 'ko', 'MarkerSize', 10, 'MarkerFaceColor', 'y');
end

xlabel('x (m)');
ylabel('Tirante y (m)');
legend('FGV1 (supercrítico)', 'Conjugado FGV1', 'FGV2 (subcrítico)', ...
       'y_{crítico}', 'y_{normal}', 'Intersección', 'Location', 'Best');
title('Intersección entre FGV2 y el conjugado del flujo 1');

%% ------------------------------------------------------------------------
% RESULTADOS ADICIONALES
%% ------------------------------------------------------------------------

if ~isnan(x_inter)

    % 1) Punto en x donde se da la intersección
    fprintf('\n1) La intersección ocurre en x = %.4f m\n', x_inter);

    % 2) Tirante del flujo 1 en ese punto (FGV1)
    % Nos aseguramos que x_inter esté dentro del rango de x1
    if x_inter >= min(x1) && x_inter <= max(x1)
        y1_inter = interp1(x1, y1, x_inter, 'linear');
        fprintf('2) Tirante del flujo 1 en ese punto: y1 = %.4f m\n', y1_inter);
    else
        y1_inter = NaN;
        fprintf('2) x_inter está fuera del rango de FGV1, no se puede interpolar y1.\n');
    end

    % 3) Tirante del flujo 2 en ese punto (FGV2)
    if x_inter >= min(x2) && x_inter <= max(x2)
        y2_inter = interp1(x2, y2, x_inter, 'linear');
        fprintf('3) Tirante del flujo 2 en ese punto: y2 = %.4f m\n\n', y2_inter);
    else
        y2_inter = NaN;
        fprintf('3) x_inter está fuera del rango de FGV2, no se puede interpolar y2.\n');
    end

    % Solo exporto si realmente existen
    assignin('base', 'x_inter', x_inter);
    assignin('base', 'y1_inter', y1_inter);
    assignin('base', 'y2_inter', y2_inter);

else
    fprintf('\nNo se pudo calcular resultados adicionales porque no hubo intersección.\n');
end

endfunction