% easysim.m: Simulates digital control of continuous-time system
% without needing Matlab's Control System Toolbox. Uses only
% Euler's approximation. Runs in Matlab and GNU Octave. User
% needs to convert plant and controller TFs to SS.   
%
% PRECONDITIONS: Tp < Tc/10; Tc < Tmin/10. Here, Tmin is the
% smallest time constant of the CL system.  
%-------------------------------------------------------------

clc; clear all; close all;

% ------------ Begin declarations ----------------------------

% Plant transfer function K/(s+w)
K = 100; w = 1;
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


%------ Declarations complete ---- Start simulation --------


% Continuous-time plant discrete-time controller

sd = 100;    % Desired motor speed in rad/sec. 
sa(1) = 0;   % Initial actual speed (sa = yp).
xc(1) = 0;   % Initial state of controller. 
yc(1) = 0;   % Intial output of controller.
xp(1) = 0;   % Initial state of plant.
for k = 1:tcfin/Tc
  uc(k) = sd - sa(k);
  xc(k+1) = uc(k)*Tc + xc(k);
  yc(k) = Kp*uc(k) + Ki*xc(k);
  % Hold last sample of controller output:
  up = yc(k); 
  % Numerically integrate plant equation holding the last
  % controller output as the input to the plant.
  for i = 1:Tc/Tp-1
    xp = (1-Tp*w)*xp + Tp*up;
    % This is the equation
    % xp(k+1) = (1-Tp*w)*xp(k) + Tp*up;
  end
  yp(k) = K*xp;
  sa(k+1) = yp(k);
end

t = (0:tcfin/Tc)*Tc;
plot(t,sa); grid(gca,'minor');
print -depsc Tc0-0001.eps