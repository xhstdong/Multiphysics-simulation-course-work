function [ G,C,b,B,H,transistors,diodes ] = NodalAnalysisTransientNonlinear( filename )
% Modified nodal analysis implementation. Handles resistors, capacitors,
% inductors, current sources, and voltage source. Generates matrices G and
% C for analysis of dynamic circuits.

% INPUTS:
% - filename: netlist describing circuit
%       format: 
%       - resistors:                            Rlabel node1 node2 value
%       - independent current sources:          Ilabel node1 node2 DCvalue
%       - independent voltage sources:          Vlabel node+ node- DCvalue
%       - voltage controlled voltage sources:   Elabel node+ node- nodectrl+ nodectrl- gain

% read contents of file
fid = fopen(filename);

% read contents of file to cell array of strings
netlistData = textscan(fid,'%s','Delimiter','\n');
netlistData = netlistData{1}; % get rid of first layer of entries

fclose(fid); % close file

l = 1; % number of columns in voltage incidence matrices
k = 1; % number of rows in source incidence matrix
m = 1; % number of rows in inductor matrix
q = 1; % transistor index
d = 1; % diodes index

% initialize empty vectors and matricies
B_I = []; % vector of current sources
B_V = []; % vector of voltage sources
A_V = []; % voltage incidence matrix (l rows x k columns)
A_Vp = []; % voltage invidence matrix (k rows x l columns)
A_L = [];
G_R = []; % resistor incidence matrix
G_L = [];
C_C = []; % capacitor matrix
C_L = []; % inductor matrix
H = []; % incidence matrix for non-linear components
transistors = [];
diodes = [];
b_V = []; % source vector
b_I = [];

% some transistor parameters
beta_F = 100; % forward beta
beta_R = 1; % reverse beta
alpha_F = beta_F/(1+beta_F); % forward alpha
alpha_R = beta_R/(1+beta_R); % reverse alpha

