clc;
clear all;

image = imread('C:\Users\zhang\iverilog_testbench\file_io\lena_32.jpg' );
data=image(:);

%打开要写入的txt
fid = fopen('C:\Users\zhang\iverilog_testbench\file_io\5.txt','wt');

for i=1:length(data)
	fprintf(fid,'%x\n',data(i));
end

fclose(fid);


clc;
clear all;
fid = fopen('C:\Users\zhang\iverilog_testbench\file_io\1.txt');
s = fscanf(fid,'%x',[32 32]);

y = (s >= 135);
y(1,:)=0;
y(:,1)=0;
y(:,32)=0;
y(32,:)=0;
imshow(y)
[r,c]=bwlabel(y,8);
c