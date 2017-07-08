function [ total_x,fnorm,xnorm, delx_list ] = newton_multi
%Vectorized simple Newton's Method for multi-dimensional problems
%the code constructs the jacobian iteratively and solve for the root of
%some vector optimization function f(x)=0. This function is q2 of
%assignment 4
%   output: solution x vector
%   output: error at each iteration

N=100; %number of discretizations
delta=(1-0)/(N+1);
V=100; %boundary V values
%note: two points are taken by boundary conditions
x=zeros([N 1]);  %initial guess is 0
f=x; %the optimization function
jacobian=zeros(N); %jacobian of f
fnorm=[];
xnorm=[];
delx_list=[];
total_x=[];
iter=1;
del_x=0;
epsilon=10^-6; %convergence criterion
maxiter=1000;

%calculate f(x) and jacobian
while iter<maxiter&& (iter<2|| fnorm(end)>epsilon|| norm(del_x)>epsilon|| norm(del_x)/norm(x)>epsilon)
    f(1)=2*x(1)-x(2)+V+delta^2*(exp(x(1))-exp(-x(1))); 
    jacobian(1,1)=2+delta^2*(exp(x(1))+exp(-x(1)));
    jacobian(1,2)=-1;
    for i=2:N-1
        f(i)=2*x(i)-x(i+1)-x(i-1)+ delta^2*(exp(x(i))-exp(-x(i)));
        jacobian(i,i)=2+delta^2*(exp(x(i))+exp(-x(i)));
        jacobian(i,i-1)=-1;
        jacobian(i,i+1)=-1;
    end
    f(N)=2*x(N)-x(N-1)-V+delta^2*(exp(x(N))-exp(-x(N)));
    jacobian(N,N)=2+delta^2*(exp(x(1))+exp(-x(1)));
    jacobian(N,N-1)=-1;
    
    %now update approximation
    %det(jacobian)
    %rank(jacobian)
    del_x=-1*(jacobian\f); %if J is invertible
    x=x+del_x; %update x guess
    total_x=[total_x,x];
    delx_list=[delx_list,norm(del_x)];
    xnorm=[xnorm,norm(x)];
    fnorm=[fnorm,norm(f)];
    iter=iter+1;
    
end
end

