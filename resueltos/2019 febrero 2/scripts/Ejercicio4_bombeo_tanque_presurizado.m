% Ejercicio4_bombeo_tanque_presurizado.m -- Examen HHA 22/feb/2019
% ("2019 febrero 2"), Ejercicio 4.
%
% Bombeo entre un tanque INFERIOR abierto a la atmosfera (nivel z1=-2 m)
% y un tanque ELEVADO PRESURIZADO (nivel z=+10 m, p=100 kPa). La
% tuberia de impulsion DESCARGA LIBRE dentro del tanque elevado, a una
% cota de +12 m (por encima del nivel de agua: la boca de la caneria
% queda en el espacio de aire presurizado del tanque, no sumergida).
%
% Succion: Ds=100 mm, Ls=5 m, ks=1. Impulsion: Di=100 mm, Li=100 m,
% ki=3. Acero galvanizado, rugosidad 0.05 mm. Bomba ubicada a cota
% zB=-1 m, con curva H-Q, rendimiento y NPSHr dados por tabla.
%
% METODO (ver RESUMEN_TEORICO.md S:C1-C4):
% - H1 (succion) = z1 + p1/(rho g) + v1^2/2g = z1 (tanque abierto,
%   superficie libre grande, v1=0).
% - H2 (descarga LIBRE dentro del tanque presurizado) = z_desc +
%   p_tanque/(rho g) + v2^2/2g -- OJO: como es descarga libre (chorro,
%   no sumergida), el termino cinetico de salida NO se cancela (no hay
%   "tanque grande" del lado de la impulsion que absorba la velocidad):
%   se cuenta v2^2/2g de la propia caneria de impulsion en la boca de
%   salida. Ademas la presion en la boca es la del AIRE del tanque
%   (100 kPa), no la atmosferica, porque el chorro descarga dentro del
%   espacio presurizado del tanque.
% - Hinst(Q) = H2(Q) - H1 + perdidas succion(Q) + perdidas impulsion(Q).
% - Punto de funcionamiento: interseccion de Hinst(Q) con la curva de
%   la bomba H(Q) (fzero).
% - NPSHdisp = 10.1 + HA - zB - vs^2/(2g), con HA=z1+p1/(rho g)+
%   vs^2/2g-perdidas succion(Q) (OJO doble conteo del termino cinetico,
%   ver comentario en Bomba_sola.m canonico).
% - Parte 2: se busca el nivel z1_min tal que, en el NUEVO punto de
%   funcionamiento que resulta con ese z1 (la curva de instalacion se
%   desplaza al bajar z1, así que el punto de funcionamiento tambien se
%   mueve), NPSHdisp = NPSHreq exactamente (limite de cavitacion).
%
% Requiere, en esta misma carpeta: colebrook.m (toolkit canonico
% RESUMEN EXAMEN/Codigos/Bombas/).

clc; clear; close all;
warning('off','all');

%% ==== EDITAR ACA (datos del enunciado) ====
g   = 9.81;
ro  = 997;
nu  = 1e-6;
eps_pipe = 0.00005;  % rugosidad acero galvanizado, m (0.05 mm)

% Succion
Ls = 5;      Ds = 0.1;   ks = 1;
z1 = -2;     p1 = 0;

% Impulsion (descarga libre en el tanque presurizado)
Li = 100;    Di = 0.1;   ki = 3;
z2 = 12;     p2 = 100e3;  % Pa (presion del AIRE del tanque, en la boca de descarga)

% Cota de la bomba
zB = -1;

% Curva de la bomba
Qtab    = [0.0 5.0 10.0 15.0 20.0 25.0 30.0]/1000;  % m3/s
Htab    = [40.0 39.0 36.0 32.0 27.0 20.0 12.0];      % mca
etatab  = [0 43 68 75 70 55 30];                     % %
NPSHrtab= [3.0 3.4 4.2 5.1 7.0 9.0 12.0];             % m

As = pi*Ds^2/4;
Ai = pi*Di^2/4;
%% ============================================

function [Hinst,HA,vs] = instalacion(Q,z1,p1,z2,p2,Ls,Ds,ks,Li,Di,ki,ro,g,nu,eps_pipe,As,Ai)
    vs = Q/As;
    Res = vs*Ds/nu;
    fs = colebrook(Res, eps_pipe/Ds);
    dHs = (ks + fs*Ls/Ds)*vs^2/(2*g);
    HA = z1 + p1/(ro*g) + vs^2/(2*g) - dHs;   % carga en la brida de succion

    vi = Q/Ai;
    Rei = vi*Di/nu;
    fi = colebrook(Rei, eps_pipe/Di);
    dHi = (ki + fi*Li/Di)*vi^2/(2*g);
    H2 = z2 + p2/(ro*g) + vi^2/(2*g);          % descarga LIBRE: se cuenta vi^2/2g (no se cancela)

    H1 = z1 + p1/(ro*g);                        % (v1=0, tanque abierto grande)
    Hinst = H2 - H1 + dHs + dHi;
endfunction

