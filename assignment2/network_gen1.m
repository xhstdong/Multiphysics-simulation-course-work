function network_gen1(N,M,R,filepath, V,Vpos,I, Ipos)
%network_gen1 creates a grid of N by N grid of resistors with sources
%   Input: N is columns of the grid associated with index j
%   Input: M is rows of the grid associated with index i
%   Input: R is array of resistor grid values, R(1) is Rval of grid rows
%   and R(2) is Rval of grid cols, R(3) is grounding resistance (ass3 only),
%   R(4) is source resistance (ass3 only)
%   Input: V, Vpos: array of voltage source and node positions. Here we assume
%   they are connected to ground on one end
%   Input: I, Ipos: array of current sources and node positions. Here we assume
%   they are connected to ground on one end
%   Input: filepath, which should be a textfile. Circuit data is written
%   into the file.
%   Output: none

R_index=1;
V_index=1;
V_size=size(V);
I_index=1;
I_size=size(I);
fid=fopen(filepath,'w');

%writing resistors
for i=1:(M+1) %
    for j=1:(N+1)
        % horizontal R
        if j~=(N+1)
            %R_string=strcat('R',int2str(R_index), {' '}, int2str((i-1)*(N+1)+j),{' '},int2str((i-1)*(N+1)+j+1),{' '},int2str(R),{'\n'});
            fprintf(fid,'R%i %i %i %i \r\n',R_index,(i-1)*(N+1)+j,(i-1)*(N+1)+j+1,R(1));
            R_index=R_index+1;
        end
        if i~=(M+1) %vertical R
            %R_string=strcat('R',int2str(R_index), {' '}, int2str((i-1)*(N+1)+j),{' '},int2str(i*(N+1)+j),{' '},int2str(R),{'\n'});
            fprintf(fid, 'R%i %i %i %i \r\n',R_index,(i-1)*(N+1)+j,i*(N+1)+j,R(2));
            R_index=R_index+1;
        end
        
        %assignment3 addition: grounding resistors
        fprintf(fid,'R%i %i %i %i \r\n',R_index,(i-1)*(N+1)+j,0, R(3));
        R_index=R_index+1;
    end
end

%assignment 3 addition: voltage source resistance
%it connectes the 1st and (N+1)^2+1 node
%part b
%fprintf(fid,'R%i %i %i %i \r\n',R_index,(M+1)*(N+1)+1,1, R(4));
% for i=1:V_size(1)
%     fprintf(fid, 'V%i %i %i DC %i \r\n', V_index, Vpos(i,1), Vpos(i,2), V(i));
%     V_index=V_index+1;
% end




%writing currents
for i=1:I_size(1)
    fprintf(fid,'I%i %i %i DC %i \r\n', I_index, Ipos(i,1), Ipos(i,2), I(i));
    I_index=I_index+1;
end

fclose(fid);
end
