function [ x,total_error,iter ] = cg_optimization(x,M,b,epsilon,maxiter,varargin)
%cg_optimization uses conjugate gradient method to solve a Mx=b system
%   Input: M: matrix to be solved
%   Input: b is rhs of the general eq M*x=b
%   Input: x is the initial guess of the solution x=M^-1*b
%   Input: epsilon is convergence criteria
%   variable input: conditioning matrix P
%   output: x is the solution
%   output: total_error is an array of the residual error during each
%   iteration until convergence
%   output: iter is the number of iterations needed for convergence
%
% improvement code is added for part g. It is a sparse implementation of
% the more optimal implementation seen on pg 31 of class note pdf on
% convergence of conjugate gradient.

%apply conditioning
if nargin==6
   P=varargin{1};
   %M=P^-0.5*M*P^-0.5; %non-optimized conditioning code
   %x=P^0.5*x;
   %b=P^-0.5*b;
else
    P=sparse(eye([size(b,1) size(M,2)]));
end

%initial iteration
r(:,1)=b-M*x;
z(:,1)=P\r(:,1); %improvement
d(:,1)=z(:,1);  %improvement
%d(:,1)=r(:,1);
alpha=z(:,1)'*r(:,1)/(d(:,1)'*M*d(:,1)); %improvement
%alpha=d(:,1)'*d(:,1)/(d(:,1)'*M*d(:,1));
x=x+alpha*d(:,1) %print output
error=norm(M*x-b)/norm(b);
total_error=error;

iter=1;
%from 2nd iteration onwards:
while error>=epsilon && iter<maxiter
    iter=iter+1;
    r(:,iter)=r(:,iter-1)-alpha*M*d(:,iter-1);
    %r(:,iter)=b-M*x;
    z(:,iter)=P\r(:,iter); %improved
    beta=z(:,iter)'*r(:,iter)/(z(:,iter-1)'*r(:,iter-1)); %improved
    %beta=d(:,iter-1)'*(M*r(:,iter))/(d(:,iter-1)'*(M*d(:,iter-1)));
    d(:,iter)=z(:,iter)+beta*d(:,iter-1);
    %d(:,iter)=r(:,iter)-beta*d(:,iter-1);
    alpha=z(:,iter)'*r(:,iter)/(d(:,iter)'*(M*d(:,iter)));
    %alpha=d(:,iter)'*r(:,iter)/(d(:,iter)'*(M*d(:,iter)));
    x=x+alpha*d(:,iter)
    error=norm(M*x-b)/norm(b);
    fprintf('iteration: %f,   error: %f \n',iter,error);
    total_error=[total_error,error];
end

if iter>=maxiter
    display('Max iteration reached before convergence');
else
    fprintf('Convergence reached after %i iterations \n', iter);
end

%if nargin==6
%   x=P^-0.5*x; 
%end

end

