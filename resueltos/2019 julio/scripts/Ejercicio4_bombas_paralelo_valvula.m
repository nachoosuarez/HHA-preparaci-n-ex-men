% Ejercicio4_bombas_paralelo_valvula.m — Examen HHA 22/jul/2019, Ejercicio 4.
%
% Dos bombas IDENTICAS en paralelo elevan agua desde un rio (superficie
% libre, cota zR) hasta un tanque elevado (superficie libre, cota zT),
% compartiendo una unica tuberia de succion (Ls,Ds) y una unica tuberia
% de impulsion (Li,Di) con una valvula reguladora (kv) antes del tanque.
%
% OJO (ver RESUMEN_TEORICO.md §C1, nota "diametros de succion e
% impulsion distintos"): como Ds != Di y AMBOS extremos son superficies
% libres de grandes depositos (rio y tanque), la ecuacion de la
% instalacion NO lleva ningun termino cinetico "suelto": los k y f de
% cada tramo (ks, ki) ya incluyen TODAS las perdidas localizadas
% (entrada, salida, accesorios) segun el propio enunciado. La formula es
% la que trae la solucion oficial:
%
%   Hm(Q) = (zT-zR) + (ks + fs*Ls/Ds)*Us^2/(2g) + (ki+kv + fi*Li/Di)*Ui^2/(2g)
%
% (NO usar la plantilla de Bomba_sola.m/Bombas_paralelo.m tal cual: esos
% scripts suman +v^2/2g en HA y HB, que solo es correcto si Ds=Di o si
% alguno de los extremos es una descarga libre real — ver la nota citada).
% Para el NPSH disponible tampoco se suma el termino cinetico de la
% succion (C4, "trampa del termino cinetico que se cancela").
%
% Parte 1) zR=0, valvula abierta (kv=0): punto de funcionamiento del
%          sistema y de cada bomba, potencia consumida, chequeo de
%          cavitacion.
% Parte 2) Nivel minimo de zR (rio bajando) sin que las bombas caviten.
% Parte 3) Con zR=0, se cierra parcialmente la valvula para reducir el
%          caudal del sistema a 150 L/s: hallar kv, nuevo punto de
%          funcionamiento, potencia y cavitacion.
%
% Requiere (mismo directorio): colebrook.m.

clc; clear; close all;
warning('off','all');

%% ==== EDITAR ACA (datos del enunciado) ====
g    = 9.8;
ro   = 1000;         % kg/m3 (agua a 20 C)
gamma = ro*g;         % N/m3 (=9800, igual que la solucion oficial)
nu   = 1.004e-6;      % m2/s, viscosidad cinematica del agua a 20 C
epsilon = 0.00004;    % m (=0.04 mm), rugosidad absoluta (succion e impulsion)

Ls = 10;  Ds = 0.3;  ks = 1;     % succion: largo, diametro, perdida localizada
Li = 100; Di = 0.25; ki = 2;     % impulsion: largo, diametro, perdida localizada
zB = 1;               % cota del eje de las bombas (m)
zT = 20;               % cota de la superficie libre del tanque elevado (m)

% Curva de catalogo (2 bombas identicas)
Qcat    = [0 25 50 75 100 125 150]/1000;   % m3/s
Hcat    = [38 37 35 31 26 19 12];           % m.c.a.
etacat  = [0 45 70 76 71 56 30];            % %
NPSHrcat= [3.1 3.5 4.3 5.20 7.1 9.2 13];    % m
%% ============================================

As = pi*Ds^2/4;
Ai = pi*Di^2/4;

function [Qpf,Hpf] = punto_funcionamiento(zR,kv,Qcat,Hcat,ks,ki,Ls,Ds,Li,Di,epsilon,nu,zT,g)
  As = pi*Ds^2/4; Ai = pi*Di^2/4;
  Qg = linspace(0.0005, 0.30, 8000);
  Heq = interp1(Qcat, Hcat, Qg/2, 'pchip');   % 2 bombas iguales en paralelo: H(Q_total/2)
  Hm = zeros(size(Qg));
  for i = 1:length(Qg)
    Q = Qg(i);
    vs = Q/As; fs = colebrook(vs*Ds/nu, epsilon/Ds);
    vi = Q/Ai; fi = colebrook(vi*Di/nu, epsilon/Di);
    Hm(i) = (zT-zR) + (ks+fs*Ls/Ds)*vs^2/(2*g) + (ki+kv+fi*Li/Di)*vi^2/(2*g);
  end
  [~,idx] = min(abs(Heq-Hm));
  Qpf = Qg(idx); Hpf = Heq(idx);
end

function NPSHdisp = calc_NPSHdisp(zR,Qtotal,zB,ks,Ls,Ds,epsilon,nu,g)
  As = pi*Ds^2/4;
  vs = Qtotal/As; fs = colebrook(vs*Ds/nu, epsilon/Ds);
  HA = zR - (ks+fs*Ls/Ds)*vs^2/(2*g);    % SIN termino cinetico (se cancela, ver C4)
  NPSHdisp = HA - zB + 10.1;             % 10.1 = patm/gamma - pvap/gamma (agua 20C)
end

