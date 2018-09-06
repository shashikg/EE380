clc; clear all; close all;
J = 13e-7; Bs = 4.1101e-6; Rs = 28.2002; Kt = 25.5e-3; Kb = 0.0209;

% Define your system
Num = [J Bs]
Den = [J*Rs (Bs*Rs+Kt*Kb)]
Num = [Kt]
Den = [J Bs]
C = tf(Num, Den)
[A B C D] = tf2ss(Num, Den)
syms Ts;
[m n] = size(A);
Ad = eye(m) + A.*Ts
Bd = B.*Ts
Cd = C
Dd = D