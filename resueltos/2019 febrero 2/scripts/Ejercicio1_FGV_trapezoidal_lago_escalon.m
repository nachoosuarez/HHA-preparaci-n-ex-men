% Ejercicio1_FGV_trapezoidal_lago_escalon.m -- Examen HHA 22/feb/2019
% ("2019 febrero 2"), Ejercicio 1.
%
% Lago (hLago=1.5 m sobre el fondo) que descarga en un canal TRAPEZOIDAL
% (b=3.5 m, talud m=2 [1V:2H], n=0.01, S0=0.015) de L=450 m que termina
% en caida libre.
%
% Parte 2: a los x=40 m del inicio, el fondo se ELEVA (escalon) Dz=0.5 m
% y luego continua con la misma pendiente original S0 (el canal, aguas
% abajo del escalon, es identico al de la Parte 1 pero con el fondo
% 0.5 m mas alto en cada x).
%
% Requiere, en esta misma carpeta (copia del toolkit canonico
% RESUMEN EXAMEN/Codigos/FGV_trapezoidal/): trap_geom.m, eq_yc.m, eq_yn.m,
% rect.m, critico.m, Mom_trap.m, Eesp_trap.m, alternos_trap.m,
% froude_trap.m, manning_trap.m, control_critico_lago_trap.m.
%
% METODO (ver RESUMEN_TEORICO.md S:A1, A2, A3, A4 "control critico en la
% entrada, seccion trapezoidal", A5 "escalon de fondo"):
% - Parte 1: se prueba la hipotesis "canal STEEP" (yn<yc): si es
%   consistente, el lago descarga el caudal MAXIMO compatible con su
%   energia -> control CRITICO en la entrada (x=0): E(yc)=hLago. En
%   seccion trapezoidal esto no tiene forma cerrada: se itera Q con
%   fzero (control_critico_lago_trap.m) hasta que
%   yc(Q)+Q^2/(2g*A(yc(Q))^2)=hLago. Se integra la curva S2
%   (supercritica, decreciendo desde yc hacia yn) desde x=0 hasta
%   x=L=450 m.
% - Parte 2: el escalon esta a x=40 m, MUY cerca de la entrada. Primero
%   se evalua, sobre la curva S2 "natural" (sin escalon) de la Parte 1,
%   la energia especifica que trae el flujo al llegar a x=40 m:
%   E_nat(40)=y_S2(40)+Q^2/(2g*A^2). El escalon maximo que NO altera esa
%   aproximacion es Dmax=E_nat(40)-Ec (Ec=energia critica=hLago, ya que
%   el control de entrada es critico). Como Dz=0.5 m > Dmax, el escalon
%   AHOGA la seccion: aparece una curva subcritica (aqui "S1", y>yc,
%   pese a que el canal es tipo S) aguas arriba del escalon, con nueva
%   energia (medida respecto al fondo ORIGINAL, antes del escalon)
%   E2=Ec+Dz. De esa energia sale y2 (alterno subcritico, alternos_trap)
%   inmediatamente aguas arriba del escalon; sobre la cresta (fondo ya
%   elevado) y3=yc (control critico local). Aguas abajo de la cresta el
%   canal es identico al de la Parte 1 (mismo S0, b, m, n) pero con el
%   fondo desplazado +0.5 m: se integra una NUEVA curva S2 local desde
%   y=yc en la cresta hasta el final del canal.
% - Como el lago sigue imponiendo yc en x=0 (igual que Parte 1, la
%   perturbacion del escalon no viaja hacia aguas arriba en flujo
%   supercritico salvo que el remanso alcance la entrada -- se verifica
%   que no ocurre porque el resalto queda muy adentro del tramo [0,40]),
%   la curva S2 "natural" de la Parte 1 sigue siendo valida desde x=0
%   hasta que se cruza con la curva subcritica que retrocede desde el
%   escalon: RESALTO donde el CONJUGADO (Mom_trap) de la S2 iguala a esa
%   curva subcritica (misma tecnica de A3).

clc; clear; close all;
warning('off','all');

%% ==== EDITAR ACA (datos del enunciado) ====
b      = 3.5;    % ancho de fondo (m)
m      = 2;      % talud lateral 1V:mH
n      = 0.01;   % Manning
g      = 9.8;
hLago  = 1.5;    % nivel del lago sobre el fondo del canal, en x=0 (m)
S0     = 0.015;  % pendiente de fondo
L      = 450;    % longitud total del canal (m)
x_esc  = 40;     % posicion del escalon (m)
Dz     = 0.5;    % altura del escalon (m)
opt    = optimset('Display','off');
%% ============================================

fprintf('=================== PARTE 1: canal sin escalon ===================\n');

% --- Control critico en la entrada (lago -> canal), iterando Q ---
[Q,yc] = control_critico_lago_trap(hLago,b,m,[1 40]);
[Bc,Ac] = trap_geom(yc,b,m);
Ec = yc + Q^2/(2*g*Ac^2);
fprintf('Control critico en la entrada: E(yc) = yc + Q^2/(2g*A(yc)^2) = hLago (fzero en Q)\n');
fprintf('  Q = %.3f m3/s ; yc = %.4f m ; Ec = %.4f m (hLago=%.2f m)\n', Q, yc, Ec, hLago);

% --- Tirante normal, para clasificar el canal ---
yn = fsolve(@(y) eq_yn(y,Q,n,m,b,S0), 0.5, opt);
fprintf('Tirante normal (Manning, S0=%.4f): yn = %.4f m\n', S0, yn);
if yn < yc
    fprintf('  yn < yc => CANAL TIPO S (steep) -> control critico en la entrada es CONSISTENTE\n');
else
    error('yn > yc: la hipotesis de canal steep no es consistente; revisar planteo.');
end

% --- Curva S2 "natural": integrar desde x=0 (y=yc) hasta x=L=450 m ---
% OJO: la ODE es singular en yc (1-Fr^2=0); con tolerancias por defecto
% de ode23 el primer tramo (muy cerca de yc) se resuelve con paso
% demasiado grueso y da un perfil visiblemente distinto (y(40) salia
% ~0.69 m en vez de ~0.724 m). Con RelTol/AbsTol mas finos el resultado
% converge y coincide con la solucion oficial (y(40)=0.724 m).
par1 = [Q b S0 n yc m];
xg = linspace(0, L, 9001);
options_ev = odeset('Events', @(x,y) critico(x,y,par1), 'RelTol',1e-10, 'AbsTol',1e-12);
[x1, yS2] = ode23(@(x,y) rect(x,y,par1), xg, yc*(1-1e-4), options_ev);
y_L = yS2(end);
fprintf('Curva S2 (x=0 -> x=%d m): y(0)=%.4f m -> y(%d)=%.4f m (asintotico a yn=%.4f m)\n', ...
        L, yS2(1), round(x1(end)), y_L, yn);

fprintf('\nRESUMEN PARTE 1: Q=%.3f m3/s | yc=%.4f m | yn=%.4f m | canal tipo S (steep)\n', Q, yc, yn);
fprintf('  Perfil: y=yc=%.3f en x=0, curva S2 decreciendo hasta y=%.3f m en x=%d m (caida libre)\n', yc, y_L, L);


fprintf('\n=================== PARTE 2: escalon Dz=%.2f m en x=%d m ===================\n', Dz, x_esc);

% Valor de la curva S2 "natural" (sin escalon) justo antes de x=x_esc
y_nat_esc = interp1(x1, yS2, x_esc);
[~,A_nat] = trap_geom(y_nat_esc,b,m);
E_nat_esc = y_nat_esc + Q^2/(2*g*A_nat^2);
Dmax = E_nat_esc - Ec;
fprintf('Curva S2 natural en x=%d m (sin escalon): y=%.4f m -> E=%.4f m\n', x_esc, y_nat_esc, E_nat_esc);
fprintf('Dmax = E_nat(%d) - Ec = %.4f - %.4f = %.4f m\n', x_esc, E_nat_esc, Ec, Dmax);

if Dz > Dmax
    fprintf('Dz=%.2f m > Dmax=%.4f m => el ESCALON AHOGA la seccion (aparece remanso aguas arriba)\n', Dz, Dmax);
else
    fprintf('Dz=%.2f m <= Dmax=%.4f m => el escalon NO afecta el tirante aguas arriba\n', Dz, Dmax);
end

% Nueva energia (referida al fondo ORIGINAL, antes del escalon) que debe
% traer el flujo justo aguas arriba de la base del escalon para pasar
% justo critico en la cresta:
E2 = Ec + Dz;
[y2,y2_alt] = alternos_trap(b,m,Q,E2);
% alternos_trap devuelve (yalt1,yalt2): nos quedamos con el SUBCRITICO (mayor)
y2 = max(y2,y2_alt);
fprintf('Nueva energia requerida (fondo original) E2 = Ec + Dz = %.4f + %.2f = %.4f m\n', Ec, Dz, E2);
fprintf('  y2 (subcritico, base del escalon, aguas arriba) = %.4f m\n', y2);

% Tirante en la cresta (fondo elevado): critico, y3=yc (mismo yc, mismo Q)
y3 = yc;
fprintf('  y3 (cresta del escalon, fondo elevado) = yc = %.4f m (verificacion: E3=Ec=%.4f=E2-Dz=%.4f)\n', ...
        y3, Ec, E2-Dz);

% --- Curva subcritica (aqui "S1", y>yc) integrada HACIA ATRAS desde
%     x=x_esc (y=y2) hasta x=0, con el mismo par1 (fondo original) ---
xg_back = linspace(x_esc, 0, 4001);
options_ev1 = odeset('Events', @(x,y) critico(x,y,par1), 'RelTol',1e-10, 'AbsTol',1e-12);
[xS1, yS1] = ode23(@(x,y) rect(x,y,par1), xg_back, y2, options_ev1);
fprintf('Curva subcritica (S1) integrada hacia atras desde x=%d (y2=%.4f m) hasta x=%.1f m (y=%.4f m)\n', ...
        x_esc, y2, xS1(end), yS1(end));

% --- Ubicacion del resalto: cruce entre el CONJUGADO de la curva S2
%     (natural, supercritica, viene del lago) y la curva S1 (subcritica,
%     viene retrocediendo desde el escalon), sobre una malla comun de x ---
x_comun = linspace(0, min(x_esc, xS1(1)), 800);
yS2_i = interp1(x1, yS2, x_comun);
yS1_i = interp1(xS1, yS1, x_comun, 'linear', 'extrap');

conjS2 = zeros(size(x_comun));
for k = 1:numel(x_comun)
    [~, yconj_k] = Mom_trap(yS2_i(k), b, m, Q);
    conjS2(k) = yconj_k;
end

dif = yS1_i - conjS2;
idx = find(dif(1:end-1).*dif(2:end) < 0, 1, 'first');
if isempty(idx)
    fprintf('*** No se encontro cruce del conjugado dentro de [0,%d] m: revisar rango ***\n', x_esc);
    x_resalto = NaN; y1_resalto = NaN; y2_resalto = NaN;
else
    x_resalto  = interp1(dif(idx:idx+1), x_comun(idx:idx+1), 0);
    y1_resalto = interp1(x_comun(idx:idx+1), yS2_i(idx:idx+1), x_resalto);
    y2_resalto = interp1(x_comun(idx:idx+1), yS1_i(idx:idx+1), x_resalto);
    fprintf('RESALTO en x = %.2f m: y = %.4f m (supercritico, S2) -> y = %.4f m (subcritico, S1)\n', ...
            x_resalto, y1_resalto, y2_resalto);
    [Mchk1,~] = Mom_trap(y1_resalto,b,m,Q);
    [Mchk2,~] = Mom_trap(y2_resalto,b,m,Q);
    fprintf('  chequeo momentum: M(%.4f)=%.5f  M(%.4f)=%.5f (deben coincidir)\n', y1_resalto, Mchk1, y2_resalto, Mchk2);
end

% --- Aguas abajo de la cresta (x>x_esc): nueva curva S2 local, fondo
%     elevado, misma Q/yc/yn (misma geometria y pendiente) ---
par2 = par1; % mismo Q,b,S0,n,yc,m: solo cambia el datum vertical (irrelevante para la ODE)
xg2 = linspace(x_esc, L, 9001);
options_ev2 = odeset('Events', @(x,y) critico(x,y,par2), 'RelTol',1e-10, 'AbsTol',1e-12);
[x2, yS2b] = ode23(@(x,y) rect(x,y,par2), xg2, yc*(1-1e-4), options_ev2);
y_L2 = yS2b(end);
fprintf('Curva S2 local aguas abajo de la cresta (x=%d -> x=%d m): y(%d)=yc=%.4f -> y(%d)=%.4f m\n', ...
        x_esc, L, x_esc, yc, round(x2(end)), y_L2);

fprintf('\nRESUMEN PARTE 2 (Q=%.3f m3/s, igual que Parte 1 -- el resalto no llega a afectar la entrada):\n', Q);
fprintf('  Perfil: y=yc=%.3f en x=0 -> curva S2 hasta y=%.3f en x=%.2f\n', yc, y1_resalto, x_resalto);
fprintf('  -> RESALTO (%.3f -> %.3f m) -> curva S1 (subcritica) hasta y2=%.3f en x=%d (base escalon)\n', ...
        y1_resalto, y2_resalto, y2, x_esc);
fprintf('  -> escalon: y3=yc=%.3f en la cresta (fondo +%.2f m) -> curva S2 local hasta y=%.3f en x=%d (caida libre)\n', ...
        yc, Dz, y_L2, L);
