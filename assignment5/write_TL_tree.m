function write_TL_tree(filepath )
%write_TL_tree generates the net list of the binary tree transmission line
%used in assignment 5
%   Input: file path of the net list file
%   Output: none. Values are written to file directly

%parameters specified by assignment
del_z=0.05;
R=[2.5,3.57,5.1,5.1]; %ohm per mm
L=[0.5,0.714,1.02,1.02]*10^-9; %H/mm
C=[0.2,0.14,0.098,0.098]*10^-12; %F/mm
lengths=[6,4,3,2]; %mm

R_chip=5000;
C_chip=5*10^-15;

fid=fopen(filepath,'w');
R_index=1;
C_index=1;
L_index=1;
V_index=1;
node_index=1;

% there are 1 path on level 1, 2 paths on lv2, 4 paths on lv 3 etc. (2^(i-1))

%because first level does not split immediately, it's treated separately
%divide by 2del_z if each element takes up del_z, and not the whole RLC
N=lengths(1)/del_z;
            for j=1:N %fill out each chain by iteratively creating one section of TL
                fprintf(fid,'R%i %i %i %.4e \r\n',R_index,node_index,node_index+1,R(1)*del_z);
                R_index=R_index+1;
                node_index=node_index+1;
                fprintf(fid,'L%i %i %i %.4e \r\n',L_index,node_index,node_index+1,L(1)*del_z);
                L_index=L_index+1;
                node_index=node_index+1;
                fprintf(fid,'C%i %i %i %.4e \r\n',C_index,node_index,0,C(1)*del_z);
                C_index=C_index+1;
            end
            
base_node_list=node_index;
base_node=node_index;
base_index=1;

for i=2:length(lengths) %for each level after the first
    N=lengths(i)/del_z;
    for k=1:2^(i-2) %for each branch from previous level
        base_node=base_node_list(base_index);
        base_index=base_index+1;
        for index=1:2 %create two branches from every previous branch
            fprintf(fid,'R%i %i %i %.4e \r\n',R_index,base_node,node_index+1,R(i)*del_z);
            R_index=R_index+1;
            node_index=node_index+1;
            fprintf(fid,'L%i %i %i %.4e \r\n',L_index,node_index,node_index+1,L(i)*del_z);
            L_index=L_index+1;
            node_index=node_index+1;
            fprintf(fid,'C%i %i %i %.4e \r\n',C_index,node_index,0,C(i)*del_z);
            C_index=C_index+1;
            
            for j=2:N %fill out each branch by iteratively creating one section of TL
                fprintf(fid,'R%i %i %i %.4e \r\n',R_index,node_index,node_index+1,R(i)*del_z);
                R_index=R_index+1;
                node_index=node_index+1;
                fprintf(fid,'L%i %i %i %.4e \r\n',L_index,node_index,node_index+1,L(i)*del_z);
                L_index=L_index+1;
                node_index=node_index+1;
                fprintf(fid,'C%i %i %i %.4e \r\n',C_index,node_index,0,C(i)*del_z);
                C_index=C_index+1;
            end
            %remember last node of each chain
            base_node_list=[base_node_list,node_index];
        end
    end
end

%add in chip circuitry
while base_index<=length(base_node_list)
        base_node=base_node_list(base_index);
        base_index=base_index+1;
            fprintf(fid,'R%i %i %i %.4e \r\n',R_index,base_node,node_index+1,R_chip);
            R_index=R_index+1;
            fprintf(fid,'C%i %i %i %.4e \r\n',C_index,base_node,node_index+1,C_chip);
            C_index=C_index+1;            
            node_index=node_index+1;        
end

%add clock generator place holder
fprintf(fid,'V%i %i %i DC %i \r\n', V_index, 1, 0, 0);
V_index=V_index+1;

fclose(fid);
end

