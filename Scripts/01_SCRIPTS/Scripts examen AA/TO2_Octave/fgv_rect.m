%%%%% FGV en Canal Trapezoidal %%%%%
%AVISO: 
% Las funciones "rect.m", "froude_rect.m", "manning_rect.m", "rect_geom.m" y "critico.m" deben estar en la misma carpeta que este script "fgv_rect.m"
%IMPORTANTE:
% Matlab cambió como maneja las funciones anidadas entre la version 6.1 que hay en las salas de computadoras de facultad y las versiones mas nuevas.
% El código que sigue contempla la sintaxix nueva de Matlab que es la que también usa Octave.
% La función fsolve en Matlab no admite el uso de function handles, a diferencia de Octave que si lo permite.
%% Datos de entrada
clear all% borra todas las variables
 
Q = 10;% caudal (m3/s)
b = 5;% ancho de fondo (m)
S = 0.001;% pendiente de fondo
n = 0.03;% n de Manning
 
%% Cálculo tirante crítico, 
yc=(Q^2/(9.8*b^2))^(1/3);% estimación inicial del tirante crítico suponiendo canal rectangular (m) 
% En el caso rectangular esta estimación inical es la solución. Las siguientes líneas de código se incluye aquí como ayuda para el caso trapezoidal.
par=[Q b];% vector con parámetros
yc=fsolve(@(y) froude_rect(y,par), yc);% tirante critico (m)

[Bc,Ac,Pc,Rc,yGc,Dc]=rect_geom(yc,b);% cálculo de parámetros geométricos asociados a las condiciones de flujo crítico
Uc=Q/Ac;% velocidad en flujo crítico  (m/s)
Ec=yc+Uc^2/(2*9.8);% energía específica en flujo crítico (m)
 
%% Cálculo tirante normal
if S<=0
    yn=inf;% si la pendiente es negativa o cero el tirante normal se supone infinito, para los otros casos se calcula a continuación
else
    yn=(Q*n/(b*S^0.5))^(3/5);% estimación inicial del tirante normal suponiendo canal rectangular muy ancho b>>yn ancho (m)
    par=[Q b S n];% vector con parámetros 
    yn=fsolve(@(y) manning_rect(y,par), yn);% tirante normal (m)

    [Bn,An,Pn,Rn,yGn,Dn]=rect_geom(yn,b);% cálculo de parámetros geométricos asociados a las condiciones de flujo normal
    Un=Q/An;% velocidad en flujo normal (m/s)
    En=yn+Un^2/(2*9.8);% energía específica en flujo normal (m)
end
%% Flujo Gradualmente Variado
 
% Condiciones de borde
x_ini=700;% x inicial (m)
x_end=0;% x final (m)
y_ini=yc+0.001;% y (tirante) inicial correspondiente a x_ini (m)
% NOTA: se debe tener en cuenta el signo de x_end dependiendo desde donde se calcula la curva de FGV:
% * si es una curva en condiciones de flujo SUBCRITICO, entonces se calcula
% desde aguas abajo hacia aguas arriba y x_end debe ser menor que x_ini.
% * si es una curva en condiciones de flujo SUPERCRITICO, entonces se calcula
% desde aguas arriba hacia aguas abajo y x_end debe ser mayor que x_ini.
% x crece desde aguas arriba hacia aguas abajo, es decir en la dirección del flujo
 
% Resolución de la curva de FGV
par=[Q b S n yc];% vector con parámetros 
options = odeset('Events',@(x,y) critico(x,y,par));% parámetros auxiliares de configuración para la función ode23 para detener la resolución de la ecuación diferencial cuando se llega al tirante crítico
[x,y]=ode23(@(x,y) rect(x,y,par),[x_ini,x_end],y_ini,options);% x es el vector con las x donde se calcularon los valores de y
    
y_end=y(end);% y (tirante) final correspondiente a x_end (m)
%% Gráfico
lw=4;% espesor de línea en los gráficos
fs=15;% tamaño de letra en los gráficos

figure(1)
clf
% Define posición y tamaño de la figura en función del tamaño de la pantalla
scrsz = get(0,'ScreenSize');
set(gcf,'Position',[scrsz(3)*0.005 scrsz(4)*0.395 scrsz(3)*0.99 scrsz(4)/2])

% Grafica fondo, superficie libre y tirantes crítico y normal
p1=plot([x(1), x(end)],-[x(1), x(end)]*S,'-k','LineWidth',lw);%zb cota del fondo del canal
hold on
p2=plot(x,y-x*S,'-b','LineWidth',lw);%zw cota de la superficie libre
p3=plot([x(1), x(end)],[yc-x(1)*S, yc-x(end)*S],'--r','LineWidth',lw);%zc cota de la superficie libre en flujo crítico
p4=plot([x(1), x(end)],[yn-x(1)*S, yn-x(end)*S],'--g','LineWidth',lw);%zn cota de la superficie libre en flujo normal
xlabel('x (m)','FontSize',fs,'FontWeight','Demi')
ylabel('z (m)','FontSize',fs,'FontWeight','Demi')
%set(gca,'LineWidth',lw/2,'FontSize',fs,'FontWeight','Demi')
set(gca,'LineWidth',lw/2,'FontSize',fs)

% Agrega referencias de la figura
lhd=legend([p1;p2;p3;p4],...
      ['z_b';...
       'z_w';...
       'z_c';...
       'z_n'],3);
%set(lhd,'Box','off','Location','SouthWest','FontSize',fs,'FontWeight','Demi')
set(lhd,'Box','off','Location','SouthWest','FontSize',fs)    

%% Ejemplo de cálculos adicionales
% [E_end,yalt]=Eesp_rect(y_end,b,Q);
% [B,A,P,R,yG,D]=rect_geom(y,b);
% Sf=(Q*n./R.^(2/3)./A).^2;
% tau=9800*R.*Sf;
% [M,yconj]=Mom_rect(0.7928,b,Q);

% figure(2)
% clf
% % Define posición y tamaño de la figura en función del tamaño de la pantalla
% scrsz = get(0,'ScreenSize');
% set(gcf,'Position',[scrsz(3)*0.005 scrsz(4)*0.395 scrsz(3)*0.99 scrsz(4)/2])
% 
% % Grafica tirnate
% p1=plot(x,y,'-k','LineWidth',lw);%zb cota del fondo del canal


