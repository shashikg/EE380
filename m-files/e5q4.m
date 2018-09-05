% e5q4.m: An m-file to help design a P or PI controller for Q2 of
% Experiment 5 through simulation combined with loop-shaping
% insights. The user does not need to go through the full
% loop-shaping procedure. 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clc; clear all, close all;

Rs=28.711; B=4.15e-6; Kt=25.5e-3; Kb=25.5e-3; J=1.34e-6;

K = B/(Rs*B+Kt*Kb); w1 = B/J; w2 = (Rs*B+Kt*Kb)/(Rs*J);
plant = tf(K*[1/w1,1],[1/w2,1]);

id1 = 0.0486;

% ------ Choose a controller from the following -----------------

%Kp = 20; Ki = 0;               % P controller.
%Kp = 250; Ki = 0;              % Even more P.
%Kp = 250; Ki = 100;            % P, and some I. 
%Kp = 20; Ki = 100;             % Less P, more I.
%Kp = 20; Ki = 500;             % P, even more I.
%Kp = 20; Ki = 1500;            % P, a lot more I.
%Kp = 0; Ki = 1500;             % Pure I.

con = tf([Kp,Ki],[1,0]);

% i(0+) from initial value theorem:
num = Kp*K*w2/w1; 
i0 = num/(1+num);
% Therefore, initial tracking error using initial value theorem:
id = 1; % The Octave function ``step'' uses a unit step.
e0 = id - i0;
% Scale this error by id1 to see the error that may be expected
% on the actual setup.
e0scaled = e0*id1

% ------------------- Simulate CL system ------------------------

tfin = 10;      % seconds.
OLsys = sysmult(con,plant);
[err,t2] = step(feedback(tf(1,1),OLsys),1,tfin,100);
[u,t2] = step(feedback(con,plant),1,tfin,100);
% u is the controller output (plant input).
[y,t1] = step(feedback(sysmult(con,plant),tf(1,1)),1,tfin,100); 
% y is the motor armature current.

% -------------- Plot quantities scaled by id1 ------------------

subplot(3,1,1), plot(t2,err*id1), 
ylabel('tracking error e = id - i [A]'); 
grid(gca,'minor');

subplot(3,1,2), plot(t2,u*id1), 
ylabel('control effort u [V]'); grid(gca,'minor');

subplot(3,1,3), plot(t1,y*id1),
ylabel('current [A]'); xlabel('t [s]'); grid(gca,'minor');

% ------------------------ Questions ----------------------------
%
% 1) For each of the PI controllers listed above, is the initial
% tracking error e0, calculated from the initial value theorem,
% the same as what the plot of e vs. t shows? 
%
% 2) In tracking 0.0486 A, the initial error would be 0.0486 - 0
% = 0.0486 A, and the control effort with K_P = 20 would be
% 20*0.0486 = 0.972 V. Yet, the simulation shows the initial
% error as 0.0287 A and the control effort as 0.55 V. Is this an
% error?  
%
% ---------------------------------------------------------------