% parse the text file line by line (there is some room for improvement in
% this section)
for ii = 1:size(netlistData,1)
    
    % find spaces that separate values
    spaces = regexp(netlistData{ii},'\s');
    
    if netlistData{ii}(1)=='Q' % transistor found
        
        % keep track of where transistors are connected to generate
        % matrices for non-linear components later
        nc = str2double(netlistData{ii}(spaces(1)+1:spaces(2)-1)); % collector node
        nb = str2double(netlistData{ii}(spaces(2)+1:spaces(3)-1)); % base node
        ne = str2double(netlistData{ii}(spaces(3)+1:end)); % base node
        
        transistors.nc(q) = nc;
        transistors.nb(q) = nb;
        transistors.ne(q) = ne;
        
        % non-linear components incidence matrix
        h = size(H,2); % number of columns in H
        
        % stamp transistor into H: NOT treating current sources as more diodes
        if nb ~= 0
            H(nb,h+1) = 1 - alpha_F;
            H(nb,h+2) = 1 - alpha_R;
        end
        if nc ~= 0
            H(nc,h+1) = alpha_F;
            H(nc,h+2) = -1;
        end
        if ne ~= 0
            H(ne,h+1) = -1;
            H(ne,h+2) = alpha_R;
        end
        
        
        q = q + 1;
    elseif netlistData{ii}(1)=='D' % diode found
        
        % keep track of where transistors are connected to generate
        % matrices for non-linear components later
        n1 = str2double(netlistData{ii}(spaces(1)+1:spaces(2)-1)); % anode node
        n2 = str2double(netlistData{ii}(spaces(2)+1:spaces(3)-1)); % cathode node
        
        diodes.n1(d) = n1;
        diodes.n2(d) = n2;
        
        h = size(H,2); % number of columns in H
        
        if n1 ~= 0
            H(n1,h+1) = 1;
        end
        if n2 ~= 0
            H(n2,h+1) = -1;
        end
        
        d = d + 1;
    else
        % read nodes and convert to numbers
        n1 = str2double(netlistData{ii}(spaces(1)+1:spaces(2)-1)); % first node
        n2 = str2double(netlistData{ii}(spaces(2)+1:spaces(3)-1)); % second node
        
        if netlistData{ii}(1)=='R' % resistor found
            %l = l+1; % add a column
            
            % matrix of values (1/R)
            valStr = netlistData{ii}(spaces(3)+1:end);
            val = readMetricPrefix(valStr); % get value of component
            
            if n1 ~= 0 % n1 is not the reference
                if size(G_R,1) >= n1 % G_R is large enough to update
                    G_R(n1,n1) = G_R(n1,n1) + 1/val;
                else
                    G_R(n1,n1) = 1/val; % add value
                end
                if n2 ~= 0 % n2 is also not the reference
                    if (size(G_R,1) >= n2) && (size(G_R,1) >= n1) % G_R is large enough to update
                        G_R(n1,n2) = G_R(n1,n2) - 1/val;
                        G_R(n2,n1) = G_R(n2,n1) - 1/val;
                    else
                        G_R(n1,n2) = -1/val;
                        G_R(n2,n1) = -1/val;
                    end
                end
            end
            if n2 ~= 0 % n2 is not the reference
                if size(G_R,1) >= n2
                    G_R(n2,n2) = G_R(n2,n2) + 1/val;
                else
                    G_R(n2,n2) = 1/val;
                end
            end
            
        elseif netlistData{ii}(1)=='I' % independent current source found
            valStr = netlistData{ii}(spaces(3)+1:end);
            val = readMetricPrefix(valStr); % get value of component
            
            % only add values if not connected to the reference node
            % vector b1: current sources
            
            if n1 ~= 0
                B_I(n1,k) = -1;
            end
            if n2 ~= 0
                B_I(n2,k) = 1;
            end
            
            if n1 ~= 0
                b_I(n1,k) = -1;
            end
            if n2 ~= 0
                b_I(n2,k) = 1;
            end
            
            
            k = k + 1;
            
        elseif netlistData{ii}(1)=='V' % independent voltage source found
            % vector b2: voltage sources
            %k = k+1; % add a column to Av
            
            valStr = netlistData{ii}(spaces(3)+1:end); % read value
            
            val = readMetricPrefix(valStr); % get value of component
            % build voltage incidence matrix and update vector of voltage
            % sources
            if n1 ~= 0
                A_V(n1,l) = 1; % update incidence matrix
                A_Vp(l,n1) = -1;
                
            end
            if n2 ~= 0
                A_V(n2,l) = -1; % update incidence matrix
                A_Vp(l,n2) = 1;
                
            end
            
            if n1 ~= 0
                b_V(l,1) = val;
            end
            if n2 ~= 0
                b_V(l,1) = val;
            end
            
            B_V(l,l) = 1; % add new entry to source matrix for V
            l = l+1;
            
            
        elseif netlistData{ii}(1)=='C' % capacitor found
            
            valStr = netlistData{ii}(spaces(3)+1:end);
            val = readMetricPrefix(valStr); % get value of component
            
            if n1 ~= 0 % n1 is not the reference
                if size(C_C,1) >= n1 % C_C is large enough to update
                    C_C(n1,n1) = C_C(n1,n1) + val;
                else
                    C_C(n1,n1) = val; % add value
                end
                if n2 ~= 0 % n2 is also not the reference
                    if (size(C_C,1) >= n2) && (size(C_C,1) >= n1) % C_C is large enough to update
                        C_C(n1,n2) = C_C(n1,n2) - val;
                        C_C(n2,n1) = C_C(n2,n1) - val;
                    else
                        C_C(n1,n2) = -val;
                        C_C(n2,n1) = -val;
                    end
                end
            end
            if n2 ~= 0 % n2 is not the reference
                if size(C_C,1) > n2
                    C_C(n2,n2) = C_C(n2,n2) + val;
                else
                    C_C(n2,n2) = val;
                end
            end
            
        elseif netlistData{ii}(1)=='L' % inductor found
            
            valStr = netlistData{ii}(spaces(3)+1:end);
            val = readMetricPrefix(valStr); % get value of component
            
            if n1 ~= 0 % n1 is not the reference
                G_L(m,n1) = -1/val;
                A_L(n1,m) = 1;
            end
            if n2 ~= 0 % n2 is not the reference
                G_L(m,n2) = 1/val;
                A_L(n2,m) = -1;
            end
            C_L(m,m) = 1;
            m = m+1;
            
        elseif netlistData{ii}(1)=='E' % voltage controlled voltage source found
            
            % vector b2: voltage sources
            % read additional paramteters for VCVSs
            nctrl1 = str2double(netlistData{ii}(spaces(3)+1:spaces(4)-1)); % first node
            nctrl2 = str2double(netlistData{ii}(spaces(4)+1:spaces(5)-1)); % second node
            gainStr = netlistData{ii}(spaces(5)+1:end);
            gainVal = readMetricPrefix(gainStr);
            
            
            % build voltage incidence matrix and update vector of voltage
            % sources
            if n1 ~= 0
                A_V(n1,l) = 1; % update incidence matrix
                A_Vp(l,n1) = -1;
                
            end
            if n2 ~= 0
                A_V(n2,l) = -1;
                A_Vp(l,n2) = 1;
                
            end
            if nctrl1 ~= 0
                A_Vp(l,nctrl1) =  -gainVal; % account for gain term
            end
            if nctrl2 ~= 0
                A_Vp(l,nctrl2) =  gainVal;
            end
            
            l = l+1; % add a column to voltage incidence matrix
            
            
        end
        
    end
    
