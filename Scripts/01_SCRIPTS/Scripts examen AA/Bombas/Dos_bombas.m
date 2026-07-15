enserie=0; % si estan en serie poner 1, si estan en paralelo poner 0
Dimp=0.2; % diametro interno impulsion(m)
Dsuc=0.2; % diametro interno succion(m)
Ksuc=2.3;    % Perdidas succion
Kimp=1.3;    % Perdidas impulsion
Limp=480;  % Largo impulsion
Lsuc=20;    % Largo hasta bomba
rugimp=1.5e-4;   % Rugosidad impulsion(m)
rugsuc=1.5e-4;   % Rugosidad succion(m)
ha=0;     % Altura tanque inferior VER TEMA DE QUE LA ALTURA VARIA!!!
hb=20;     % Altura tanque superior
hbom=3;    % Altura de la bomba

%Curva de la bomba
Qbomba1=[0.1,7.8,16.2,24.0,31.8,40.2,48.0,55.8]/1000;
Hbomba1=[36.3,35.7,34.5,32.7,30.3,26.6,22.4,16.9];
NPSHreq1=[1.6,1.8,2.2,2.8,3.9,5.5,7.3,9.7];
Ef1=[2,36,59,73,77,72,59,36]; %Eficiencia de la bomba 1

%Curva de la bomba
Qbomba2=[0.1,7.8,16.2,24.0,31.8,40.2,48.0,55.8]/1000;
Hbomba2=[36.3,35.7,34.5,32.7,30.3,26.6,22.4,16.9];
NPSHreq2=[0.7,0.9,1.3,1.9,3.0,4.6,6.4,8.8];
Ef2=[5,41,63,76,83,84,76,54]; %Eficiencia de la bomba 1
              %%%% BOMBA EQUIVALENTE

if enserie==1
Qeqbomba=Qbomba1; %Si estan en serie el caudal es el mismo
Heqbomba=Hbomba1+Hbomba2; %si estan en serie se suman als cargas

else
Qeqbomba=Qbomba1+Qbomba2; %Si estan en paralelo el caudal se suman 
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
plot(Qeqbomba,Heqbomba)
hold on
plot(Qbomba1,Ef1)
hold on
plot(Qbomba2,Ef2)
title('Curvas de instalación y bomba')
xlabel('Caudal(m^3/s)')
ylabel('Carga(m)')
legend('Curva instalacion','Bomba.1','Bomba.2','Bomba.eq','Eficiencia.1','Eficiencia.2')
hold off

     %%% NPSH 

NPSHdisp1=Q*0
for i=1:lQ
    NPSHdisp1(i)=-(hbom-ha)-((Ksuc+Lsuc*colebrook(Resuc(i),epssuc)/Dsuc)*((Q(i)/Asuc)^2))/(2*9.8)+10.33-0.32;
end 

if enserie==1
NPSHdisp2=NPSHdisp1+Hbomba1;

%FIGURAS PARA VER SI HAY CAVITACION
figure (2)
plot(Qbomba1,NPSHdisp1)
hold on
plot(Qbomba1,NPSHreq1)
title('Curvas de NPSH en funcion del caudal bomba 1')
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

figure (4)
grid on
plot(Q,Ef1)
hold on
plot(Qbomba1,Ef1)
hold on
plot(Qbomba2,Ef2)
title('Curvas de instalación y bomba')
xlabel('Caudal(m^3/s)')
ylabel('Carga(m)')
legend('Curva instalacion','Bomba.1','Bomba.2','Bomba.eq','Eficiencia.1','Eficiencia.2')
hold off
