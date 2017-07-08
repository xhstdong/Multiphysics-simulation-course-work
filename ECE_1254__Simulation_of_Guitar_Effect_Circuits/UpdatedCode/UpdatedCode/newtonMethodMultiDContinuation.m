function [ J,x,Niter ] = newtonMethodMultiDContinuation( G,H,b,D,Q,NiterMax,epsilon,x0,N,plotResults )
% Newton method code for circuit containing BJTs and diodes

% Use continuation methods to improve singular jacobian issues

% INPUTS:
%   G - matrix multiplied by unknowns
%   H - incidence matrix for non-linear components
%   D - struct of diode nodes
%   Q - struct of transistor nodes
%   NiterMax - maximum number of Newton iterations
%   epsilon - convergence threshold
%   x0 - initial guess
%   N - numbers of rows in G
%   plotResults - '1' to plot residuals, '0' to not

% Use the multi-dimensional Newton method to solve the non-linear Poisson's
% equation

dlambda = 0.01; % continuation parameter
lambda = 0;

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

kk = 1; % index
convFlag = 0; % flag to indicate convergence



% non-linear elements jacobian has dimensions of 
% number of non-linear elements x number of columns in G
% (this needs to be adjusted for transistors)
J_g = zeros(size(H,2),N);
g = zeros(size(H,2),1);

x = x0; % intial guess
while (lambda-1) <= 1e-10
    Niter = 0; % number of iterations

    while( (convFlag == 0) && (Niter < NiterMax))
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
        
        % evaluate function at current iteration
        F = lambda*G*x + lambda*H*g - lambda*b + (1-lambda)*x;
        
        % evaluate jacobian of F
        J = lambda*G + lambda*H*J_g + eye(N)*(1-lambda);
        
        % update solution
        dx = -eye(size(J,2))/J*F;
        xNew = x + dx;
        
        % check for convergence
        normF(kk) = sqrt( sum(F.^2) );
        normdx(kk) = sqrt( sum((xNew-x).^2) );
        normdx2(kk) = normdx(kk)/sqrt( sum(x.^2) );
        
        % doesn't converge if the solution is zero (lambda = 0 and initial
        % guess of 0)
        % put in some logic to avoid this
        if (lambda == 0) % ignore normdx2 as it is NaN for lambda = 0 with zero initial guess
            if (normF(kk) <= epsilon) && (normdx(kk) <= epsilon) 
                convFlag = 1;
            end
        else
            if (normF(kk) <= epsilon) && (normdx(kk) <= epsilon) && (normdx2(kk) <= epsilon)
                convFlag = 1;
            end            
        end
        
        
        x = xNew; % update solution
        
        kk = kk+1;
        Niter = Niter+1;
        
    end
    
    % update lambda
    
%     if convFlag == 1 % newton method has converged, increase step size
% %         dlambda = dlambda*2;
% %         lambdaPrev = lambda;
%         lambda = lambda + dlambda;
% %     elseif convFlag == 0 % newton method has not converged, decrease step size
% %         dlambda = dlambda/2;
% %         lambda = lambdaPrev + dlambda;
% %         lambdaPrev = lambda;
%     end
    lambda = lambda + dlambda;
    
    convFlag = 0; % reset convergence flag
end

if Niter >= NiterMax
    fprintf('Newton method has not converged\n');
end

if plotResults == 1
    % plot residuals
    figure;
    semilogy(normdx,'LineWidth',1.5);
    xlabel('Iteration number','FontSize',12)
    ylabel('||x_{k+1}-x_{k}||','FontSize',12)
    grid on;
    set(gcf,'PaperSize',[5 4]) % smaller image
    set(gcf,'PaperPosition',[0 0 5 4]) % smaller image
    set(gca,'FontSize',12)
    
    figure;
    semilogy(normF,'LineWidth',1.5);
    xlabel('Iteration number','FontSize',12)
    ylabel('||F(x)||','FontSize',12)
    grid on;
    set(gcf,'PaperSize',[5 4]) % smaller image
    set(gcf,'PaperPosition',[0 0 5 4]) % smaller image
    set(gca,'FontSize',12)
    
    figure;
    semilogy(normdx2,'LineWidth',1.5)
    xlabel('Iteration number','FontSize',12)
    ylabel('||x_{k+1}-x_k||/||x_k||','FontSize',12)
    grid on;
    set(gcf,'PaperSize',[5 4]) % smaller image
    set(gcf,'PaperPosition',[0 0 5 4]) % smaller image
    set(gca,'FontSize',12)
end

end

