clearvars
d=1;
Q=1;
y=[0:0.001:1];

[tt,B,A,P,R,yG,D]=circ_geom(y,d);

[tt0,B0,A0,P0,R0,yG0,D0]=circ_geom(d,d)

figure(2)
plot(A/A0,y,'r',P/P0,y,'b',R/R0,y,'g',yG/yG0,y,'y',B(1:end)/d,y,'m',D(1:end-8)/d,y(1:end-8),'k',R.^(2/3).*A/(R0^(2/3)*A0),y,'c',A(1:end-7).^2.*D(1:end-7)/(A0^2*d),y(1:end-7),'k--')
set(gca,'XLim',[0 1.5])
grid on
% % figure(2)
% % plot(B(1:end)/d,y,'r',D(1:end-7)/d,y(1:end-7),'b')
% 
% Fr2=(Q^2)*B./(9.8*A.^3);
% figure(2)
% plot(Fr2(20:end),y(20:end),'r')