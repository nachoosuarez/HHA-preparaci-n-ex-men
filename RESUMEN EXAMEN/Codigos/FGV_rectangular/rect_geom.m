% rect_geom.m ‚Äî calcula las propiedades geom√©tricas de una secci√≥n
% RECTANGULAR (ancho superficial B=b, √°rea A, per√≠metro mojado P, radio
% hidr√°ulico R, profundidad del baricentro yG=y/2, profundidad
% hidr√°ulica D) dado el tirante y y el ancho b. Funci√≥n geom√©trica base
% para los dem√°s scripts de este directorio (Mom_rect, Eesp_rect,
% froude_rect, manning_rect, fgv_rect, rect.m). Usar cuando: cualquier
% c√°lculo de canal rectangular (caso particular de trap_geom.m con m=0,
% pero con f√≥rmulas cerradas m√°s simples).
function [B,A,P,R,yG,D]=rect_geom(y,b)
% funciÛn que calcula los par·metros geomÈtricos de una secciÛn rectangular
%
% INPUT
% y tirante (m)
% b ancho del canal (m)
%
% OUTPUT
% B   ancho superficial (m)
% A   ·rea (m^3)
% P   perÌmetro mojado (m)
% R   radio hidr·ulico (m)
% yG  distancia desde la superficie libre al baricentro de la seccion (m)
% D   profundidad hidr·ulica (m)
%
B=b; 
A=b.*y;
P=b+2*y; 
R= A./P;
yG=y/2;
D=A./B;
