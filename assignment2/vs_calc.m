function [ G, b ] = vs_calc( V, G, b )
%vs calc updates the circuit matrix G and source vector b with independent voltage sources
%   Input: V is the independent voltage source matrix where each row
%   represents a voltage source
%   Input: G is the circuit matrix
%   Input: b is the source vector
%   The input G only contain node equations. vs_calc will add additional
%   rows representing voltage sources
%   Output: G and b are updated with voltage sources
G_size=size(G);
V_size=size(V);
V_temp=zeros(V_size(1),G_size(2));
for i=1:V_size(1)
    loc1=V(i,1);
    loc2=V(i,2);
    volt=V(i,3);
    
    if loc1~=0
        V_temp(i,loc1)=1;
    end
    if loc2~=0
        V_temp(i,loc2)=-1;
    end
    
    b(G_size(1)+i,1)=volt;
end
%augment rows of G
G((G_size(1)+1):(G_size(1)+V_size(1)),:)= V_temp;

%augment columns of G
G(:,(G_size(2)+1):(G_size(2)+V_size(1)))=zeros(G_size(1)+V_size(1),V_size(1));
G(1:G_size(1),(G_size(2)+1):(G_size(2)+V_size(1)))=-1*V_temp';

end

