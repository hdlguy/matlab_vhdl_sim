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
sprintf('length of b2 = %d, gain of b2 = %d\n', length(b2), sum(b2))
figure(1);
freqz(b2/scale_factor);

% print out the quantized coefficients in Xilinx .coe format.
fid = fopen('halfband0.coe','w');
fprintf(fid,'Radix = 10;\n');
fprintf(fid,'CoefData =');
for i=1:length(b2)
    fprintf(fid,' %d', b2(i));
end
fprintf(fid,';\n');
fclose(fid);

