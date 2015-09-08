% This little script illustrates how to read the output of a vhdl
% simulation.  Data is just plotted.
clear;
res = load('../sim/filt_out.dat');

r = res(:,1) + j*res(:,2);
r = r(32:length(r)); % trim off the startup junk.

subplot(3,1,1);
plot(real(r),'b');
subplot(3,1,2);
plot(imag(r),'r');
subplot(3,1,3);
plot(20*log10(abs(r)),'m');


