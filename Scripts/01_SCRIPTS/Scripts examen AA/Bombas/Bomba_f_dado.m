clear all
close all
clc

Dimp=0.102; %% diametro interno impulsion(m)
Dsuc=0.102; %% diametro interno succion(m)
Ksuc=1.2;    %% Perdidas succion
Kimp=2.4;    %% Perdidas impulsion
Limp=81;  %% Largo impulsion
Lsuc=12;    %% Largo hasta bomba
fimp=0.02185;   %% f impulsion
fsuc=0.02185;   %% f succion
ha=-7.9;     %% Altura tanque inferior VER TEMA DE QUE LA ALTURA VARIA!!!
hb=10;     %% Altura tanque superior
hbom=0;    %% Altura de la bomba

%Curva de la bomba
Qbomba1=[0,12.5,18.055555556,20.8333333333,23.6111111111,29.1666666667,31.944444444]/1000;
Hbomba1=[22,21,20,19,18,15,13];
NPSHreq1=[1.4,1.6,2,2.5,2.8,3.75,4.5];
Ef1=[0,68,78,80,82,80,75]./10; %Eficiencia de la bomba 1



%Determinar caudal que circula
%% Curva de instalación
Q=Qbomba1; %%en m3/s %DEPENDE DEL VECTOR DE Q, CORREGIRLO SEGUN LA  CURVA DE LA BOMBA
Hm=Q*0;
viscagua=10^-6;
Aimp=(Dimp^2)*pi/(4);
Asuc=(Dsuc^2)*pi/(4);
Dhimp=Dimp;
Dhsuc=Dsuc;
lQ=length(Q);


%calculo de perdida de carga
for i=1:lQ
  
    Hm(i)=(hb-ha)+((Kimp+Limp*fimp/Dimp)*((Q(i)/Aimp)^2)+(Ksuc+Lsuc*fsuc/Dsuc)*((Q(i)/Asuc)^2))/(2*9.8);
  
end


figure (1)
plot(Q,Hm)
hold on
plot(Qbomba1,Hbomba1)
hold on
plot(Qbomba1,Ef1)
title('curvas de instalación y bomba')
xlabel('Caudal(m^3/s)')
ylabel('Carga(mca)')
legend('curva instalacion','bomba1','bomba2','bombaeq','eficiencia1','eficiencia2')
hold off

     %%% NPSH 

NPSHdisp1=Q*0
for i=1:lQ
    NPSHdisp1(i)=-(hbom-ha)-((Ksuc+Lsuc*fsuc/Dsuc)*((Q(i)/Asuc)^2))/(2*9.8)+10.33-0.32;
end 


%FIGURAS PARA VER SI HAY CAVITACION
figure (2)
plot(Qbomba1,NPSHdisp1)
hold on
plot(Qbomba1,NPSHreq1)
title('curvas de NPSH en funcion del caudal bomba 1')
xlabel('Caudal(m^3/s)')
ylabel('NPSH')
legend('NPSHdisp1','NPSHreq1')
hold off-