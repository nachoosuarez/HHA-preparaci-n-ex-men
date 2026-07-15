enserie=0; % si estan en serie poner 1, si estan en paralelo poner 0
Dimp=0.1; % diametro interno impulsion(m)
Dsuc=0.1; % diametro interno succion(m)
Ksuc=2;    % Perdidas succion
Kimp=5;    % Perdidas impulsion
Limp=20;  % Largo impulsion
Lsuc=7;    % Largo hasta bomba
rugimp=0.02e-3;   % Rugosidad impulsion(m)
rugsuc=0.02e-3;   % Rugosidad succion(m)
ha=-4.64;     % Altura tanque inferior VER TEMA DE QUE LA ALTURA VARIA!!!
hb=14;     % Altura tanque superior
hbom=1;    % Altura de la bomba

%Curva de la bomba
Qbomba1=[0,0.0015,0.003,0.0045,0.006,0.0075,0.009,0.0105];
Hbomba1=[26,25.7,25,23.3,21.5,19,16,11];
NPSHreq1=[1.3,1.6,2.1,2.8,3.6,4.5,5.5,6.6];
Ef1=[0,30,53,64,67,65,58,43]; %Eficiencia de la bomba 1

%Curva de la bomba
Qbomba2=[0,0.0015,0.003,0.0045,0.006,0.0075,0.009,0.0105];
Hbomba2=[26,25.7,25,23.3,21.5,19,16,11];
NPSHreq2=[1.3,1.6,2.1,2.8,3.6,4.5,5.5,6.6];
Ef2=[0,30,53,64,67,65,58,43]; %Eficiencia de la bomba 2

%Curva de la bomba
Qbomba3=[0,0.0015,0.003,0.0045,0.006,0.0075,0.009,0.0105];
Hbomba3=[26,25.7,25,23.3,21.5,19,16,11];
NPSHreq3=[1.3,1.6,2.1,2.8,3.6,4.5,5.5,6.6];
Ef3=[0,30,53,64,67,65,58,43]; %Eficiencia de la bomba 3

              %%%% BOMBA EQUIVALENTE

if enserie==1
Qeqbomba=Qbomba1; %Si estan en serie el caudal es el mismo
Heqbomba=Hbomba1+Hbomba2+Hbomba3; %si estan en serie se suman als cargas

else
Qeqbomba=Qbomba1+Qbomba2+Qbomba3; %Si estan en paralelo el caudal se suman 
Heqbomba=Hbomba1; %si estan en paralelo las cargas son iguales 
end
                %%%%%%%%%%%%%%%%%%


%Determinar caudal que circula
%% Curva de instalación
Q=Qeqbomba; %%en m3/s %DEPENDE DEL VECTOR DE Q, CORREGIRLO SEGUN LA  CURVA DE LA BOMBA
Hm=Q*0;
viscagua=10^-6;
Aimp=(Dimp^2)*pi/(4);
Asuc=(Dsuc^2)*pi/(4);
Dhimp=Dimp;
Dhsuc=Dsuc;
Reimp=(Q/Aimp)*(Dhimp)/viscagua;
Resuc=(Q/Asuc)*(Dhsuc)/viscagua;
lQ=length(Q);
epsimp=rugimp/Dimp;
epssuc=rugsuc/Dsuc;

%calculo de perdida de carga
for i=1:lQ
  
    Hm(i)=(hb-ha)+((Kimp+Limp*colebrook(Reimp(i),epsimp)/Dimp)*((Q(i)/Aimp)^2)+(Ksuc+Lsuc*colebrook(Resuc(i),epssuc)/Dsuc)*((Q(i)/Asuc)^2))/(2*9.8);
  
end


figure (1)
grid on
plot(Q,Hm)
hold on
plot(Qbomba1,Hbomba1)
hold on
plot(Qbomba2,Hbomba2)
hold on
plot(Qbomba3,Hbomba3)
hold on
plot(Qeqbomba,Heqbomba)
hold on
plot(Qbomba1,Ef1)
hold on
plot(Qbomba2,Ef2)
hold on
plot(Qbomba3,Ef3)
title('curvas de instalación y bomba')
xlabel('Caudal(m^3/s)')
ylabel('Carga(mca)')
legend('curva instalacion','bomba1','bomba2','bomba3','bombaeq','eficiencia1','eficiencia2','eficiencia3')
hold off

     %%% NPSH 

NPSHdisp1=Q*0
for i=1:lQ
    NPSHdisp1(i)=-(hbom-ha)-((Ksuc+Lsuc*colebrook(Resuc(i),epssuc)/Dsuc)*((Q(i)/Asuc)^2))/(2*9.8)+10.33-0.32;
end 

if enserie==1
NPSHdisp2=NPSHdisp1+Hbomba1;
NPSHdisp3=NPSHdisp2+Hbomba2;

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

figure(3)
plot(Qbomba2,NPSHdisp2)
hold on
plot(Qbomba2,NPSHreq2)
title('curvas de NPSH en funcion del caudal bomba 2')
xlabel('Caudal(m^3/s)')
ylabel('NPSH')
legend('NPSHdisp2','NPSHreq2')
hold off

figure(4)
plot(Qbomba3,NPSHdisp3)
hold on
plot(Qbomba3,NPSHreq3)
title('curvas de NPSH en funcion del caudal bomba 3')
xlabel('Caudal(m^3/s)')
ylabel('NPSH')
legend('NPSHdisp3','NPSHreq3')
hold off

else
NPSHdisp2=NPSHdisp1;

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

figure(3)
plot(Qbomba2,NPSHdisp2)
hold on
plot(Qbomba2,NPSHreq2)
title('curvas de NPSH en funcion del caudal bomba 2')
xlabel('Caudal(m^3/s)')
ylabel('NPSH')
legend('NPSHdisp2','NPSHreq2')
hold off

end

