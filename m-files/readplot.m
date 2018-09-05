% readplot.m: Uses GNU Octave's or MATLAB's dlmread function to
% read the contents of the file testdata.txt into a vector. This
% file belongs to the lab manual for EE380 (control lab).
% 
% The file testdata.txt is generated as follows. The program
% terminal.exe writes the information that it receives from
% dsPIC30F4012 to the file testdata.txt. The program in
% dsPIC30F4012 sends this information as tab seperated ASCII
% values.  
% 
% We have tested that this m-file executes nicely in GNU Octave
% version 3.2.4 that comes packaged for Windows in 
% 
% http://sourceforge.net/projects/octave/files/
% Octave_Windows%20-%20MinGW/
% Octave%203.2.4%20for%20Windows%20MinGW32%20Installer/
% Octave-3.2.4_i686-pc-mingw32_gcc-4.4.0_setup.exe/download
%
% and MATLAB 7.7.0471 (R2008b) that we have in our CC. On MATLAB
% dlmread('testdata.txt') seems to be returning the last item in
% the vector as 0 even though it may be blank. GNU Octave does
% not have this problem. 
%
% The plots are generated nicely in MATLAB and the Linux version
% of GNU Octave.  The plotting program (most likely GNUPlot) in
% the windows version of GNU Octave does not seem to be properly
% integrated into GNU Octave. So, we have trouble displaying the
% results of plot on the screen. As a work around, we have used
% the command 
%
%   print -djpg plot.jpg
%
% to print the plots to jpeg files. 
%
% We found that this problem has been reported at 
%
% http://octave.1599824.n4.nabble.com/
% Gnuplot-freezes-in-Win7-3-2-4-td2279218.html#a2279218
%
% and a work-around has been suggested there and at
%
% http://old.nabble.com/
% Re:-Octave-3.2.4-mingw32-available-p28053703.html
%
% Using this work-around does remove this problem.
% 
% PRECONDITIONS: readplot.m and testdata.txt need to be in the
% same folder. All data in testdata.txt is tab-separated and in a
% single row, and no spaces lead the first item of the data. 
% 
% Date created on: September 12, 2010.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear all, close all, clc

%x = dlmread('../log-files/rect4fg5.log');
%x = dlmread('../log-files/tri4fg5.log');
x = dlmread('../log-files/tri8fg5.log');

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
T = 0.002; % sampling time
t = 0:T:T*(cols/2-1);

% Plot the speeds and the voltages with respect to time. 
subplot(2,1,1); plot(t,w); grid(gca,'minor');
title('Speed of the motor shaft in (rad/s)');
subplot(2,1,2); plot(t,u); grid(gca,'minor'); 
title('Voltage applied to motor in (V)');

print -djpg plots.jpg