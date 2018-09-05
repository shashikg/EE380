clear all, close all, clc
[y,t] = step(tf(39.3,[0.056,1]));

plot(t,y); grid(gca,'minor');
hold on;
[y,t] = step(tf(1781.5,[1, 7.7,139.4]));

plot(t,y); grid(gca,'minor');
hold on;
[y,t] = step(tf(3733.8,[1, 13.6,148.7]));

plot(t,y); grid(gca,'minor');
hold on;
[y,t] = step(tf(1561.1,[1, 5.5,56.4]));

plot(t,y); grid(gca,'minor');
hold on;

legend('Exp1', ...
'Tri 4V',...
'Tri 8V',...
'Rect 4V'); 