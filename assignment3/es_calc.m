function [ G,b ] = es_calc( E,G,b )
%es_calc updates the circuit matrix G and source vector b with dependent voltage sources
%   Input: E is the dependent voltage source matrix where each row
%   represents a voltage source
%   Input: G is the circuit matrix
%   Input: b is the source vector
%   The input G does not contain E source equations. es_calc will add additional
%   rows representing dependent voltage sources
%   Output: G and b are updated with dependent voltage sources

G_size=size(G);
E_size=size(E);
E_temp=zeros(E_size(1),G_size(2));
E_temp_vert=E_temp;
for i=1:E_size(1)
    Eloc1=E(i,1);
    Eloc2=E(i,2);
    Vloc1=E(i,3);
    Vloc2=E(i,4);
    gain=E(i,5);
    
    if Eloc1~=0
        E_temp(i,Eloc1)=1;
        E_temp_vert(i,Eloc1)=-1;
    end
    if Eloc2~=0
        E_temp(i,Eloc2)=-1;
        E_temp_vert(i,Eloc2)=1;
    end
    
    if Vloc1~=0
        E_temp(i,Vloc1)=E_temp(i,Vloc1)-gain;
    end
    if Vloc2~=0
        E_temp(i,Vloc2)=E_temp(i,Vloc2)+gain;
    end
    
    b(G_size(1)+i,1)=0;
end
%augment rows of G
G((G_size(1)+1):(G_size(1)+E_size(1)),:)= E_temp;

%augment columns of G
G(:,(G_size(2)+1):(G_size(2)+E_size(1)))=zeros(G_size(1)+E_size(1),E_size(1));
G(1:G_size(1),(G_size(2)+1):(G_size(2)+E_size(1)))=E_temp_vert';




end

