% Bombas_optimizado.m — Sistema de bombeo consolidado: N bombas
% IDENTICAS en 'una' / 'serie' / 'paralelo', succion + impulsion en
% serie (Colebrook-White para f). Editar solo el bloque de abajo.
%
% Que resuelve:
%  - Curva de instalacion Hinst(Q) (perdida distribuida Darcy-Weisbach
%    con Colebrook-White + perdidas localizadas ks/ki) vs. curva
%    equivalente de N bombas identicas segun MODO:
%      'una'      -> curva de catalogo tal cual
%      'serie'    -> H_eq(Q) = N * H_cat(Q)      (mismo Q, se suman cargas)
%      'paralelo' -> H_eq(N*Q1) = H_cat(Q1)      (misma H, se suman caudales)
%  - Punto de funcionamiento (interseccion), H y Q de cada bomba
%    individual, rendimiento, potencia por bomba y del sistema.
%  - NPSHdisp de cada bomba y chequeo de cavitacion:
%      'serie': la succion es comun a todas -> mismo Q; la mas
%               comprometida es la PRIMERA (antes de ganar carga de las
%               siguientes); cada bomba subsiguiente suma el H ya
%               entregado por las anteriores a su NPSHdisp.
%      'paralelo': la succion comun transporta el CAUDAL TOTAL (todas
%               las bombas ven el mismo NPSHdisp, calculado con Qtotal).
%      'una': NPSHdisp con el propio Q de la bomba.
%
% Que pide: geometria succion/impulsion (L,D,epsilon,k,z,p de cada
% tramo), N y MODO, curva de catalogo Q-H-eta-NPSHr de UNA bomba
% (todas identicas), cota de las bombas zB.
%
% Requiere en la misma carpeta: colebrook.m (copia de RESUMEN EXAMEN/
% Codigos/Bombas/ o FactorFriccion/, sin modificar).
%
% Verificado contra: resueltos/2019 febrero/RESOLUCION.md Ejercicio 4
% (MODO='serie', N=2: Q=9.17 L/s, H=55.5m, 27.76m por bomba, eta=68.4%,
% P_sistema=7.30 kW, NPSHdisp bomba1=9.00m>NPSHr=7.46m, no cavita).
clear all
g = 9.81; ro = 1000; nu = 0.000001;

%% ==== EDITAR ACA ====
MODO = 'serie';  % 'una' | 'serie' | 'paralelo'
N    = 2;        % cantidad de bombas identicas

% --- Succion ---
Ls = 2;      Ds = 0.100;  epsilon_s = 0.00005;  ks = 1;  z1 = -1;  p1 = 0;
% --- Impulsion ---
Li = 60;     Di = 0.075;  epsilon_i = 0.00005;  ki = 3;  z2 = 50;  p2 = 0;
% --- Cota de las bombas (todas a la misma cota, acople sin perdidas) ---
zB = 0;

% --- Curva de catalogo de UNA bomba ---
Qcat = [0.0 2.5 5.0 7.5 10.0 12.5 15.0]/1000; % m3/s
Hcat = [39 38 35 31 26 20 13];                 % m
etacat = [0 45 66 70 67 57 40];                % %
NPSHrcat = [4.0 4.5 5.3 6.5 8.0 10.0 13.0];    % m
%% =====================

As = pi*Ds^2/4; Ai = pi*Di^2/4;

% Chequeo rapido serie vs. paralelo (numero minimo de bombas)
Dz_estatico = z2 - z1 + (p2-p1)/(ro*g);
printf('Carga estatica a vencer (Q~0) = %.2f m ; Hmax de 1 bomba = %.1f m\n', Dz_estatico, max(Hcat));
if Dz_estatico > max(Hcat)
  printf('=> 1 sola bomba NO alcanza. En PARALELO tampoco (Hmax no crece). Hace falta SERIE.\n\n');
else
  printf('=> alcanza con 1 bomba o con paralelo (Hmax de 1 bomba ya supera la carga estatica).\n\n');
