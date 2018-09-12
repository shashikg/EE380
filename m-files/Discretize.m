clc; clear all; close all;
J = 13e-7; Bs = 4.1101e-6; Rs = 28.2002; Kt = 25.5e-3; Kb = 0.0209;

% Define your system
Num = [50/40.8*0.06 50/40.8]
Den = [5 1]
%Num = [1.27/17.6991 1.27]
%Den = [5 1]
C = tf(Num, Den)
[A B C D] = tf2ss(Num, Den)
syms Ts;
[m n] = size(A);
Ad = eye(m) + A.*Ts
Bd = B.*Ts
Cd = C
Dd = D