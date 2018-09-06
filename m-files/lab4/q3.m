% easysim.m: Simulates digital control of continuous-time system
% without needing Matlab's Control System Toolbox. Uses only
% Euler's approximation. Runs in Matlab and GNU Octave. User
% needs to convert plant and controller TFs to SS.   
%
% PRECONDITIONS: Tp < Tc/10; Tc < Tmin/10. Here, Tmin is the
% smallest time constant of the CL system.  
%-------------------------------------------------------------

clc; clear all; close all;
pkg load control
pkg load signal

% ------------ Begin declarations ----------------------------

% Plant transfer function K/(s+w)
K = 39.3*17.6991; w = 17.6991;
% State space model of plant is 
%
% xpdot = -w*xp + up;
% yp = K*xp;
%
% The suffix ``p'' represents plant.

% Controller will sample plant states every Tc seconds  
Tc = 0.01;
% We will control the plant for tcfin seconds
tcfin = 5; 

% Step size Tp used for numerical integration of plant 
% differential equation using Euler's approximation.
Tp = 0.00001;
% We will numerically integrate plant differential
% equation for Tc seconds.   

% Controller TF is Cs = (Kp*s+Ki)/s
Kp = 0.11;
Ki = 1.737;
% State-space model of controller is 
%
% xcdot = uc;
% yc = Ki*xc + Kp*uc;
%
% The suffix ``c'' represents controller.
a = 1 - 0.2*Tc; b = Tc;
c = 0.2516; d = 0.0144;

ai = 1 - 17.6992*Tp; bi = Tp;
ci = -0.5155; di = 0.0355;


%------ Declarations complete ---- Start simulation --------


% Continuous-time plant discrete-time controller

sd = 100;    % Desired motor speed in rad/sec. 
sa(1) = 0;   % Initial actual speed (sa = yp).
sahat(1) = 0;
xc(1) = 0;   % Initial state of controller. 
yc(1) = 0;   % Intial output of controller.
xp(1) = 0;   % Initial state of plant.
xphat(1) = 0;   % Initial state of plant.
for k = 1:tcfin/Tc
  uc(k) = sd - sahat(k);
  xc(k+1) = a*xc(k) + b*uc(k);
  yc(k) = c*xc(k) + d*uc(k);
  % Hold last sample of controller output:
  up = yc(k); 
  % Numerically integrate plant equation holding the last
  % controller output as the input to the plant.
  
  for i = 1:Tc/Tp-1
    xphat = ai*xphat + bi*up;
    xp = (1-Tp*w)*xp + Tp*up;
    % This is the equation
    %xp(k+1) = (1-Tp*w)*xp(k) + Tp*up;
  end
  ip(k) = ci*xphat + di*up;
  sahat(k+1) = (up - 28.2002*ip(k))/0.0209;
  yp(k) = K*xp;
  sa(k+1) = yp(k);
end

t = (0:tcfin/Tc)*Tc;
save ('q32.mat', 'sa', 't', 'yc', 'sahat')

plot(t, sa, t, sahat); grid(gca,'minor');
legend('w', ...
'w hat');
title('w and w hat for Current Control');
xlabel('t');
ylabel('w and w hat');
print('plots/Speed', '-dpdf')
%print -depsc Tc0-0001.eps