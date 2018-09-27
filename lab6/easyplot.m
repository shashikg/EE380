% easyplot.m: Modification of readplot.m

clear all, close all, clc

% Change the path in the argument of dlmread to suit yourself.
x = dlmread('1.txt');

% Determine the number of rows and columns of x.
% If all went well, the number of rows will be equal to 1.
[rows,cols] = size(x);

% Truncate x so that x has an even number of columns.
if cols/2 > floor(cols/2)
  x = x(:,1:cols-1);
  cols = cols-1;
end

T = 0.002; % sampling time
t = 0:T:T*(cols/2-1);
w = x(1,1:2:cols-1); % This is the vector of speeds

% Filter speed with a LP filter of cutoff frequency Fcf to obtain
% filtered version wf (this filter is similar to current filter in
% main-prog.c):  
Fcf = 50;
wf(1) = w(1);
for k = 1:cols/2-1
 wf(k+1) = (Fcf*T/(2+Fcf*T))*( w(k+1)+w(k) )+((2-Fcf*T)/(2+Fcf*T))*wf(k);
end

% Without feedback of disturbance observer

% 1: Plot w and T_Lhat with DOB
TL = x(1,2:2:cols)/100000; % This is the vector of voltages.
subplot(2,1,1); plot(t,w); grid;
title('w (rad/s) with hat i_L fed back');
subplot(2,1,2); plot(t,TL); grid;
title('hat T_L (Nm) with hat i_L fed back');
print -djpg 1.jpg
figure
% Filtered version of the data plotted above
subplot(2,1,1); plot(t,wf); grid;
title('w (rad/s) with hat i_L fed back');
subplot(2,1,2); plot(t,TL*62/9.8/1.25e-2); grid;
title('hat m (kg) with hat i_L fed back');
print -djpg 1f.jpg

% 2: Plot w and u with DOB
% u = x(1,2:2:cols)/10; % This is the vector of voltages.
% subplot(2,1,1); plot(t,w); grid;
% title('w (rad/s) with hat i_L fed back');
% subplot(2,1,2); plot(t,u); grid;
% title(u (V) with hat i_L fed back');
% print -djpg 2.jpg
% figure
% Filtered version of the data plotted above
% subplot(2,1,1); plot(t,wf); grid;
% title('w (rad/s) with hat i_L fed back');
% subplot(2,1,2); plot(t,u); grid;
% title('u (V) with hat i_L fed back');
% print -djpg 2f.jpg

% 3: Plot w and T_Lhat without DOB
% TL = x(1,2:2:cols)/100000; % This is the vector of voltages.
% subplot(2,1,1); plot(t,w); grid;
% title('w (rad/s) without hat i_L fed back');
% subplot(2,1,2); plot(t,TL); grid;
% title('hat T_L (Nm) without hat i_L fed back');
% print -djpg 3.jpg
% figure
% Filtered version of the data plotted above
% subplot(2,1,1); plot(t,wf); grid;
% title('w (rad/s) without hat i_L fed back');
% subplot(2,1,2); plot(t,TL*62/9.8/1.25e-2); grid;
% title('hat m (kg) without hat i_L fed back');
% print -djpg 3f.jpg

% 4: Plot w and u without DOB
% u = x(1,2:2:cols)/10; % This is the vector of voltages.
% subplot(2,1,1); plot(t,w); grid;
% title('w (rad/s) without hat i_L fed back');
% subplot(2,1,2); plot(t,u); grid;
% title('u (V) without hat i_L fed back');
% print -djpg 4.jpg
% figure
% Filtered version of the data plotted above
% subplot(2,1,1); plot(t,wf); grid;
% title('w (rad/s) without hat i_L fed back');
% subplot(2,1,2); plot(t,u); grid;
% title('u (V) without hat i_L fed back');
% print -djpg 4f.jpg

