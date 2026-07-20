% ej1_racional_Tr.m — Examen 13/feb/2020, Ejercicio 1, Parte 1.
% Metodo Racional: dado Qdiseno=10 m3/s y tc=18min, hallar el periodo de
% retorno Tr de la obra. Formulometro "Eventos extremos - IDF" (B3/B4 del
% resumen teorico).
clear all
A = 1;            % area cuenca (km2) -> 100 ha
tc = 18/60;       % tiempo de concentracion (h) = 0.30 h
Qdiseno = 10;      % caudal de diseno (m3/s)

% Coeficiente de escorrentia C: tabla de Chow, pastizales pendiente
% media (2-7%), interpolado linealmente entre Tr=5 (C=0.36) y Tr=10 (C=0.38)
% (mismos valores de tabla usados en la solucion oficial manuscrita).
C_fun = @(Tr) 0.36 + (Tr-5)/5*0.02;

CD = @(d) (d<3).*(0.6208.*d./(d+0.0137).^0.5639) + (d>=3).*(1.0287.*d./(d+1.0293).^0.8083);
CT = @(Tr) 0.5786 - 0.4312.*log10(log(Tr./(Tr-1)));
CA = @(Ak,d) 1 - (0.3549.*d.^(-0.4272)).*(1-exp(-0.005792.*Ak));

d = tc;
cd_ = CD(d);
ca_ = CA(A,d);
printf('CD(tc=%.3fh) = %.4f   CA(A=1km2) = %.4f\n', d, cd_, ca_);

Q_of = @(Tr,P310) C_fun(Tr).*CT(Tr).*P310.*cd_.*ca_.*(A*100)/(360*d);

% Ajuste de P(3,10) para reproducir los puntos de la tabla manuscrita
for P310 = [82 88 90 92]
  printf('\nP(3,10)=%d mm:\n', P310);
  for Tr = [5 6 6.5 7.5]
    printf('  Tr=%.1f  C=%.3f  CT=%.4f  Q=%.2f m3/s\n', Tr, C_fun(Tr), CT(Tr), Q_of(Tr,P310));
  end
end

% Tr exacto para Q=10 con P310=90 (mejor ajuste)
P310 = 90;
Tr_exacto = fzero(@(Tr) Q_of(Tr,P310)-Qdiseno, 6);
printf('\nCon P(3,10)=90mm: Tr exacto para Q=10 m3/s -> Tr = %.2f anios\n', Tr_exacto);

P310 = 92;
Tr_exacto2 = fzero(@(Tr) Q_of(Tr,P310)-Qdiseno, 6);
printf('Con P(3,10)=92mm: Tr exacto para Q=10 m3/s -> Tr = %.2f anios\n', Tr_exacto2);
