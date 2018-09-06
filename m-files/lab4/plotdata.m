clc; clear all; close all;

load q31.mat;
sa1 = sa;
yc1 = yc;

load q32.mat;

plot(t(1:500), yc1, t(1:500), yc); grid(gca,'minor');
legend('control outputs for w', ...
'control outputs for w hat');
title('Control outputs in case of w and w hat');
xlabel('t');
ylabel('u and u hat');
print('plots/ControlOutputs', '-dpdf')

figure();
plot(t, sa1, t, sa); grid(gca,'minor');
legend('w', ...
'w hat');
title('w and w hat');
xlabel('t');
ylabel('w and w hat');
print('plots/Speed', '-dpdf')

figure();
plot(t, sa1); grid(gca,'minor');
title('w vs t');
xlabel('t');
ylabel('w');
print('plots/w', '-dpdf')

figure();
plot(t, sa); grid(gca,'minor');
title('w hat vs t');
xlabel('t');
ylabel('w hat');
print('plots/what', '-dpdf')