clear;



fid = fopen('test_data.dat','w');
for i = 1:size(r,1)
    for j = 1:size(r,2)
        fprintf(fid,'%d  %d  ',real(r(i,j)), imag(r(i,j)));
    end
    fprintf(fid,'\n');
end
fclose(fid);



