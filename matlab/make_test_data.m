clear;
Nb = 12; % number of bits in input word
N=2^14;  % number of samples

cr=2*pi/N; 
w=(-N/2:N/2-1)*cr; 
ph=cumsum(w); 
s=exp(j*ph);
scale = (2^(Nb-1))-1;
s2=round(scale*s);

fid = fopen('test_data.dat','w');
for i = 1:size(s,2)
    fprintf(fid,'%d  %d \n',real(s2(i)), imag(s2(i)));
end
fclose(fid);



