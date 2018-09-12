clc; clear all; close all;

load q31.mat;
sa1 = sa;
yc1 = yc;

load q32.mat;

plot(t(1:500), yc1, t(1:500), yc); grid(gca,'minor');
legend('Speed Controlled', ...
'Current Controlled');
title('Control Outputs');
xlabel('t');
ylabel('u and u hat');
print('plots/ControlOutputs', '-dpdf')

figure();
plot(t, sa1); grid(gca,'minor');
title('w vs t Speed Control');
xlabel('t');
ylabel('w');
print('plots/w', '-dpdf')