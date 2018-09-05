% simsine.m: Simulates the response to a sine reference input
% under the digital control of continuous-time system. Uses only
% Euler's approximation. Runs in GNU Octave. 
%
% PRECONDITIONS: (1) User needs to convert plant and controller
% TFs to SS. (2) Tp < Ts/10; Ts < Tmin/10. Here, Tmin is the
% smallest time constant of the CL system, Tp is the step size of
% numerical integration of the plant dynamics, and Ts is the step
% size of the numerical integration of the closed-loop system
% dynamics and equals the chosen sampling interval.  
%----------------------------------------------------------------

clc; clear all; close all;

% ------------------ Declarations -------------------------------
% Plant transfer function Kp/(s/wp+1)
Kp = 39.3; wp = 1/0.056;
% Using tf2ss in Octave 3.2.4
[ap,bp,cp,dp] = tf2ss(Kp,[1/wp,1]);
% This line to be changed appropriately for Octave >= 3.6.0. 

% State space model of plant is
%
% xpdot = ap*xp + bp*up;
%    yp = cp*xp + dp*up;
%
% The suffix ``p'' represents plant.

% Controller samples plant states every Ts seconds
Ts = 0.002;

% The plant is controlled in closed-loop for tsfin seconds
tsfin = 20;

% Step size Tp used for numerical integration of plant
% differential equation using Euler's approximation.
Tp = 0.00001;
% We numerically integrate plant differential equation for 
% Ts seconds using a step size of Tp. 

% Controller TF is 
%
%       (s/z + 1)
%  Kc * ---------
%       (s/p + 1)

Kc = 50/39.3; p = 9.4248; z = 1/0.056;

% Controller state space equation
%
% xcdot = ac*xc + bc*uc;
%    yc = cc*xc + dc*uc;
%
% Using tf2ss in Octave 3.2.4:
[ac,bc,cc,dc] = tf2ss(Kc*[1/z,1],[1/p,1]);
% This line to be changed appropriately for Octave >= 3.6.0.
%
% The suffix ``c'' represents controller.

%---------------------------------------------------------------
% Simulate continuous-time plant discrete-time controller 
%---------------------------------------------------------------

% Specify the sampling instants
t =  (0:tsfin/Ts)*Ts;

% Desired motor speeds in rad/sec at sampling instants
sd = 150*sin(2*pi*1.5*t);

% Initial conditions
sa(1) = 0; % Initial actual speed (sa = yp).
xc(1) = 0; % Initial state of controller.
yc(1) = 0; % Intial output of controller.
xp(1) = 0; % Initial state of plant.

% Recursion
for k = 1:tsfin/Ts
 uc(k) = sd(k) - sa(k);
 xc(k+1) = (1+ac*Ts)*xc(k) + bc*Ts*uc(k);
 yc(k) = cc*xc(k) + dc*uc(k);
 % Hold last sample of controller output
 up = yc(k);
 % Numerically integrate plant equation holding
 % the input as last controller output:
 for i = 1:Ts/Tp-1
  xp = (1+Tp*ap)*xp + Tp*bp*up;
  yp = cp*xp + dp*up;
 end
 sa(k+1) = yp;
end

t = (0:tsfin/Ts)*Ts;
subplot(2,1,1); plot(t,sd, t,sa); grid(gca,'minor'); 
legend('reference','speed');
subplot(2,1,2); plot(t(:,1:size(yc,2)),yc); grid(gca,'minor'); 
legend('controller output');
print -depsc Ts0-0001.eps

% Determine the amplitudes of sa and yc after a transient.
max(sa(:,0.8*tsfin/Ts:tsfin/Ts)), 
max(yc(:,0.8*tsfin/Ts:tsfin/Ts))


% August 1, 2013

% Potential sources of errors:
% 1. The desired loop gain should have a slope of -20 dB/dec
% around crossover.
% 2. The sampling period needs to be around 5 - 10 times smaller
% than the smallest closed-loop time constant.