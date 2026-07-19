% FGV_trapezoidal_optimizado.m — script CONSOLIDADO para resolver de
% punta a punta un ejercicio de Flujo Gradualmente Variado en canal
% TRAPEZOIDAL: tirante crítico yc y normal yn, clasificación M/S, y
% (opcional) una compuerta de fondo ideal con chequeo libre/ahogada,
% tirante aguas arriba, ubicación del resalto hidráulico si es libre,
% fuerza sobre la compuerta, potencia disipada en el resalto, y la
% apertura máxima para descarga libre. Antes había que combinar
% trap_geom.m + froude_trap.m + manning_trap.m + Mom_trap.m + Eesp_trap.m
% + rect.m(ODE)+critico.m a mano; acá está todo en un único punto de
% entrada.
%
% CÓMO USARLO: editar SOLO el bloque "EDITAR ACÁ" de abajo con los datos
% del enunciado y correr el script entero.
%   - Si el ejercicio no tiene compuerta, dejar USAR_COMPUERTA=false
%     (alcanza para clasificar el canal).
%   - El tirante de referencia aguas abajo de la compuerta (necesario
%     para el chequeo libre/ahogada y para ubicar el resalto) se puede
%     dar de 3 formas, elegidas con CONTROL_AGUASABAJO:
%       'yn'     -> el canal aguas abajo es muy largo, tiende a yn.
%       'lago'   -> descarga a un lago de nivel conocido a distancia
%                   L_AGUASABAJO de la compuerta (dato hLago).
%       'caida'  -> termina en una caída libre (control crítico, y=yc)
%                   a distancia L_AGUASABAJO de la compuerta.
%     En los casos 'lago'/'caida' se integra la curva M2 hacia atrás
%     (ode23) desde el control conocido hasta la compuerta.
%
% REQUIERE, en esta misma carpeta: trap_geom.m, froude_trap.m,
% manning_trap.m, Mom_trap.m, Eesp_trap.m, critico.m (copias de
% RESUMEN EXAMEN/Codigos/FGV_trapezoidal/, sin modificar), rect_trap.m
% (copia RENOMBRADA del "rect.m" de FGV_trapezoidal/ — con ese nombre
% original chocaría con el rect.m, distinto, que ya usa
% FGV_rectangular_optimizado.m en esta misma carpeta), y conjugado_de_a.m
% (wrapper de Mom_trap que devuelve solo yconj, necesario porque Octave
% 8.4 no reconoce funciones locales definidas al final de un script
% cuando se llaman desde dentro de un anonymous function pasado a
% fsolve).
%
% Verificado contra resueltos/2020 Diciembre/RESOLUCION.md Ejercicio 1
% (misma salida: yc=1.4085, yn=2.1188, canal M, compuerta a=0.85 a
% 500 m de una caída libre -> descarga LIBRE, y1=2.836 m, resalto a
% x=30.1 m [0.966->1.949 m], F=113.6 kN, Pdis=57.05 kW, a_max=0.9595 m).

clc; clear; close all;
warning('off','all');

%% ==== EDITAR ACÁ ====
Q  = 22;       % caudal (m3/s)
b  = 2.4;      % ancho de fondo (m)
m  = 2;        % talud lateral 1V:mH
S0 = 0.0005;   % pendiente de fondo del canal
n  = 0.016;    % coeficiente de Manning

% Compuerta de fondo ideal (dejar USAR_COMPUERTA=false si no aplica)
USAR_COMPUERTA = true;
a_compuerta = 0.85;   % apertura de la compuerta (m)

% Control aguas abajo de la compuerta: 'yn' | 'lago' | 'caida'
CONTROL_AGUASABAJO = 'caida';
L_AGUASABAJO = 500;   % distancia (m) de la compuerta al control (lago/caida); ignorado si CONTROL_AGUASABAJO='yn'
h_lago = [];          % nivel del lago (m), sólo si CONTROL_AGUASABAJO='lago'

CALCULAR_A_MAX = true; % apertura maxima de la compuerta para descarga libre
%% =====================

g = 9.81;

% ---- Tirante critico y normal, clasificacion ----
yc = fsolve(@(y) froude_trap(y,[Q b m]), (Q^2/(g*b^2))^(1/3));
if S0 > 0
  yn = fsolve(@(y) manning_trap(y,[Q b S0 n m]), (Q*n/(b*sqrt(S0)))^(3/5));
else
  yn = Inf;
end
fprintf('yc = %.4f m ; yn = %.4f m\n', yc, yn);
if S0<=0
  fprintf('S0<=0 => yn=Inf (canal horizontal o de contrapendiente)\n');
elseif yn > yc
  fprintf('yn > yc => CANAL TIPO M (pendiente suave)\n');
else
  fprintf('yn < yc => CANAL TIPO S (pendiente fuerte)\n');
end

if ~USAR_COMPUERTA
  return
end

