clc; clear all; close all;

% Define your system
Num = [100];
Den = [1 1 1 1];
[A B C D] = tf2ss(Num, Den);
syms Ts;
[m n] = size(A);
Ad = eye(m) + A.*Ts
Bd = B.*Ts
Cd = C
Dd = D