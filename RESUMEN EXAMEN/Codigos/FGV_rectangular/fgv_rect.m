% fgv_rect.m — script principal de FLUJO GRADUALMENTE VARIADO (FGV) en
% canal RECTANGULAR: calcula yc (crítico, cerrado) y yn (normal, por
% fsolve), integra la ecuación diferencial dy/dx (rect.m) con ode23
% deteniéndose al cruzar yc (evento critico.m), y grafica el perfil de
% la superficie libre junto a las rasantes de yc/yn. Editar los DATOS DE
% ENTRADA (Q,b,S,n) y las condiciones de borde (x_ini,x_end,y_ini) según
% el enunciado — el signo de x_end define si se integra hacia aguas
% arriba (subcrítico) o hacia aguas abajo (supercrítico).
% Usar cuando: piden el perfil y(x) de un canal rectangular (curvas
% M1/M2/M3, S1/S2/S3, etc.). Requiere rect_geom.m, rect.m, critico.m,
% froude_rect.m, manning_rect.m.
% (El título original decía "Canal Trapezoidal" por copia/pegado del
% script trapezoidal — este script es en realidad para sección
% rectangular, como indica su propio contenido.)
%%%%% FGV en Canal Trapezoidal %%%%%
%AVISO:
% Las funciones "rect.m", "froude_rect.m", "manning_rect.m", "rect_geom.m" y "critico.m" deben estar en la misma carpeta que este script "fgv_rect.m"
%IMPORTANTE:
% Matlab cambi� como maneja las funciones anidadas entre la version 6.1 que hay en las salas de computadoras de facultad y las versiones mas nuevas.
% El c�digo que sigue contempla la sintaxix nueva de Matlab que es la que tambi�n usa Octave.
% La funci�n fsolve en Matlab no admite el uso de function handles, a diferencia de Octave que si lo permite.
%% Datos de entrada
clear all% borra todas las variables
 
Q = 10;% caudal (m3/s)
b = 5;% ancho de fondo (m)
S = 0.001;% pendiente de fondo
n = 0.03;% n de Manning
 
%% C�lculo tirante cr�tico, 
yc=(Q^2/(9.8*b^2))^(1/3);% estimaci�n inicial del tirante cr�tico suponiendo canal rectangular (m) 
% En el caso rectangular esta estimaci�n inical es la soluci�n. Las siguientes l�neas de c�digo se incluye aqu� como ayuda para el caso trapezoidal.
par=[Q b];% vector con par�metros
yc=fsolve(@(y) froude_rect(y,par), yc);% tirante critico (m)

[Bc,Ac,Pc,Rc,yGc,Dc]=rect_geom(yc,b);% c�lculo de par�metros geom�tricos asociados a las condiciones de flujo cr�tico
Uc=Q/Ac;% velocidad en flujo cr�tico  (m/s)
Ec=yc+Uc^2/(2*9.8);% energ�a espec�fica en flujo cr�tico (m)
 
%% C�lculo tirante normal
if S<=0
    yn=inf;% si la pendiente es negativa o cero el tirante normal se supone infinito, para los otros casos se calcula a continuaci�n
else
    yn=(Q*n/(b*S^0.5))^(3/5);% estimaci�n inicial del tirante normal suponiendo canal rectangular muy ancho b>>yn ancho (m)
    par=[Q b S n];% vector con par�metros 
    yn=fsolve(@(y) manning_rect(y,par), yn);% tirante normal (m)

    [Bn,An,Pn,Rn,yGn,Dn]=rect_geom(yn,b);% c�lculo de par�metros geom�tricos asociados a las condiciones de flujo normal
    Un=Q/An;% velocidad en flujo normal (m/s)
    En=yn+Un^2/(2*9.8);% energ�a espec�fica en flujo normal (m)
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
% x crece desde aguas arriba hacia aguas abajo, es decir en la direcci�n del flujo
 
% Resoluci�n de la curva de FGV
par=[Q b S n yc];% vector con par�metros 
options = odeset('Events',@(x,y) critico(x,y,par));% par�metros auxiliares de configuraci�n para la funci�n ode23 para detener la resoluci�n de la ecuaci�n diferencial cuando se llega al tirante cr�tico
[x,y]=ode23(@(x,y) rect(x,y,par),[x_ini,x_end],y_ini,options);% x es el vector con las x donde se calcularon los valores de y
    
y_end=y(end);% y (tirante) final correspondiente a x_end (m)
%% Gr�fico
lw=4;% espesor de l�nea en los gr�ficos
fs=15;% tama�o de letra en los gr�ficos

figure(1)
clf
% Define posici�n y tama�o de la figura en funci�n del tama�o de la pantalla
scrsz = get(0,'ScreenSize');
set(gcf,'Position',[scrsz(3)*0.005 scrsz(4)*0.395 scrsz(3)*0.99 scrsz(4)/2])

% Grafica fondo, superficie libre y tirantes cr�tico y normal
p1=plot([x(1), x(end)],-[x(1), x(end)]*S,'-k','LineWidth',lw);%zb cota del fondo del canal
hold on
p2=plot(x,y-x*S,'-b','LineWidth',lw);%zw cota de la superficie libre
p3=plot([x(1), x(end)],[yc-x(1)*S, yc-x(end)*S],'--r','LineWidth',lw);%zc cota de la superficie libre en flujo cr�tico
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

%% Ejemplo de c�lculos adicionales
% [E_end,yalt]=Eesp_rect(y_end,b,Q);
% [B,A,P,R,yG,D]=rect_geom(y,b);
% Sf=(Q*n./R.^(2/3)./A).^2;
% tau=9800*R.*Sf;
% [M,yconj]=Mom_rect(0.7928,b,Q);

% figure(2)
% clf
% % Define posici�n y tama�o de la figura en funci�n del tama�o de la pantalla
% scrsz = get(0,'ScreenSize');
% set(gcf,'Position',[scrsz(3)*0.005 scrsz(4)*0.395 scrsz(3)*0.99 scrsz(4)/2])
% 
% % Grafica tirnate
% p1=plot(x,y,'-k','LineWidth',lw);%zb cota del fondo del canal


