% Bombas_LineasDeCarga.m — calcula, punto a punto a lo largo de una
% instalación de bombeo (succión -> bomba -> impulsión, con codos y
% cambios de sección), la línea de carga (energía) y la línea
% piezométrica (presión), y la presión relativa en cada punto notable.
% Entradas: cotas de cada punto notable (zT1,z_c1,z_b,z_c2,z_c3,zT2),
% longitudes por tramo (L1..L4), diámetro D, caudal Q de funcionamiento
% (ya conocido, p.ej. del punto de funcionamiento hallado con
% Bomba_sola.m), rugosidad, coeficientes de pérdida localizada (k_ent,
% k_codo,k_sal) y la carga de bomba HB en ese caudal.
% Salidas: h1..h11 (línea de energía) y h_piez_1..11 (línea piezométrica)
% en cada punto, y p1..p11 (presión relativa respecto a la cota real del
% tramo) — útil para chequear que no haya presión negativa excesiva.
% Usar cuando: piden graficar/tabular la línea de carga y la
% piezométrica de una instalación de bombeo ya resuelta (Q y HB
% conocidos). Requiere colebrook.m.
clc; clear; close all;

% ========================
% DATOS DEL PROBLEMA
% ========================
g = 9.81;
rho = 997;
nu = 1e-6;
epsilon = 0.00015;

% Longitudes
L1 = 2;
L2 = 10;
L3 = 75;
L4 = 6;

% Cotas
zT1 = -5;
z_c1 = -10;
z_b  = 0;
z_c2 = 0;
z_c3 = 6;
zT2 = 10;

% Diametro
D = 0.102;

% Punto de funcionamiento
Q = 59.47/3600;   % m3/s
A = pi*D^2/4;
v = Q/A;
head_vel = v^2/(2*g);

% Friccion f
Re = v*D/nu;
f = colebrook(Re, epsilon/D);

% Perdidas localizadas
k_ent = 0.5;
k_codo = 0.9;
k_sal = 1.0;

% Cabeza de bomba
HB = 20.18;

h1=zT1;
h2=h1-k_ent*(v^2)/(2*g);
h3=h2-f*L1/D*(v^2)/(2*g);
h4=h3-k_codo*(v^2)/(2*g);
h5=h4-f*L2/D*(v^2)/(2*g);
h6=h5+HB;
h7=h6-f*L3/D*(v^2)/(2*g);
h8=h7-k_codo*(v^2)/(2*g);
h9=h8-f*L4/D*(v^2)/(2*g);
h10=h9-k_codo*(v^2)/(2*g);
h11=h10-k_sal*(v^2)/(2*g);

h_piez_1=h1;
h_piez_2=h2-(v^2)/(2*g);
h_piez_3=h3-(v^2)/(2*g);
h_piez_4=h4-(v^2)/(2*g);
h_piez_5=h5-(v^2)/(2*g);
h_piez_6=h6-(v^2)/(2*g);
h_piez_7=h7-(v^2)/(2*g);
h_piez_8=h8-(v^2)/(2*g);
h_piez_9=h9-(v^2)/(2*g);
h_piez_10=h11-(v^2)/(2*g);
h_piez_11=h11;

p1=h_piez_1-(-5);
p2=h_piez_2-(-5);
p3=h_piez_3-(-5);
p4=h_piez_4-(-5);
p5=h_piez_5-0;
p6=h_piez_6-0;
p7=h_piez_7-0;
p8=h_piez_8-0;
p9=h_piez_9-6;
p10=h_piez_10-6;
p11=h_piez_11-(10);

