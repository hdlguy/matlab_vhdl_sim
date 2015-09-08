% Calculate the FIR filtr coefficients for a decimate-by-two halfband filter.
clear;
Nb=16; % number of bits in filter coefficients.
BWF = 0.5
Astop = 0.01;
N = 32;

b = fir1(N, BWF); 

% Normalize and quantize.
scale_factor = ((2^(Nb-1))-1)/max(abs(b));
b2 = b*scale_factor;

% Now let's scale the coeffs so they give good output range.
G=abs(sum(b2)); 
headroom = 0.9; 
Gscale = headroom*(2^floor(log2(G/headroom)))/G;
b3 = round(b2*Gscale);
sprintf('length of b3 = %d, gain of b3 = %d\n', length(b3), sum(b3))
figure(1);
freqz(b3/scale_factor);

% print out the quantized coefficients in Xilinx .coe format.
fid = fopen('halfband0.coe','w');
fprintf(fid,'Radix = 10;\n');
fprintf(fid,'CoefData =');
for i=1:length(b3)
    fprintf(fid,' %d', b3(i));
end
fprintf(fid,';\n');
fclose(fid);

