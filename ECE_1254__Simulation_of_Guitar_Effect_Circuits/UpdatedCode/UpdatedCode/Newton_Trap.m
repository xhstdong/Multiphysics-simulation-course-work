function [ x ] = Newton_Trap( G,H,C,B,D,Q,u,t,NiterMax,epsilon,x0,N,plotResults )
% nest Newton's method inside trapezoidal

dt = diff(t); % spacing in time points
dt = dt(1);

% trapezoidal rule code
% inverse term in update equation
% M = G/2 + C/deltaT; % this doesn't change
% % invM = eye(size(G,1))/M;

% P = G/2 - C/deltaT; % also doesn't change
dxp_max=0.1;
x0 = zeros(size(G,1),1); % initial guess

% solve DC system to get initial guess
b = B*u(:,1);
%[~,x(:,1),Niter ] = newtonMethodMultiD( G,H,b,D,Q,NiterMax,epsilon,x0,N,0 );
[ ~,x(:,1),Niter ] = newtonMethodMultiDContinuation( G,H,b,D,Q,NiterMax,epsilon,x0,N,0 );
%x(:,1)=x0;

[ g(:,1),J_g ] = calcg( x(:,1),D,Q,H,N ); % values from initial guess


% Trapezoidal rule implementation
for ii = 2:size(u,2)
    % trapezoidal rule update
    %    x(:,ii) = invM*( B*( u(:,ii) + u(:,ii-1) )/2 - P*x(:,ii-1) - H/2*( g(:,ii) + g(:,ii-1) ) );
    %    x(:,ii) = eye(size(G,1))/(G/2+C/deltaT)*(-(G/2-C/deltaT)*x(:,ii-1) + B*(u(:,ii)+u(:,11-1))/2);
    if mod(ii,10^4)==0
        ii
    end
    
    % xp: indicates solution being updated in Newton method
    kk = 1; % index
    convFlag = 0; % flag to indicate convergence
    Niter = 0; % number of iterations
    
%     xp = x0; % intial guess
    xp = x(:,ii-1);
    
    while( (convFlag == 0) && (Niter < NiterMax))
        
        [gp,J_g] = calcg(xp,D,Q,H,N);
        
%         if mod(kk,100)==0
%            kk 
%         end
        % evaluate function at current iteration
        % discretized derivative using trapezoidal rule
        F = G*(xp+x(:,ii-1))/2 + C*(xp-x(:,ii-1))/dt  + H*(gp + g(:,ii-1))/2 - ...
            B*( u(:,ii) + u(:,ii-1) )/2;
        
        % evaluate jacobian of F (also from TR discretization)
        J = G/2 + C/dt + H/2*J_g;
        
        % update solution
        dxp = -eye(size(J,2))/J*F;
        if norm(dxp)>dxp_max
            dxp=dxp_max/norm(dxp)*dxp;
        end
        xpNew = xp + dxp;
        
        % check for convergence
        normF(kk) = sqrt( sum(F.^2) );
        normdx(kk) = sqrt( sum((xpNew-xp).^2) );
        normdx2(kk) = normdx(kk)/sqrt( sum(xp.^2) );
        
        %note: it may be necessary to comment out the last one or two
        %conditions if convergence is an issue
        if (normF(kk) <= epsilon) && (normdx(kk) <= epsilon) && (normdx2(kk) <= epsilon)
            convFlag = 1;
        end
        
        xp = xpNew; % update solution
        
        kk = kk+1;
        Niter = Niter+1;
    end
    if convFlag==0
        fprintf('Newton method has not converged\n');
    end
    
    x(:,ii) = xp; % update solution in time
    g(:,ii) = gp; % update vector of nonlinear equations
end



end