function s = merit(b)
  if b, s = 'NO CAVITA'; else, s = 'CAVITA'; end
end

function res = residuo_zR(zR,Qcat,Hcat,NPSHrcat,ks,ki,Ls,Ds,Li,Di,epsilon,nu,zT,g,zB)
  [Qpf,~] = punto_funcionamiento(zR,0,Qcat,Hcat,ks,ki,Ls,Ds,Li,Di,epsilon,nu,zT,g);
  Qb = Qpf/2;
  NPSHdisp = calc_NPSHdisp(zR,Qpf,zB,ks,Ls,Ds,epsilon,nu,g);
  NPSHr = interp1(Qcat,NPSHrcat,Qb,'pchip');
  res = NPSHdisp - NPSHr;
end

%% ================= PARTE 1: zR=0, valvula abierta =================
fprintf('=================== PARTE 1: zR=0 m, valvula abierta (kv=0) ===================\n');
[Qpf,Hpf] = punto_funcionamiento(0,0,Qcat,Hcat,ks,ki,Ls,Ds,Li,Di,epsilon,nu,zT,g);
Qb = Qpf/2;
fprintf('a) Qsistema = %.1f L/s ; Hsistema = %.2f m ; Qbomba = %.1f L/s ; Hbomba = %.2f m\n', ...
        Qpf*1000, Hpf, Qb*1000, Hpf);

eta_b = interp1(Qcat,etacat,Qb,'pchip');
Pc = gamma*Qpf*Hpf/(eta_b/100);
fprintf('b) eta(Qbomba) = %.1f %% ; Pc = gamma*Qsist*Hsist/eta = %.0f*%.4f*%.2f/%.3f = %.2f kW\n', ...
        eta_b, gamma, Qpf, Hpf, eta_b/100, Pc/1000);

NPSHdisp1 = calc_NPSHdisp(0,Qpf,zB,ks,Ls,Ds,epsilon,nu,g);
NPSHr1 = interp1(Qcat,NPSHrcat,Qb,'pchip');
fprintf('c) NPSHdisp = %.2f m ; NPSHreq(Qbomba) = %.2f m => %s\n', ...
        NPSHdisp1, NPSHr1, merit(NPSHdisp1>NPSHr1));

%% ================= PARTE 2: zR minimo sin cavitacion =================
fprintf('\n=================== PARTE 2: zR minimo sin cavitacion ===================\n');
zR_min = fzero(@(zR) residuo_zR(zR,Qcat,Hcat,NPSHrcat,ks,ki,Ls,Ds,Li,Di,epsilon,nu,zT,g,zB), [-5 0]);
[Qpf2,Hpf2] = punto_funcionamiento(zR_min,0,Qcat,Hcat,ks,ki,Ls,Ds,Li,Di,epsilon,nu,zT,g);
fprintf('zR_min = %.2f m ; Qbomba = %.1f L/s ; Hbomba = %.2f m (NPSHdisp=NPSHreq justo en ese punto)\n', ...
        zR_min, Qpf2/2*1000, Hpf2);

%% ================= PARTE 3: cerrar valvula para Qsistema=150 L/s =================
fprintf('\n=================== PARTE 3: zR=0, cerrar valvula para Qsistema=150 L/s ===================\n');
Qtarget = 0.150;
Hb_target = interp1(Qcat,Hcat,Qtarget/2,'pchip');
vs = Qtarget/As; fs = colebrook(vs*Ds/nu, epsilon/Ds);
vi = Qtarget/Ai; fi = colebrook(vi*Di/nu, epsilon/Di);
% Hb_target = (zT-0) + (ks+fs*Ls/Ds)*vs^2/2g + (ki+kv+fi*Li/Di)*vi^2/2g  -> despejar kv (caso "inverso" C6)
rhs_fijo = (zT-0) + (ks+fs*Ls/Ds)*vs^2/(2*g) + (ki+fi*Li/Di)*vi^2/(2*g);
kv = (Hb_target - rhs_fijo)/(vi^2/(2*g));
fprintf('a) Q_bomba=75 L/s -> Hbomba (curva) = %.2f m ; despejando kv de Hm(Q=150L/s)=Hbomba: kv = %.2f\n', ...
        Hb_target, kv);

fprintf('b) Nuevo punto de funcionamiento: Qsistema = 150.0 L/s ; Hsistema = %.2f m ; Qbomba = 75.0 L/s ; Hbomba = %.2f m\n', ...
        Hb_target, Hb_target);

eta_b3 = interp1(Qcat,etacat,Qtarget/2,'pchip');
Pc3 = gamma*Qtarget*Hb_target/(eta_b3/100);
fprintf('c) eta(75 L/s) = %.1f %% ; Pc = %.2f kW\n', eta_b3, Pc3/1000);

NPSHdisp3 = calc_NPSHdisp(0,Qtarget,zB,ks,Ls,Ds,epsilon,nu,g);
NPSHr3 = interp1(Qcat,NPSHrcat,Qtarget/2,'pchip');
fprintf('d) NPSHdisp = %.2f m ; NPSHreq(75 L/s) = %.2f m => %s\n', ...
        NPSHdisp3, NPSHr3, merit(NPSHdisp3>NPSHr3));
