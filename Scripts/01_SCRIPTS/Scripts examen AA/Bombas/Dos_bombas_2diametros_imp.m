
enserie=1 % si estan en serie poner 1, si estan en paralelo poner 0
Dimp1=0.4; % diametro interno impulsion1(m)
Dimp2=0.25; % diametro interno impulsion2(m)
Dsuc=0.4; % diametro interno succion(m)
Ksuc=0;    % Perdidas succion
Kimp1=0;    % Perdidas impulsion1
Kimp2=0;    % Perdidas impulsion2
Limp1=250;  % Largo impulsion1
Limp2=850;  % Largo impulsion2
Lsuc=30;    % Largo hasta bomba
rugimp1=0.12e-3;   % Rugosidad impulsion1(m)
rugimp2=0.075e-3;   % Rugosidad impulsion2(m)
rugsuc=0.12e-3;   % Rugosidad succion(m)
ha=-2;     % Altura tanque inferior VER TEMA DE QUE LA ALTURA VARIA!!!
hb=10;     % Altura tanque superior
hbom=2.5;    % Altura de la bomba

%Curva de la bomba
Qbomba1=[0,0.025,0.05,0.075,0.1,0.125,0.15,0.175];
Hbomba1=[39,12.7,12.2,11.2,10,8.5,7,3.5];
NPSHreq1=[3.2,3.5,4,5,6.5,8.5,11,14];
Ef1=[0,55,70,75,77,78,76,68]; %Eficiencia de la bomba 1

Qbomba2=[0,0.025,0.05,0.075,0.1,0.125,0.15,0.175];
Hbomba2=[17,16.4,15.5,14.5,13.2,11.8,10,7.5];
NPSHreq2=[3.5,3.7,4.4,5.5,6.8,8.8,11.2,13.3];
Ef2=[0,60,68,75,80,83,79,73]; %Eficiencia de la bomba 2

              %%%% BOMBA EQUIVALENTE

if enserie==1
Qeqbomba=Qbomba1; %Si estan en serie el caudal es el mismo
Heqbomba=Hbomba1+Hbomba2; %si estan en serie se suman als cargas

else
Qeqbomba=Qbomba1+Qbomba2; %Si estan en paralelo el caudal es el mismo
Heqbomba=Hbomba1; %si estan en paralelo las cargas son iguales 
end
                %%%%%%%%%%%%%%%%%%

%Determinar caudal que circula
%% Curva de instalación
Q=Qeqbomba; %%en m3/s %DEPENDE DEL VECTOR DE Q, CORREGIRLO SEGUN LA  CURVA DE LA BOMBA
Hm=Q*0;
viscagua=10^-6;
Aimp1=(Dimp1^2)*pi/(4);
Aimp2=(Dimp2^2)*pi/(4);
Asuc=(Dsuc^2)*pi/(4);
Dhimp1=Dimp1;
Dhimp2=Dimp2;
Dhsuc=Dsuc;
Reimp1=(Q/Aimp1)*(Dhimp1)/viscagua;
Reimp2=(Q/Aimp2)*(Dhimp2)/viscagua;
Resuc=(Q/Asuc)*(Dhsuc)/viscagua;
lQ=length(Q);
epsimp1=rugimp1/Dimp1;
epsimp2=rugimp2/Dimp2;
epssuc=rugsuc/Dsuc;

%calculo de perdida de carga
for i=1:lQ
   Hm(i)=(hb-ha)+((Kimp1+Limp1*colebrook(Reimp1(i),epsimp1)/Dimp1)*((Q(i)/Aimp1)^2)+(Kimp2+Limp2*colebrook(Reimp2(i),epsimp2)/Dimp2)*((Q(i)/Aimp2)^2)+(Ksuc+Lsuc*colebrook(Resuc(i),epssuc)/Dsuc)*((Q(i)/Asuc)^2))/(2*9.8);
end


figure (1)
plot(Q,Hm)
hold on
plot(Qbomba1,Hbomba1)
hold on
plot(Qbomba2,Hbomba2)
hold on
plot(Qeqbomba,Heqbomba)
hold on
plot(Qbomba1,Ef1,'bk')
hold on
plot(Qbomba2,Ef2)
title('curvas de instalación y bomba')
xlabel('Caudal(m^3/s)')
ylabel('Carga(mca)')
legend('hinst','hb1','hb2','hbeq','ef1','ef2')
hold off

     %%% NPSH 

NPSHdisp1=Q*0
for i=1:lQ
    NPSHdisp1(i)=-(hbom-ha)-((Ksuc+Lsuc*colebrook(Resuc(i),epssuc)/Dsuc)*((Q(i)/Asuc)^2))/(2*9.8)+10.33-0.32; 
end 

if enserie=1
NPSHdisp2=NPSHdisp1+Hbomba1;

%FIGURAS PARA VER SI HAY CAVITACION
figure (2)
plot(Qbomba1,NPSHdisp1,'r--')
hold on
plot(Qbomba1,NPSHreq1,'b--')
title('curvas de NPSH en funcion del caudal bomba 1')
xlabel('Caudal(m^3/s)')
ylabel('NPSH')
hold off

figure(3)
plot(Qbomba2,NPSHdisp2,'r--')
hold on
plot(Qbomba2,NPSHreq2,'b--')
title('curvas de NPSH en funcion del caudal bomba 2')
xlabel('Caudal(m^3/s)')
ylabel('NPSH')
hold off
hold off


else
NPSHdisp2=NPSHdisp1;

%FIGURAS PARA VER SI HAY CAVITACION
figure (2)
plot(Qbomba1,NPSHdisp1,'r--')
hold on
plot(Qbomba1,NPSHreq1,'b--')
title('curvas de NPSH en funcion del caudal bomba 1')
xlabel('Caudal(m^3/s)')
ylabel('NPSH')
hold off

figure(3)
plot(Qbomba2,NPSHdisp2,'r--')
hold on
plot(Qbomba2,NPSHreq2,'b--')
title('curvas de NPSH en funcion del caudal bomba 2')
xlabel('Caudal(m^3/s)')
ylabel('NPSH')
hold off

end

