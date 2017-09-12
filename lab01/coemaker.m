
fid = fopen('b.txt','wt');
fprintf(fid,'MEMORY_INITIALIZATION_RADIX=2;\nMEMORY_INITIALIZATION_VECTOR=\n');
    for i=1:1:256
            y=dec2hex(randi([0 15]));
            fprintf(fid,'%c',y);
            y=dec2hex(randi([0 15]));
            fprintf(fid,'%c',y);
            y=dec2hex(randi([0 15]));
            fprintf(fid,'%c',y);
            y=dec2hex(randi([0 15]));
            fprintf(fid,'%c',y);
            y=dec2hex(randi([0 15]));
            fprintf(fid,'%c',y);
            y=dec2hex(randi([0 15]));
            fprintf(fid,'%c',y);
            y=dec2hex(randi([0 15]));
            fprintf(fid,'%c',y);
            y=dec2hex(randi([0 15]));
            fprintf(fid,'%c\n',y);
    end
fclose(fid);