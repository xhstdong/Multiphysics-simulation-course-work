function [ R, I, V, E, C, L ] = extract_data( data_raw )
%Extraction reads the cell array and pull out the useful values
%   Input: cell array for the entire circuit
%   Outpt: [ R, I, V, E, C, L ] are separate arrays for each type of circuit element

R=[]; Rindex=1;
I=[]; Iindex=1;
V=[]; Vindex=1;
E=[]; Eindex=1;
C=[]; Cindex=1;
L=[]; Lindex=1;

for index=1:length(data_raw)
    [label,remain]=strtok(data_raw{index});
    if strncmpi(label,'R',1)==1
        %read data for resistor
        % node1, node2, value
        for subind=1:3
            [newval, remain]=strtok(remain);
            R(Rindex,subind)=str2num(newval);
        end
        Rindex=Rindex+1;
    elseif strncmpi(label, 'I', 1)==1
        %read data for current source
        %node1, node2, DC, value
        for subind=1:2
            [newval, remain]=strtok(remain);
            I(Iindex,subind)=str2num(newval);
        end
        [~,remain]=strtok(remain);
        newval=strtok(remain);
        I(Iindex,3)=str2num(newval);
        Iindex=Iindex+1;
            
    elseif strncmpi(label, 'V', 1) ==1
        %read data for voltage source
        %node+, node-, DC, value
        for subind=1:2
            [newval, remain]=strtok(remain);
            V(Vindex,subind)=str2num(strtok(newval));
        end
        [~,remain]=strtok(remain);
        newval=strtok(remain);
        V(Vindex,3)=str2num(newval);
        Vindex=Vindex+1;
    elseif strncmpi(label, 'E', 1) ==1
        %read data for dependent voltage source
        %node+, node-, nodectrl+ nodectrl-  gain
        for subind=1:5
            [newval, remain]=strtok(remain);
            E(Eindex,subind)=str2num(newval);
        end
        Eindex=Eindex+1;
    elseif strncmpi(label, 'C', 1) ==1
        % read data for capacitors
        % node1 node2 value
        for subind=1:3
            [newval,remain]=strtok(remain);
            C(Cindex,subind)=str2num(newval);
        end
        Cindex=Cindex+1;
    elseif strncmpi(label, 'L', 1) ==1
        %read data for inductors
        %node1 node2 value
        for subind=1:3
            [newval,remain]=strtok(remain);
            L(Lindex,subind)=str2num(newval);
        end
        Lindex=Lindex+1;
    else
        display(strcat('circuit element ',data_raw{index}, ' cannot be identified'))
    end
end