% ---- Tirante de referencia aguas abajo de la compuerta (sin resalto) ----
par_fgv = [Q b S0 n yc m];
switch CONTROL_AGUASABAJO
  case 'yn'
    y_tw_gate = yn;
    xL = NaN;
  case {'lago','caida'}
    xL = L_AGUASABAJO;
    if strcmp(CONTROL_AGUASABAJO,'lago')
      y_ini2 = h_lago;
    else
      y_ini2 = yc + 1e-4;
    end
    opt2 = odeset('Events', @(x,y) critico(x,y,par_fgv));
    [x2, y2] = ode23(@(x,y) rect_trap(x,y,par_fgv), [xL 0], y_ini2, opt2);
    [x2, idx2] = sort(x2); y2 = y2(idx2);
    y_tw_gate = interp1(x2, y2, 0, 'linear');
  otherwise
    error('CONTROL_AGUASABAJO debe ser ''yn'', ''lago'' o ''caida''');
end
fprintf('\nTirante de referencia aguas abajo (en la compuerta, sin resalto) = %.4f m\n', y_tw_gate);

% ---- Compuerta: tirante aguas arriba (energia) y chequeo libre/ahogada ----
[Ea, y1] = Eesp_trap(a_compuerta, b, Q, m);
fprintf('\n--- Compuerta de fondo ideal, a = %.3f m ---\n', a_compuerta);
fprintf('y1 (aguas arriba de la compuerta, alterno de a) = %.4f m\n', y1);

[~, a_conj] = Mom_trap(a_compuerta, b, m, Q);
fprintf('Conjugado de a (Mom_trap) = %.4f m\n', a_conj);

if a_conj > y_tw_gate
  fprintf('=> a_conj > y_ref: DESCARGA LIBRE (resalto aguas abajo de la compuerta)\n');

  if ~strcmp(CONTROL_AGUASABAJO,'yn')
    % Rama supercritica (M3) desde la compuerta hacia el control aguas abajo
    opt1 = odeset('Events', @(x,y) critico(x,y,par_fgv));
    [x1, y1s] = ode23(@(x,y) rect_trap(x,y,par_fgv), [0 xL], a_compuerta, opt1);
    y_s1 = NaN(size(y1s));
    for i = 1:length(y1s)
      [~,A,~,~,~,D] = trap_geom(y1s(i), b, m);
      Fr = (Q/A)/sqrt(g*D);
      if Fr > 1
        [~, yci] = Mom_trap(y1s(i), b, m, Q);
        y_s1(i) = yci;
      end
    end
    mask = ~isnan(y_s1);
    x_s1v = x1(mask); y_s1v = y_s1(mask);
    y2_int = interp1(x2, y2, x_s1v, 'linear');
    diffy = y_s1v - y2_int;
    idxc = find(diffy(1:end-1).*diffy(2:end) <= 0, 1);
    if isempty(idxc)
      fprintf('(no se encontro interseccion del conjugado de M3 con la rama de aguas abajo\n');
      fprintf(' en el rango [0, %.0f] m -- revisar L_AGUASABAJO o el caso ahogado)\n', xL);
      y_antes = NaN; y_despues = NaN;
    else
      xA = x_s1v(idxc); xB = x_s1v(idxc+1);
      fA = diffy(idxc); fB = diffy(idxc+1);
      x_resalto = xA - fA*(xB-xA)/(fB-fA);
      y_antes = interp1(x1, y1s, x_resalto, 'linear');
      y_despues = interp1(x2, y2, x_resalto, 'linear');
      fprintf('RESALTO a x = %.2f m aguas abajo de la compuerta: y=%.4f -> y=%.4f m\n', ...
              x_resalto, y_antes, y_despues);

      [E_antes,~] = Eesp_trap(y_antes, b, Q, m);
      [E_despues,~] = Eesp_trap(y_despues, b, Q, m);
      P_dis = 1000*g*Q*(E_antes - E_despues);
      fprintf('Potencia disipada en el resalto = rho*g*Q*(E1-E2) = %.2f kW\n', P_dis/1000);
    end
  else
    fprintf('(con CONTROL_AGUASABAJO=''yn'' no se ubica la posicion exacta del resalto,\n');
    fprintf(' solo se confirma que la descarga es libre)\n');
  end
else
  fprintf('=> a_conj < y_ref: DESCARGA AHOGADA (resalto sumergido contra la compuerta)\n');
end

% ---- Fuerza sobre la compuerta (entre y1 y la vena contraida) ----
[M1,~] = Mom_trap(y1, b, m, Q);
[Ma,~] = Mom_trap(a_compuerta, b, m, Q);
F_compuerta = 1000*g*(M1 - Ma);
fprintf('\nFuerza sobre la compuerta F = rho*g*(M1-Ma) = %.2f kN\n', F_compuerta/1000);

% ---- Apertura maxima para descarga libre ----
if CALCULAR_A_MAX
  a_max = fsolve(@(aa) conjugado_de_a(aa,b,m,Q) - y_tw_gate, a_compuerta);
  fprintf('\nApertura maxima para descarga libre: a_max = %.4f m\n', a_max);
end
