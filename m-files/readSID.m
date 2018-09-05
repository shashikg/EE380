% readSID.m: Is an amalgam of readplot.m and sysid.m
%
% INPUT: Data of u and w obtained from the plant used in
% experiments 1 and 2. 
%
% OUTPUT: Two sets of values of {K, a, b} for the TF 
% K/(s^2 + as + b). The first set is using the data of u and
% w; the second set is using the data of u and filtered w. 
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 

clear all, close all, clc


% ---------------------- Step 1 ----------------------------
% ------------ This part is from readplot.m ----------------

x = dlmread('../log-files/rect4fg5.log');
%x = dlmread('../log-files/tri4fg5.log');
%x = dlmread('../log-files/tri8fg5.log');

% Determine the number of rows and columns of x. 
% If all went well, the number of rows will be equal to 1.
[rows,cols] = size(x);

% Truncate x so that x has an even number of columns.
if cols/2 > floor(cols/2)
  x = x(:,1:cols-1);
  cols = cols-1;
end

% Extract columns number 1, 3, 5, ... into a vector w,
% and columns number 2, 4, 6, ... into a vector u.
w = x(1,1:2:cols-1); % This is the vector of speeds
u = x(1,2:2:cols)/100;   % This is the vector of voltages.

% Calculate times at which to plot speed and voltage.
Tp = 0.002;   t = 0:Tp:Tp*(cols/2-1);


% ---------------------- Step 2 ----------------------------
% ------------- This part is from sysid.m ------------------

% We now have a set of input-output data from the plant. We
% use this data to perform system identification. 

y = w; u = u;
k = 3;
for n =1:cols/2-3
  Y(n,1) = (2/Tp)^2 * (y(k) - 2*y(k-1) + y(k-2));
  P(n,:) = [( u(k) + 2*u(k-1) + u(k-2)) ...
            (-2/Tp*( y(k)-y(k-2) ) ) -( y(k)+2*y(k-1)+y(k-2) )];
  k = k+1;
end

X = (P' * P)^(-1) * P' * Y;           % X = [K a b]'

[y1,t1] = step(tf(X(1,:),[1,X(2,:),X(3,:)]));


% ---------------------- Step 3 ----------------------------
% Redo the system identification on a low-pass filtered 
% version of w. 
% This step was added based on Kumar Saurav's observation 
% that the identification is significantly affected by the
% noise in the signal of motor speed.

om = 25; x(1) = 0;
for k = 1:cols/2
 x(k+1) = (1-om*Tp)*x(k) + om*Tp*w(k);
end

w = x(1:cols/2); % Filtered w.

% Use data of u and filtered w to do system identification.

y = w; u = u;
k = 3;
for n =1:cols/2-3
  Y(n,1) = (2/Tp)^2 * (y(k) - 2*y(k-1) + y(k-2));
  P(n,:) = [( u(k) + 2*u(k-1) + u(k-2)) ...
            (-2/Tp*( y(k)-y(k-2) ) ) -( y(k)+2*y(k-1)+y(k-2) )];
  k = k+1;
end

X = (P' * P)^(-1) * P' * Y;           % X = [K a b]'

[y2,t2] = step(tf(X(1,:),[1,X(2,:),X(3,:)]));

[y3,t3] = step(tf(39.3,[0.056,1]));

plot(t1,y1,'r',t2,y2,t3,y3,'g'); grid(gca,'minor');

legend('Step response of TF using u and w', ...
'Step response of TF using u and filtered w',...
'Step response of TF identified in Exp-t 1'); 
