% sysid.m: Implements least squares system identification. The
% method is taken from Gene F. Franklin, J. David Powell, and
% Michael L. Workman. Digital Control of Dynamic Systems.
% Addison-Wesley, 3 edition, 1998, pages 503 -- 505.   
%
% Uses only Euler's approximation. User needs to convert plant TF
% to SS. Works in GNU Octave as well as MATLAB. 
%
% PRECONDITIONS: Tc < Tmin/10. Here, Tmin is the smallest time
% constant of the CL system, and Tc is the period at which the uC
% samples the plant states. In the lab manual Tc is denoted Ts. 
%----------------------------------------------------------------

clc; clear all; close all;

% ------------ Begin declarations -------------------------------

% Plant transfer function K/(s^2 + a*s + b)
% Parameter vector X = [K a b]’

% K=487e2; a=14.7+1e2; b=14.7e2;
K = 500; a = 25; b = 50;
% State space model of plant is 
%
% x1pdot = x2p;
% x2pdot = -b*x1p -a*x2p + up;
% yp = K*x1p;
%
% The suffix ``p'' represents plant, and the suffix ``c''
% represents controller.

% The plant states are sampled every Tc seconds  
Tc = 0.01;
% We control the plant in open-loop for tcfin seconds
tcfin = 5; 

%------ Declarations complete ---- Start simulation -------------

% Triangular control input
t = (1:tcfin/Tc)*Tc;
[Rt Ct] = size(t);
uc(1) = 0;
sgn = 1;
for i = 2:Ct
  uc(i) = uc(i-1) + sgn*0.5;
  if(uc(i)> 9.0)
    sgn = -1;
  elseif( uc(i) < -9 )
    sgn = 1;
  end
end
 
% Initialize
yp(1) = 0;   % Initial actual speed.
x1p(1) = 0; x2p(1) = 0;  % Initial state of the plant.

% Recursion
for i = 1:tcfin/Tc
 x1p(i+1) = x1p(i) + x2p(i)*Tc;
 x2p(i+1) = -b*Tc*x1p(i) + (1-a*Tc)*x2p(i) + Tc*uc(i);
 yp(i) = K*x1p(i);
end

% Plot
plot(t,uc,t,yp); grid; legend('Control input','Actual speed');
print -depsc sysid.eps

% We now have a set of input-output data from the plant. We use
% this data to perform system identification 

y = yp; u = uc;
k = 3;
for n =1:Ct-3
  Y(n,1) = (2/Tc)^2 * (y(k) - 2*y(k-1) + y(k-2));
  P(n,:) = [( u(k) + 2*u(k-1) + u(k-2)) ...
            (-2/Tc*( y(k)-y(k-2) ) ) -( y(k)+2*y(k-1)+y(k-2) )];
  k = k+1;
end

X = (P' * P)^(-1) * P' * Y           % X = [K a b]'