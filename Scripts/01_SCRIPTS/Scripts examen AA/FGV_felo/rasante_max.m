clc; clear; close all;

%========================
% INPUTS (DATOS)
%========================
Q  = 17.39;     % Caudal [m3/s]
n  = 0.013;     % Manning
b  = 2.2;       % Ancho de fondo [m]
m  = 1.0;       % Talud lateral (H/V)
Tmax = 42;      % Tension rasante maxima admisible [N/m2 = Pa]

gama = 9800;    % Peso especifico del agua [N/m3]

%========================
% FUNCION TENSION RASANTE
%========================
tau_fun = @(y) gama .* (Q.^2 .* n.^2) ./ ...
    ((b .* y + m .* y.^2).^2 .* ...
    ((b .* y + m .* y.^2) ./ (b + 2 .* y .* sqrt(1 + m.^2))).^(1/3));

%========================
% CALCULO DE y_max
%========================
f = @(y) Tmax - tau_fun(y);

y0 = 0.5;              % Valor inicial
y_max = fsolve(f, y0);

%========================
% RESULTADOS
%========================
fprintf('\nRESULTADOS DE TENSION RASANTE\n');
fprintf('------------------------------\n');
fprintf('Tension rasante maxima admisible: %.2f Pa\n', Tmax);
fprintf('Tirante critico y_max = %.3f m\n\n', y_max);

fprintf('INTERPRETACION HIDRAULICA:\n');
fprintf('- Para y < %.3f m  --> ZONA DE PELIGRO (tau > tau_max)\n', y_max);
fprintf('- Para y >= %.3f m --> ZONA SEGURA (tau <= tau_max)\n', y_max);
