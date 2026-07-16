%% EJERCICIO 1 - Parte 3
% 500 m aguas arriba de la compuerta (x = 2700 m) el tirante no debe superar
% 1.8 m. Se pide la minima abertura de compuerta 'a' que cumple la condicion.
clear all
load('part1.mat');   % Q, yn, yc, b, m, n, S0, hLA, L, g

xg   = 3200;         % ubicacion de la compuerta
xchk = xg - 500;      % 500 m aguas arriba de la compuerta = 2700 m
ylim = 1.8;           % tirante maximo admisible en xchk (m)

par = [Q b S0 n yc m];

function y_at = perfil_M1_en(a, b, m, Q, g, S0, n, yc, xg, xchk)
  par = [Q b S0 n yc m];
  yB = a;
  [E_gate, ~] = Eesp_trap(yB, b, Q, m);
  [yalt1, yalt2] = alternos_trap(b, m, Q, E_gate);
  yA = max(yalt1, yalt2);
  [xu, yu] = ode23(@(x,y) rect(x,y,par), [xg, xchk], yA);
  y_at = yu(end);
end

%% Situacion actual (Parte 2, a=0.8 m)
a0 = 0.8;
y_actual = perfil_M1_en(a0, b, m, Q, g, S0, n, yc, xg, xchk);
fprintf('Con a = %.2f m (Parte 2): tirante a 500 m aguas arriba de la compuerta (x=%.0f) = %.4f m\n', ...
        a0, xchk, y_actual);
if y_actual <= ylim
  fprintf('  -> Cumple la condicion (%.4f <= %.2f m).\n', y_actual, ylim);
else
  fprintf('  -> NO cumple la condicion (%.4f > %.2f m).\n', y_actual, ylim);
end

%% Busqueda de la minima abertura 'a' tal que y(xchk) = 1.8 m (caso limite)
% A mayor apertura 'a' (siempre a<yc), menor es el remanso aguas arriba
% (yA -> yc cuando a -> yc). Se busca el 'a' donde y(xchk) = ylim exactamente.
f = @(a) perfil_M1_en(a, b, m, Q, g, S0, n, yc, xg, xchk) - ylim;

a_lo = 0.05; a_hi = yc - 1e-4;
f_lo = f(a_lo); f_hi = f(a_hi);
fprintf('\nBusqueda de raiz: f(a=%.3f)=%.4f ; f(a=%.4f)=%.4f\n', a_lo, f_lo, a_hi, f_hi);

a_root = fzero(f, [a_lo, a_hi]);
[E_gate_r, ~] = Eesp_trap(a_root, b, Q, m);
[yalt1_r, yalt2_r] = alternos_trap(b, m, Q, E_gate_r);
yA_r = max(yalt1_r, yalt2_r);

fprintf('\nMinima abertura de compuerta: a = %.4f m  (redondeando, a ~ %.2f m)\n', a_root, a_root);
fprintf('Tirante en la compuerta para ese caso limite (y = a'' alterno de a) = %.4f m\n', yA_r);
y_check = perfil_M1_en(a_root, b, m, Q, g, S0, n, yc, xg, xchk);
fprintf('Verificacion: tirante a 500 m aguas arriba de la compuerta = %.4f m (debe ser %.2f m)\n', y_check, ylim);
