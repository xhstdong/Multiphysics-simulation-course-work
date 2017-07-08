function [ b ] = is_calc( I, b )
%is_calc updates the source vector b with current sources
%   Input: b is the source vector of the circuit
%   Input: I is the current source matrix where each row represent a source
%   Output: the updated vector b with current sources

is_mat=zeros(size(b)); 

is_size=size(I);

%node 0 refers to ground
for i=1:is_size(1)
    is_temp=zeros(size(b));
    loc1=I(i,1);
    loc2=I(i,2);
    current=I(i,3);
    if loc1~=0
        is_temp(loc1)=-1*current;
    end
    if loc2~=0
        is_temp(loc2)=current;
    end
    is_mat=is_mat+is_temp;
end
b=b+is_mat;
end

