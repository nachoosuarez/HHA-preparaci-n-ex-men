clear all
close all
clc

Dimp=0.15; %% diametro interno impulsion(m)
Dsuc=0.15; %% diametro interno succion(m)
Ksuc=1;    %% Perdidas succion
Kimp=5;    %% Perdidas impulsion
Limp=600;  %% Largo impulsion
Lsuc=15;    %% Largo hasta bomba
rugimp=0.00005;   %% Rugosidad impulsion(m)
rugsuc=0.00005;   %% Rugosidad succion(m)
ha=-4;     %% Altura tanque inferior 
hb=30;     %% Altura tanque superior
hbom=0;    %% Altura de la bomba

%Curva de la bomba
Qbomba1=[0.00 0.01 0.02 0.03 0.04 0.05 0.06 0.07]/1000;
Hbomba1=[65.0 64.0 60.0 54.0 48.0 41.0 31.0 18.0];
NPSHreq1=[3.2 3.4 3.7 4.4 5.3 6.8 8.5 10.8];
Ef1=[0 35 56 68 67 60 46 26]; %Eficiencia de la bomba 1



%Determinar caudal que circula
%% Curva de instalación
Q=Qbomba1; %%en m3/s %DEPENDE DEL VECTOR DE Q, CORREGIRLO SEGUN LA  CURVA DE LA BOMBA
Hm=Q*0;
viscagua=10^-6;
Aimp=(Dimp^2)*pi/(4);
Asuc=(Dsuc^2)*pi/(4);
Dhimp=Dimp;
Dhsuc=Dsuc;
Reimp=(Q/Aimp)*(Dhimp)/viscagua;
Resuc=(Q/Asuc)*(Dhsuc)/viscagua;
lQ=length(Q);
lH=length(Hbomba1);
lNPSH=length(NPSHreq1);
ln=length(Ef1);
epsimp=rugimp/Dimp;
epssuc=rugsuc/Dsuc;

%calculo de perdida de carga
for i=1:lQ
  
    Hm(i)=(hb-ha)+((Kimp+Limp*colebrook(Reimp(i),epsimp)/Dimp)*((Q(i)/Aimp)^2)+(Ksuc+Lsuc*colebrook(Resuc(i),epssuc)/Dsuc)*((Q(i)/Asuc)^2))/(2*9.8);
  
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
legend('curva instalacion','bomba1','efbomba')
hold off

     %%% NPSH 

NPSHdisp1=Q*0
for i=1:lQ
    NPSHdisp1(i)=-(hbom-ha)-((Ksuc+Lsuc*colebrook(Resuc(i),epssuc)/Dsuc)*((Q(i)/Asuc)^2))/(2*9.8)+10.33-0.32;
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
hold off

fact_fric_imp=colebrook((0.0464/Aimp)*(Dhimp)/viscagua,epsimp) %CAMBIAR Q

fact_fric_suc=colebrook((0.0464/Asuc)*(Dhsuc)/viscagua,epssuc) %CAMBIAR Q