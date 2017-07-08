function [ G,C,B ] = L_calc( L, G, C, B )
%L_calc adds the inductor related equations into the nodal matrices
%   Input: L is the list of inductors containing their values and node
%   positions
%   Input: G is the resistor circuit matrix
%   Input: C is the capacitor circuit matrix
%   Input: B is the source matrix
%   Ouput: updated G,C,B

G_size=size(G);
C_size=size(C); %C should be same dimension as G
L_size=size(L);

%augment the columns of G
G(:,(G_size(2)+1):(G_size(2)+L_size(1)))=zeros([G_size(1) L_size(1)]);

%add the new columns of C, which are all 0
C(:,(C_size(2)+1):(C_size(2)+L_size(1)))=zeros([C_size(1) L_size(1)]);

for i=1:L_size(1)
    loc1=L(i,1);
    loc2=L(i,2);
    induct=L(i,3);
   
    %augment the rows of C
    C(C_size(1)+i,:)=zeros([1 C_size(2)+L_size(1)]);
    %add positions of di/dt
    C(C_size(1)+i,C_size(1)+i)=induct;
    
    %augment the rows of G
    G(G_size(1)+i,:)=zeros([1 G_size(2)+L_size(1)]);
    %add position of the two nodes of the inductor
    if loc1~=0
        G(G_size(1)+i,loc1)=1;
        G(loc1,G_size(1)+i)=-1;
    end
    if loc2~=0
        G(G_size(1)+i,loc2)=-1;
        G(loc2,G_size(1)+i)=1;
    end
    %augment B matrix rows
    B(G_size(1)+i,:)=zeros([1 size(B,2)]);
end



end

