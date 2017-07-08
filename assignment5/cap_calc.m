function [ C ] = cap_calc( cap, C )
%cap calc updates the circuit matrix G with specified resistor info
%   Input: C is the (possibly empty) capacitor matrix
%   Input: cap is the list of capacitors and contains its node connections
%   and its resistance
%   Output: C is the updated capacitor matrix

%initialize circuit grid
% node with no resistors remain 0
C_size=size(C);
cap_mat=sparse(C_size(1),C_size(2));

cap_size=size(cap);
%iteratively apply capacitor stamps
%node 0 refers to ground
for i=1:cap_size(1)
    loc1=cap(i,1);
    loc2=cap(i,2);
    capacitance=cap(i,3);
    if loc1==0
        if loc2==0
            %do nothing since both ends are grounded
        else
            row=loc2;
            column=loc2;
            Cval=capacitance;
            C_temp=sparse(row,column,Cval,C_size(1),C_size(2));
        end
    elseif loc2==0
            row=loc1;
            column=loc1;
            Cval=capacitance;
            C_temp=sparse(row,column,Cval,C_size(1),C_size(2));
    else
        row=[loc1, loc1, loc2, loc2];
        column=[loc1, loc2, loc1, loc2];
        Cval=[capacitance,-1*capacitance,-1*capacitance,capacitance];
        C_temp=sparse(row,column,Cval,C_size(1),C_size(2));
    end
    cap_mat=cap_mat+C_temp;
end
%update 
C=C+cap_mat;
end

