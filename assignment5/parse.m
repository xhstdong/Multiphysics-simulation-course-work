function data=parse( file )
%PARSE read data from a file line by line
%   Input: file location as a string
%   Output: data in a size n cell array, where n is number of rows in file
%   If file is empty, PARSE will return -1 as data

fid=fopen(file, 'r');
index=1;
newline=fgetl(fid);
data={};
%keep reading new line until reaching EOF (-1)
 while newline~=-1
     data(index)=cellstr(newline);
     index=index+1;
     newline=fgetl(fid);
 end
fclose(fid);
display('data is parsed')

end

