function [ B,u] = is_calc( I,B )
%is_calc updates the source matrix B with current sources
%   Input: B is the source matrix
%   Input: I is the current source matrix where each row represent a source
%   Output: the updated matrix B with current source positions
%   Ouput:  the source vecor u with the values of the current sources

is_size=size(I);
%initialize u
u=zeros([1 1]);

if is_size(1)~=0
%value of the current sources are read to u
u=I(:,3);
%resize the B matrix
B=zeros([size(B,1) size(I,1)]);
%node 0 refers to ground
for i=1:is_size(1)
    loc1=I(i,1);
    loc2=I(i,2);
    if loc1~=0
        B(i,loc1)=-1; 
    end
    if loc2~=0
        B(i,loc2)=1;
    end

end

end
end

