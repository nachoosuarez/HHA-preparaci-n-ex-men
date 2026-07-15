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

