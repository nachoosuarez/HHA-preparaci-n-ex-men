% Ejercicio4_bomba_incendio.m — Examen HHA diciembre 2022, Ejercicio 4.
% Sistema de bombeo para combate de incendios: succion con manometro
% (p1=1e5 Pa a z1=0m, L1=20m) alimentando una bomba (cota zA=+1m) que
% impulsa (L2=80m) hasta una tobera de descarga a la atmosfera (DT=30mm)
% a cota z2 (15m en las Partes 1-3). Succion e impulsion tienen el mismo
% diametro D=45mm y rugosidad absoluta eps=0.01mm; k1=6 (succion), k2=5
% (impulsion, coeficiente referido a la velocidad EN LA TUBERIA, no en
% la tobera).
%
% Resuelve:
%  1) Punto de funcionamiento (Qpf,Hpf) con z2=15m.
%  2) Potencia consumida por el sistema de bombeo.
%  3) NPSH disponible vs. requerido (verificar que no cavita).
%  4) Cota maxima z2 para asegurar un caudal minimo de bombeo Qmin=4.5 l/s.
%
% Requiere colebrook.m (mismo directorio).

%% Datos generales
g = 9.8;
rho = 1000;
nu = 1e-6;
eps = 0.01e-3;   % rugosidad absoluta (m), igual en succion e impulsion
D  = 0.045;      % diametro succion e impulsion (m)
DT = 0.030;      % diametro de la tobera (m)
A  = pi*D^2/4;
AT = pi*DT^2/4;

L1 = 20; k1 = 6;   % succion (entre el manometro y la bomba)
L2 = 80; k2 = 5;   % impulsion (entre la bomba y la tobera)

z1 = 0;     % cota del manometro (succion)
p1 = 1e5;   % Pa (lectura del manometro, presion relativa)
zA = 1;     % cota de la bomba

%% Curva de la bomba (catalogo, tabla del enunciado)
Qcat = [0.25 1 2 3 4 5 6 7 8 9 10 11]/1000;   % m3/s (dato en L/s / 1000)
Hcat = [50.83 50.16 49.59 48.64 47.5 46.36 45.03 43.89 42.75 40.66 37.62 34.2];
etacat = [23 51.75 65.55 73.6 78.2 81.65 85.1 88.55 89.7 88.55 86.25 82.8];
NPSHreqcat = [2.7 3.2 3.5 3.8 4.1 4.6 5.3 6.1 6.7 7.3 8 8.5];

%% ---------------- PARTE 1: punto de funcionamiento (z2=15m) ----------------
z2 = 15;

function [Hinst, HA, Vs] = curva_instalacion(Q, z1, p1, zA, z2, L1, k1, L2, k2, D, DT, eps, g, rho, nu)
  A  = pi*D^2/4;
  AT = pi*DT^2/4;
  Vs = Q/A;  % velocidad en succion Y en impulsion (mismo D)
  Re = Vs*D/nu;
  f  = colebrook(Re, eps/D);
  dH_succ = (k1 + f*L1/D) * Vs^2/(2*g);
  dH_imp  = (k2 + f*L2/D) * Vs^2/(2*g);
  VT = Q/AT;
  H1 = z1 + p1/(rho*g) + Vs^2/(2*g);
  H2 = z2 + VT^2/(2*g);              % descarga a la atmosfera, p2=0
  Hinst = H2 - H1 + dH_succ + dH_imp;
  HA = H1 - dH_succ;                 % carga en la brida de succion de la bomba
end

Qmalla = linspace(min(Qcat), max(Qcat), 2000);
Hb = interp1(Qcat, Hcat, Qmalla, 'pchip');
Hinst = arrayfun(@(Q) curva_instalacion(Q, z1, p1, zA, z2, L1, k1, L2, k2, D, DT, eps, g, rho, nu), Qmalla);

[~, idx] = min(abs(Hb - Hinst));
Qpf = Qmalla(idx);
Hpf = Hb(idx);
[~, HA_pf, Vs_pf] = curva_instalacion(Qpf, z1, p1, zA, z2, L1, k1, L2, k2, D, DT, eps, g, rho, nu);
VT_pf = Qpf/AT;
Re_pf = Vs_pf*D/nu;
f_pf = colebrook(Re_pf, eps/D);

printf('PARTE 1: Qpf=%.4f L/s | Hpf=%.3f m | Vsucc=Vimp=%.3f m/s | VT=%.3f m/s | f=%.4f\n', ...
       Qpf*1000, Hpf, Vs_pf, VT_pf, f_pf);

%% ---------------- PARTE 2: potencia consumida ----------------
eta_pf = interp1(Qcat, etacat, Qpf, 'pchip');
Pot = rho*g*Qpf*Hpf/(eta_pf/100);
printf('PARTE 2: eta(Qpf)=%.2f %% | Potencia consumida = %.1f W = %.3f kW\n', eta_pf, Pot, Pot/1000);

%% ---------------- PARTE 3: NPSH disponible vs requerido ----------------
% OJO (distinto de Bomba_sola.m): ahí z1 es la superficie libre de un
% deposito (V~0 en z1, pero el script agrega igual Vs^2/2g a H1 "de mas"
% y hay que restarlo despues para no contarlo dos veces). ACA z1 es la
% posicion de un MANOMETRO dentro de la propia caneria de succion, donde
% la velocidad Vs ya es real y H1=z1+p1/(rho g)+Vs^2/2g representa
% correctamente (una sola vez) la energia en ese punto -- no hay nada
% que restar de mas. Verificado contra la solucion oficial (9.8 m):
% con la resta extra de Vs^2/2g (formula de Bomba_sola.m aplicada sin
% pensar) da 9.05 m, que NO cierra con la oficial.
patm_menos_pvap_sobre_gamma = 10.1; % m (10.33 atm - 0.24 vapor, aprox. agua a 20C)
NPSHdisp_pf = patm_menos_pvap_sobre_gamma + HA_pf - zA;
NPSHreq_pf = interp1(Qcat, NPSHreqcat, Qpf, 'pchip');
printf('PARTE 3: NPSHdisp=%.2f m | NPSHreq=%.2f m | %s\n', NPSHdisp_pf, NPSHreq_pf, ...
       merge(NPSHdisp_pf>NPSHreq_pf, 'NO CAVITA', 'CAVITA'));

%% ---------------- PARTE 4: z2max para Qmin=4.5 L/s ----------------
Qmin = 4.5/1000;
[Hinst_ref, ~, Vs_min] = curva_instalacion(Qmin, z1, p1, zA, 0, L1, k1, L2, k2, D, DT, eps, g, rho, nu); % con z2=0 para aislar el resto
Hb_min = interp1(Qcat, Hcat, Qmin, 'pchip');
% Hinst(Qmin; z2) = z2 + Hinst_ref(z2=0)  =>  z2max = Hb(Qmin) - Hinst_ref(z2=0)
z2max = Hb_min - Hinst_ref;
printf('PARTE 4: Hb(Qmin)=%.3f m | resto(sin z2)=%.3f m | z2max = %.2f m\n', Hb_min, Hinst_ref, z2max);
