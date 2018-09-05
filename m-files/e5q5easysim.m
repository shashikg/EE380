% e5q5easysim.m: Simulates digital control of continuous-
% time system without needing Matlab's Control System
% Toolbox. Uses only Euler's approximation. Runs in 
% Matlab and GNU Octave. User needs to convert plant
% and controller TFs to SS.  
%
% PRECONDITIONS: Tp < Tc/10; Tc < Tmin/10. Here, Tmin
% is the smallest time constant of the CL system. 
%-------------------------------------------------------------

clc; clear all; close all;

% ------------ Begin declarations ----------------------------


Rs = 28.711; B = 4.15e-6; Kt = 25.5e-3; Kb = 25.5e-3;
J = 1.34e-6;  

% Controller will sample plant states every Tc seconds  
Tc = 0.002;
% We will control the plant for tcfin seconds
tcfin = 5; 

% Step size Tp used for numerical integration of plant 
% differential equation using Euler's approximation.
Tp = 0.0001;
% We will numerically integrate plant differential
% equation for Tc seconds.   

% ------ Choose a controller from the following -----------------

%Kp = 20; Ki = 0;               % P controller.
%Kp = 250; Ki = 0;              % Even more P.
%Kp = 250; Ki = 100;            % P, and some I. 
%Kp = 20; Ki = 100;             % Less P, more I.
%Kp = 20; Ki = 500;             % P, even more I.
%Kp = 20; Ki = 1500;            % P, a lot more I.
Kp = 0; Ki = 1500;             % Pure I.
%
% Controller TF is C(s) = (Kp*s+Ki)/s
%
% State-space model of controller is 
%
% xcdot = uc;
% yc = Ki*xc + Kp*uc;
%
% The suffix ``c'' represents controller, ``p'' represents plant.

% -------- Declarations complete ---- Start simulation ----------


% Continuous-time plant discrete-time controller

% -------------------------- Initializations --------------------

id1 = 0.0486; id2 = 0.148;
id = id1;     % Desired armature current in A.
i1 = 0;       % Current due to voltage up.
i2 = 0;       % Current due to TL.
xp = 0;       % State of up-to-i1 TF.
ip = 0;       % Motor current. This variable is used only to
	      % make this file similar to easysim.m. 
xc = 0;       % State of controller. 
yc = 0;       % Output of controller.
uc = 0;       % Input to controller.

% TLvect = [zeros(1,tcfin/Tc/2), 0.003*ones(1,tcfin/Tc/2)];
% TLvect = 0.003*ones(1,tcfin/Tc);
 TLvect = zeros(1,tcfin/Tc);

K1 = B/(Rs*B+Kb*Kt); K2 = Kb/(Rs*B+Kb*Kt);
w1 = B/J; w2 = (Rs*B+Kb*Kt)/(Rs*J);

% ----------------------- Initialization complete ---------------

for k = 1:tcfin/Tc
   uc(k) = id - ip(k);           % Error.
   yc(k) = Ki*xc(k) + Kp*uc(k);  % Controller output.
 xc(k+1) = xc(k) + uc(k)*Tc;     % Update equation.
 % Hold last sample of controller output:
 up = yc(k);
 TL = TLvect(k);
 % Numerically integrate the plant equation holding the controller
 % output as the input to the plant: 
 for i = 1:Tc/Tp
  i1 = K1*w2/w1*up + (1-w2/w1)*xp;
  ia = i1 + i2;
  % Update equations:
  xp =  (1-Tp*w2)*xp + Tp*K1*w2*up;
  i2 = (1-Tp*w2)*i2 + Tp*K2*w2*TL;
 end
 ip(k+1) = ia;
end

t = (0:tcfin/Tc)*Tc;

subplot(3,1,1), plot(t,id - ip(1:size(t,2)),"linewidth",5), 
ylabel('Tracking error id - i [A]'); grid(gca,'minor');

subplot(3,1,2), plot(t,ip(1:size(t,2)),"linewidth",5), 
ylabel('Current [A]'); grid(gca,'minor');

subplot(3,1,3), plot(t(1:size(yc,2)),yc,"linewidth",5), 
ylabel('Control effort u [V]'); xlabel('t [s]'); grid(gca,'minor');

print -djpg q5easysim.jpg