end

if strcmp(MODO,'paralelo')
  Qtot = linspace(0.0001, N*max(Qcat), 400);
  Q1 = Qtot/N;                       % caudal de CADA bomba
  Hb_eq = interp1(Qcat,Hcat,Q1,'pchip'); % todas ven la misma H
  Qsucc = @(Qt) Qt;                  % succion comun transporta el TOTAL
else
  Q1 = linspace(0.0001, max(Qcat), 400); % caudal de cada bomba = caudal de linea
  Hb1 = interp1(Qcat,Hcat,Q1,'pchip');
  if strcmp(MODO,'serie')
    Hb_eq = N*Hb1;
  else % 'una'
    Hb_eq = Hb1;
  end
  Qtot = Q1;
  Qsucc = @(Qt) Qt;
end

Hinst = zeros(size(Qtot));
NPSHdisp_primera = zeros(size(Qtot));
for i = 1:length(Qtot)
  vs = Qsucc(Qtot(i))/As;
  Re_s = max(vs*Ds/nu, 1);
  fs = colebrook(Re_s, epsilon_s/Ds);
  deltaS = fs*Ls/Ds*vs^2/(2*g) + ks*vs^2/(2*g);
  HA = z1 + p1/(ro*g) + vs^2/(2*g) - deltaS;

  vi = Qtot(i)/Ai; % la impulsion transporta el caudal TOTAL siempre (serie o paralelo, una sola linea de impulsion)
  Re_i = max(vi*Di/nu, 1);
  fi = colebrook(Re_i, epsilon_i/Di);
  deltaI = fi*Li/Di*vi^2/(2*g) + ki*vi^2/(2*g);
  HB = z2 + p2/(ro*g) + vi^2/(2*g) + deltaI;

  Hinst(i) = HB - HA;
  NPSHdisp_primera(i) = 10.1 + HA - zB - vs^2/(2*g);
end

[~, idx] = min(abs(Hb_eq - Hinst));
Qpf_total = Qtot(idx);
Qpf_bomba = Q1(idx);
Hpf_bomba = interp1(Qcat,Hcat,Qpf_bomba,'pchip');
eta_pf = interp1(Qcat,etacat,Qpf_bomba,'pchip');
NPSHr_pf = interp1(Qcat,NPSHrcat,Qpf_bomba,'pchip');

printf('MODO=%s, N=%d bombas\n', MODO, N);
printf('Q total del sistema = %.5f m3/s = %.3f L/s\n', Qpf_total, Qpf_total*1000);
printf('Q por cada bomba    = %.5f m3/s = %.3f L/s\n', Qpf_bomba, Qpf_bomba*1000);
printf('H por cada bomba (=curva de catalogo en Qpf_bomba) = %.2f m\n', Hpf_bomba);
printf('H equivalente / instalacion en el PF = %.2f m\n', Hb_eq(idx));
printf('Rendimiento de cada bomba = %.1f %%\n', eta_pf);

P_bomba = ro*g*Qpf_bomba*Hpf_bomba/(eta_pf/100);
P_sistema = N*P_bomba;
printf('Potencia por bomba = %.3f kW ; Potencia del sistema = %.3f kW\n\n', P_bomba/1000, P_sistema/1000);

NPSHd_pf = NPSHdisp_primera(idx);
printf('NPSHdisp (bomba mas comprometida) = %.3f m ; NPSHr(Qpf_bomba) = %.3f m\n', NPSHd_pf, NPSHr_pf);
if NPSHd_pf < NPSHr_pf
  printf('=> CAVITA\n');
else
  printf('=> NO cavita\n');
end
if strcmp(MODO,'serie') && N>1
  printf('\n(bombas 2..N en la serie tienen MAS NPSHdisp que la primera: cada una suma\n');
  printf(' el H ya entregado por las anteriores, NPSHdisp_k = NPSHdisp_1 + (k-1)*Hpf_bomba)\n');
end