end


% need to adjust size of A_V
if size(A_V,1) < size(A_L,1)
   A_V((end+1):size(A_L,1),:)=0;
%    A_V(:,(end+1):size(A_L,2))=0;
   
%    A_Vp((end+1):size(G_L,1),:)=0;
   A_Vp(:,(end+1):size(G_L,2))=0;
end

if size(A_V,1) < size(G_R,1)
   A_V((end+1):size(G_R,1),:)=0;
%    A_V(:,(end+1):size(A_L,2))=0;
   
%    A_Vp((end+1):size(G_L,1),:)=0;
   A_Vp(:,(end+1):size(G_R,2))=0;
end

% size of G_R
if size(G_R,1) < size(A_V,1)
   G_R(end+1:size(A_V,1),:)=0;
   G_R(:,size(G_R,1)) = 0; % make G_R square
%    A_V(:,(end+1):size(A_L,2))=0;
   
%    A_Vp((end+1):size(G_L,1),:)=0;
%    A_Vp(:,(end+1):size(G_L,2))=0;
end


% construct full G matrix
G = [G_R A_L A_V; G_L  zeros(size(G_L,1),(size(A_L,2) + size(A_V,2)) );...
    A_Vp zeros(size(A_Vp,1),(size(A_L,2) + size(A_V,2)) )];

% if size of B_I is less than G_R fill in with zeros
if size(G_R,1) > size(B_I,1) % more rows in G_R than B_I
%     B_I(:,(end+1):size(G_R,2)) = 0; % add zero entries to columns of B_I
    B_I((end+1):size(G_R,1),:) = 0; % add zero entries to rows of B_I
    
%     k = k+1;
end

% if size of B_L is less than bottom rows of G, then fill with zeros
if (size(G_L,1)+size(A_Vp,1)) > size(B_V,1)
%    B_V = zeros((size(G_L,1)+size(A_Vp,1))) + B_V; 
%     B_V = [zeros(size(G_L,1),size(A_L,2)+size(A_V,2)); ...
%         zeros(size(A_Vp,1),size(A_L,2)) B_V];
    B_V((end+1):size(A_Vp,1),:) = 0; % add zero entries to rows of B_V


end

% correct size of b

if (length(b_V) < size(A_Vp,1))
    b_V(end+1:size(A_Vp,1),:) = 0;
end
if (length(b_I) < size(G_R,1))
   b_I(end+1:size(G_R,1),:) = 0;
end

b = [b_I;b_V];

% b_V = [zeros(size(G_R,1),1); b_V];
% construct full B matrix
% correct sizes of B
if size(B_V,2) < size(B_I,2)
    B_V(:,end+1:size(B_I,2))=0;
end
if size(B_I,2) < size(B_V,2)
    B_I(:,end+1:size(B_V,2))=0;
end

B = [B_I; B_V];

% B = [B_I zeros(size(B_I,1),size(B_V,2)); zeros(size(B_V,2),size(B_I,1)) B_V];

% correct sizes of C_C and C_L
if size(C_L,1) > size(C_C,1)
   C_C(:,(end+1):size(C_L,2)) = 0; % add zero entries to columns of C_C
   C_C((end+1):size(C_L,1),:) = 0; % add zero entries to rows of C_C
end
% if size(C_L,1) < (size(G_L,1)+size(A_Vp,1))
% %    C_L(:,(end+1):size(C_L,2)) = 0; % add zero entries to columns of C_C
%    C_L((end+1):(size(G_L,1)+size(A_Vp,1)),:) = 0; % add zero entries to rows of C_C
% end
% if size(C_L,2) < (size(A_L,2)+size(A_V,2))
%    C_L(:,(end+1):(size(A_L,2)+size(A_V,2))) = 0; % add zero entries to columns of C_C
% %    C_L((end+1):(size(G_L,1)+size(A_Vp,1),:) = 0; % add zero entries to rows of C_C
% end


C = [C_C zeros(size(C_C,1),size(C_L,2)); zeros(size(C_L,1),size(C_C,2)) C_L];
% b = 0;

% correct size of C
if size(C,1) < size(G,1)
    C(end+1:size(G,1),:) = 0;
    C(:,end+1:size(C,1)) = 0;
end

if size(H,1) < size(G,1)
   H(end+1:size(G,1),:) = 0; 
end

% add an entry to D or Q if they are empty for compatibility with other
% code
if length(diodes) == 0
    diodes.n1 = [];
end
if length(transistors) == 0
    transistors.nb = [];
end


% B = B(:,end); % only keep last column of B
end

