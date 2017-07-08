function [ g,J_g ] = calcg( x,D,Q,H,N )
% Evaluate non-linear functions

% calculate transistor parameters
% c is for collector and e for emitter
V_Tc = 1.38062e-23*293.15/1.60212e-19; % thermal voltage (k*T/q) at 20 degrees Celsius
V_Te = V_Tc;
I_Se = 1e-14; % saturation current
I_Sc = I_Se;
beta_F = 100; % forward beta
beta_R = 1; % reverse beta
alpha_F = beta_F/(1+beta_F); % forward alpha
alpha_R = beta_R/(1+beta_R); % reverse alpha

% diode parameters
I_Sd = 1e-14; % saturation current
V_Td = V_Tc; % thermal voltage

% initialize J_g and g
J_g = zeros(size(H,2),N);
g = zeros(size(H,2),1);

h = 0; % index to keep track of rows in J_g
% fill in g vector and jacobian for diodes
for ii = 1:length(D.n1)
    % calculate diode voltage drop
    % diode should not be connected to both reference nodes
    if D.n1(ii) == 0 % diode anode is connected to ground
        v_D = 0 - x(D.n2(ii));
    elseif D.n2(ii) == 0 % diode cathode is connected to ground
        v_D = x(D.n1(ii)) - 0;
    else % not connected to either reference node
        v_D = x(D.n1(ii)) - x(D.n2(ii));
    end
    
    % diode current
    i_D = I_Sd*( exp(v_D/V_Td) - 1 );
    dvi_D = I_Sd/V_Td*exp(v_D/V_Td);
    
    % fill in vector of non-linear functions
    g(ii) = i_D;
    
    % fill in jacobian from diodes
    if D.n1(ii) == 0
        J_g(h+1,D.n2(ii)) = -dvi_D;
    elseif D.n2(ii) == 0
        J_g(h+1,D.n1(ii)) = dvi_D;
    else % not connected to either reference node
        J_g(h+1,D.n1(ii)) = dvi_D;
        J_g(h+1,D.n2(ii)) = -dvi_D; % diode voltage drop
    end
    
    h = h + 1; % each diode adds one row to J_g
    
end

% do BJTs
for jj = 1:length(Q.nb)
    
    % calculate BJT voltage drops
    if Q.nb(jj) == 0
        v_be = 0 - x(Q.ne(jj));
        v_bc = 0 - x(Q.nc(jj));
    elseif Q.ne == 0
        v_be = x(Q.nb(jj));
        v_bc = x(Q.nb(jj)) - x(Q.nc(jj));
    else
        v_be = x(Q.nb(jj)) - x(Q.ne(jj));
        v_bc = x(Q.nb(jj)) - x(Q.nc(jj));
    end
    
    
    % forward and reverse currents and their derivatives
    i_F = I_Se*( exp(v_be/V_Te) - 1 );
    dvi_F = I_Se/V_Te*exp(v_be/V_Te);
    
    i_R = I_Sc*( exp(v_bc/V_Tc) - 1 );
    dvi_R = I_Sc/V_Tc*exp(v_bc/V_Tc);
    
    % fill in vector of non-linear functions
    g(1) = i_F;
    g(2) = i_R;
    
    % fill in Jacobian for BJT
    if Q.nb(jj) ~= 0
        J_g(h+2,Q.nb(jj)) = dvi_R;
        J_g(h+1,Q.nb(jj)) = dvi_F;
    end
    if Q.ne(jj) ~= 0
        J_g(h+1,Q.ne(jj)) = -dvi_F;
    end
    if Q.nc(jj) ~= 0
        J_g(h+2,Q.nc(jj)) = -dvi_R;
    end
    
    h = h + 2; % each BJT adds two rows to J_g
    
end


end

