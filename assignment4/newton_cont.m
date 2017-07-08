function [ x ,y] = newton_cont
%Newton's method with continuation/source stepping
%   
x=0; %initial guess
epsilon=10^-6;
del_lambda=0.1;
lambda=0; 
lambda_prev=lambda;
figure
hold on
y=[];

%variables for equation
V_t=1/80;
R=1;
I_s1=5;
I_s2=10^-6;
I0=10^-6;

while lambda<1    
    %q1c
   diode_eq=@(x,lambda)(x/R+I0*exp(x/V_t)-lambda*(I_s1-I_s2-I0));
   diode_deriv=@(x,lambda)(1/R+I0/V_t*exp(x/V_t));
   
   %q1d
%   diode_eq=@(x,lambda)(lambda*(x/R+I0*exp(x/V_t)-(I_s1-I_s2-I0))+(1-lambda)*x);
 %  diode_deriv=@(x,lambda)(lambda*(1/R+I0/V_t*exp(x/V_t))+1-lambda);
   
   
   [x_temp,y_val]=newton(diode_eq,diode_deriv,epsilon, x,lambda);
   plot(y_val);
   y=[y,y_val];
   if abs(y_val(end))<=epsilon
       %convergence reached
       lambda_prev=lambda;
        lambda=lambda+del_lambda;
        x=x_temp; %ver 1
        
        %ver 2 improvements
        %dx=-(diode_eq(x,lambda_prev)-x)*del_lambda/diode_deriv(x,lambda_prev);
        %x=x_temp+dx;
        

   else
       %did not converge. try a smaller value
       del_lambda=del_lambda/2;
       lambda=lambda_prev+del_lambda;
   end
    
end


end

