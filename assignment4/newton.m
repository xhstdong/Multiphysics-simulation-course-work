function [ x ,y] = newton(newton_func,func_deriv,epsilon,x0,lambda)
%Newton's method with possibility of source stepping
%   Input: epsilon is the convergence criteria
%   Input: newton_func is function handle of the optimization function to 
%be solved
%   Input: func_deriv is the function handle of derivative of newton_func
%   Input: x0 the initial guess at the solution
%   Input: lambda: If newton_func takes a lambda for source stepping, this
%   function will takes in a lambda parameter.
%   Ouput: x, an array containing x solution at each iteration
%   output: y, ann arrya containing f(x) solution at each iteration

%variables
%V_t=1/80;
%R=1;
%I_s1=5;
%I_s2=10^-6;
%I0=10^-6;
maxiter=5000;
%epsilon=10^-6;
 
% if varargin==1
%     lambda=varargin{1};
% else
%     lambda=1;
% end

x=x0; %initial guess
iter=1;
%y(1)=diode_eq(x,lambda);
y(1)=newton_func(x,lambda);
delta_x=0;
%function is: x/R+I0*exp(x/V_t)-(I_s1-I_s2_I0)=0;
while iter<maxiter && (abs(y(iter))>epsilon||abs(delta_x)>epsilon||abs(delta_x)/abs(x)>epsilon)
    %diff_f=1/R+I0/V_t*exp(x/V_t);
    diff_f=func_deriv(x,lambda);
    delta_x=-y(iter)/diff_f;
    x=x+delta_x;
    %y=[y,diode_eq(x,lambda)];
    y=[y,newton_func(x,lambda)];
    iter=iter+1;
end
end

function [y]= diode_eq(x,lambda)
V_t=1/80;
R=1;
I_s1=5;
I_s2=10^-6;
I0=10^-6;
y=x/R+I0*exp(x/V_t)-(I_s1-I_s2-I0)*lambda;

end