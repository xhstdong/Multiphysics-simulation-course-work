function [ G,C, B,u ] = vs_calc( V, G, C, B, u )
%vs calc updates the circuit matrices with independent voltage sources
%   Input: V is the independent voltage source matrix where each row
%   represents a voltage source
%   Input: G is the circuit matrix
%   Input: C is the capacitor matrix
%   Input: B is the source matrix
%   Input: u is the source vector
%   The input G only contain node equations. vs_calc will add additional
%   rows representing voltage sources
%   Output: G,C,B, and u are updated with voltage sources
G_size=size(G);
V_size=size(V);
B_size=size(B);
V_temp=zeros(V_size(1),G_size(2));
%expand B
B=[B;zeros(V_size(1),B_size(2))];
B=[B,zeros(B_size(1)+V_size(1),V_size(1))];
%expand C columns
C=[C,zeros(size(C,1),V_size(1))];

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
    
    %modify B matrix
    B(B_size(1)+i,B_size(2)+i)=1;
    %modify C matrix rows
    C(G_size(1)+i,:)=zeros([1 size(C,2)]);
    %add a voltage source term
    u(B_size(2)+i,1)=volt;
end
%augment rows of G
G((G_size(1)+1):(G_size(1)+V_size(1)),:)= V_temp;

%augment columns of G
G(:,(G_size(2)+1):(G_size(2)+V_size(1)))=zeros(G_size(1)+V_size(1),V_size(1));
G(1:G_size(1),(G_size(2)+1):(G_size(2)+V_size(1)))=-1*V_temp';

end

