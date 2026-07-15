%%%%% FGV en Canal Circular %%%%%
%AVISO: 
%Las funciones "circ.m", "froude_circ.m", "manning_circ.m", "circ_geom.m" y "critico.m" deben estar en la misma carpeta que este script "fgv_circ.m"

%% Datos de entrada
clearvars

Q = 0.73;% caudal en m3/s
d = 1;% diametro en m
S = 0.001;% pendiente de fondo 0.000018;
n = 0.014;% n de Manning

% Calculo tirante crítico
yc=min(d,(Q^2*(pi/4)^2/9.8)^(1/5));% Estimaciones inicales de tirante crítico
par=[Q d];% vector con parametros 
yc=fzero(@(y) froude_circ(y,par), yc);% tirante critico
[Bc,Ac,Pc,Rc,yGc,Dc]=circ_geom(yc,d);
Uc=Q/Ac;
Ec=yc+Uc^2/(2*9.8);
%%
% Calculo tirante normal
yn1=NaN;
yn2=NaN;
[ttnmax,Bnmax,Anmax,Pnmax,Rnmax,yGnmax,Dnmax]=circ_geom(d*0.938,d);% Maximo caudal transportable en flujo uniforme pare n y S dados
Qnmax=1/n*Anmax*Rnmax^(2/3)*S^0.5;% Condicion de exitencia del tirante normal
if Q<Qnmax
    yn1=(Q*n/(S^0.5))^(3/8);% Estimacion inical del tirante normal
    par=[Q d S n];% vector con parametros 
    yn1=fzero(@(y) manning_circ(y,par), yn1);% tirante normal
    [Bn1,An1,Pn1,Rn1,yGn1,Dn1]=circ_geom(yn1,d);
    Un1=Q/An1;
    En1=yn1+Un1^2/(2*9.8);
    taun1=9800*Rn1.*S;
% Condicion para que exitan dos tirantes normales
    if yn1>0.81963% a partir de este tirante normal existe un segundo tirante normal
        yn2=fzero(@(y) manning_circ(y,par), d*0.99999);% tirante normal
        [Bn2,An2,Pn2,Rn2,yGn2,Dn2]=circ_geom(yn2,d);
        Un2=Q/An2;
        En2=yn2+Un2^2/(2*9.8);
        taun2=9800*Rn2.*S;
    end
end

%% FGV
% Condiciones de borde
x_ini=500;% x inicial en m
x_end=0;% x final en m, tner en cuenta el signo si voy aguas arriba o aguas abajo. x crece hacia aguas abajo
y_ini=0.9;% y (tirante) inicial en m 0.975

% Resolución
par=[Q d S n];% vector con parametros 
options = odeset('Events',@(x,y) critico_lleno(x,y,yc,d));% para parar la resolucion de la ec. dif. cuando se llega al tirante crítico
[xdum,ydum]=ode23(@(x,y) circ(x,y,par),[x_ini,x_end],y_ini,options);% x es el vector con las x donde se calcularon los valores de y
y=real(ydum(imag(ydum)==0));% Se toman valores reales porque el criterio de parada a flujo lleno no para siempre la resolucion a tiempo
x=xdum(imag(ydum)==0);
y_end=y(end);

%% Gráfico
figure(1)
clf
p1=plot([x(1), x(end)],-[x(1), x(end)]*S,'k');%zb cota del lecho
hold on
plot([x(1), x(end)],-[x(1), x(end)]*S+d,'k');%zb cota del lecho
p2=plot(x,y-x*S,'b');%zf cota de la superficie libre
p3=plot([x(1), x(end)],[yc-x(1)*S, yc-x(end)*S],'r');%zc cota de la superfice libre en flujo crítico
p4=plot([x(1), x(end)],[yn1-x(1)*S, yn1-x(end)*S],'g');%zn cota de la superfice libre en flujo normal
p4=plot([x(1), x(end)],[yn2-x(1)*S, yn2-x(end)*S],'g');%zn cota de la superfice libre en flujo normal

xlabel('x (m)')
ylabel('z (m)')

lhd=legend([p1;p2;p3;p4],...
    ['z_b';...
     'z_f';...
     'z_c';...
     'z_n']);
set(lhd,'Box','off','Location','SouthWest')

%% Extras
%[E_end,yalt]=Eesp_trapez(y_end,b,m,Q);
% [B,A,P,R,yG,D]=trapez_geom(0.504,b,m)
% Sf=(Q*n./R.^(2/3)./A).^2
% tau=9800*R.*Sf
% tau=9800*Rn.*S
