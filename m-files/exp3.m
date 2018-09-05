clear all;
clc all;
close all;
pkg load control;
pkg load signal;
s = tf('s');
G = 39.3/(0.056*s+1);
H = 29/(s*s+10*s+29);
K = 0.25866;
Gc = feedback(K*H*G);
Go = G*H;
%rlocus(Go);
%hold on
%[rldata, k_break, rlpol, gvec] = rlocus(Go, 0.005, 0, 0.3);
%step(Gc)

Kcr = 0.25932;
Pcr = 0.44;

%P Controller
Cp = 0.5*Kcr
Gp = feedback(Cp*H*G);

%PI
Cpi = 0.45*Kcr*(1 + 1.2/(Pcr*s))
Gpi = feedback(Cpi*H*G);

%PID
Cpid = 0.6*Kcr*(1 + 2/(Pcr*s) + (0.125*Pcr*s)/(0.15*0.125*Pcr*s + 1))
Gpid = feedback(Cpid*H*G);


