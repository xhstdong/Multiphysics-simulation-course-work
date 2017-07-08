function [ J,x,Niter ] = newtonMethodMultiD( G,H,b,D,Q,NiterMax,epsilon,x0,N,plotResults )
% Newton method code for circuit containing BJTs, diodes, capacitors, and
% inductors

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

kk = 1; % index
convFlag = 0; % flag to indicate convergence
Niter = 0; % number of iterations

x = x0; % intial guess

while( (convFlag == 0) && (Niter < NiterMax))
    
    [g,J_g] = calcg(x,D,Q,H,N);
    
    % evaluate function at current iteration
    F = G*x + H*g - b;
    
    % evaluate jacobian of F
    J = G + H*J_g;
    
    % update solution
    dx = -eye(size(J,2))/J*F;
    xNew = x + dx;
    
    % check for convergence
    normF(kk) = sqrt( sum(F.^2) );
    normdx(kk) = sqrt( sum((xNew-x).^2) );
    normdx2(kk) = normdx(kk)/sqrt( sum(x.^2) );
    
    if (normF(kk) <= epsilon) && (normdx(kk) <= epsilon) && (normdx2(kk) <= epsilon)
        convFlag = 1;
    end
    
    x = xNew; % update solution
    
    kk = kk+1;
    Niter = Niter+1;
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