function Qpf = punto_funcionamiento(z1,p1,z2,p2,Ls,Ds,ks,Li,Di,ki,ro,g,nu,eps_pipe,As,Ai,Qtab,Htab)
    residuo = @(Q) interp1(Qtab,Htab,Q,'pchip') - instalacion(Q,z1,p1,z2,p2,Ls,Ds,ks,Li,Di,ki,ro,g,nu,eps_pipe,As,Ai);
    Qpf = fzero(residuo, 0.015);
endfunction

fprintf('=================== PARTE 1: punto de funcionamiento ===================\n');
Qpf = punto_funcionamiento(z1,p1,z2,p2,Ls,Ds,ks,Li,Di,ki,ro,g,nu,eps_pipe,As,Ai,Qtab,Htab);
[Hinst_pf, HA_pf, vs_pf] = instalacion(Qpf,z1,p1,z2,p2,Ls,Ds,ks,Li,Di,ki,ro,g,nu,eps_pipe,As,Ai);
Hpf = interp1(Qtab,Htab,Qpf,'pchip');
eta_pf = interp1(Qtab,etatab,Qpf,'pchip');
NPSHr_pf = interp1(Qtab,NPSHrtab,Qpf,'pchip');

fprintf('Qpf = %.5f m3/s (%.2f L/s)\n', Qpf, Qpf*1000);
fprintf('Hpf (curva bomba = curva instalacion) = %.3f m\n', Hpf);
fprintf('Eficiencia en Qpf = %.2f %%\n', eta_pf);

Pot = ro*g*Qpf*Hpf/(eta_pf/100);
fprintf('Potencia consumida = rho*g*Q*H/eta = %.1f W = %.3f kW\n', Pot, Pot/1000);

NPSHdisp_pf = 10.1 + HA_pf - zB - vs_pf^2/(2*g);
fprintf('NPSHdisp = 10.1 + HA - zB - vs^2/2g = %.3f m\n', NPSHdisp_pf);
fprintf('NPSHreq (tabla, en Qpf) = %.3f m\n', NPSHr_pf);
if NPSHdisp_pf > NPSHr_pf
    fprintf('=> NPSHdisp > NPSHreq: la bomba NO CAVITA (margen %.3f m)\n', NPSHdisp_pf-NPSHr_pf);
else
    fprintf('=> NPSHdisp < NPSHreq: LA BOMBA CAVITA\n');
end


fprintf('\n=================== PARTE 2: nivel minimo del tanque inferior ===================\n');
% Se busca z1 tal que, en el NUEVO punto de funcionamiento (la curva de
% instalacion se desplaza al variar z1), NPSHdisp(z1,Qpf(z1)) = NPSHreq(Qpf(z1)).
function res = margen_npsh(z1_test,p1,z2,p2,Ls,Ds,ks,Li,Di,ki,ro,g,nu,eps_pipe,As,Ai,Qtab,Htab,NPSHrtab,zB)
    Qpf_i = punto_funcionamiento(z1_test,p1,z2,p2,Ls,Ds,ks,Li,Di,ki,ro,g,nu,eps_pipe,As,Ai,Qtab,Htab);
    [~,HA_i,vs_i] = instalacion(Qpf_i,z1_test,p1,z2,p2,Ls,Ds,ks,Li,Di,ki,ro,g,nu,eps_pipe,As,Ai);
    NPSHdisp_i = 10.1 + HA_i - zB - vs_i^2/(2*g);
    NPSHreq_i = interp1(Qtab,NPSHrtab,Qpf_i,'pchip');
    res = NPSHdisp_i - NPSHreq_i;
endfunction

z1_min = fzero(@(z) margen_npsh(z,p1,z2,p2,Ls,Ds,ks,Li,Di,ki,ro,g,nu,eps_pipe,As,Ai,Qtab,Htab,NPSHrtab,zB), z1-3);

Qpf_min = punto_funcionamiento(z1_min,p1,z2,p2,Ls,Ds,ks,Li,Di,ki,ro,g,nu,eps_pipe,As,Ai,Qtab,Htab);
Hpf_min = interp1(Qtab,Htab,Qpf_min,'pchip');
[~,HA_min,vs_min] = instalacion(Qpf_min,z1_min,p1,z2,p2,Ls,Ds,ks,Li,Di,ki,ro,g,nu,eps_pipe,As,Ai);
NPSHdisp_min = 10.1 + HA_min - zB - vs_min^2/(2*g);
NPSHreq_min = interp1(Qtab,NPSHrtab,Qpf_min,'pchip');

fprintf('z1_min = %.3f m\n', z1_min);
fprintf('  -> nuevo punto de funcionamiento: Qpf = %.5f m3/s (%.2f L/s), Hpf = %.3f m\n', Qpf_min, Qpf_min*1000, Hpf_min);
fprintf('  -> NPSHdisp = NPSHreq = %.3f m (limite de cavitacion)\n', NPSHdisp_min);
fprintf('\nRESUMEN: el nivel del tanque inferior puede descender hasta z1=%.2f m sin que la bomba cavite;\n', z1_min);
fprintf('por debajo de esa cota, NPSHdisp<NPSHreq y la bomba cavitaria.\n');
