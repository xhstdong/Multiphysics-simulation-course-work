function [ G ] = resistor_calc( R, G )
%Resistor calc updates the circuit matrix G with specified resistor info
%   Input: G is the circuit matrix
%   Input: R is the resistor matrix where each row represents a resistor
%   and contains its node connections and its resistance
%   Output: G is the updated circuit matrix with resistors

%initialize circuit grid
% node with no resistors remain 0
G_size=size(G);
%R_mat=zeros(G_size); 
R_mat=sparse(G_size(1),G_size(2));

R_size=size(R);
%iteratively apply resistance stamps
%node 0 refers to ground
for i=1:R_size(1)
    %R_temp=zeros(size(G));
    loc1=R(i,1);
    loc2=R(i,2);
    resistance=R(i,3);
    g=1/resistance;
    if loc1==0
        if loc2==0
            %do nothing since both ends are grounded
        else
            row=loc2;
            column=loc2;
            Rval=g;
            R_temp=sparse(row,column,Rval,G_size(1),G_size(2));
            %R_temp(loc2,loc2)=1/resistance
        end
    elseif loc2==0
            row=loc1;
            column=loc1;
            Rval=g;
            R_temp=sparse(row,column,Rval,G_size(1),G_size(2));
        %R_temp(loc1,loc1)=+1/resistance
    else
        row=[loc1, loc1, loc2, loc2];
        column=[loc1, loc2, loc1, loc2];
        Rval=[g,-1*g,-1*g,g];
        R_temp=sparse(row,column,Rval,G_size(1),G_size(2));
        %R_temp(loc1,loc1)=1/resistance;
        %R_temp(loc2,loc2)=1/resistance;
        %R_temp(loc1,loc2)=-1/resistance;
        %R_temp(loc1,loc1)=-1/resistance;
    end
    R_mat=R_mat+R_temp;
end
%update 
G=G+R_mat;
end

