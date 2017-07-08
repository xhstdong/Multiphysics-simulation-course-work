function [ x_0] = interpolate_signal( t,x,t_0 )
%Interpolate_signal interpolates the x value at t_0 based on the data set
%t, x
%   Used in adaptive stepping implementation. x could be vector or scalar
%   Input: array of known t values
%   Input: array of known x(t) values. Note x is vector
%   Input: desired interpolation point t_0
%   Ouput: interpolated value x(t_0)

%note, linear interpolation if two points given, quadratic if 3 points
%given. we could potentially add more
x_0=zeros([size(x,1) 1]);
switch length(t)
    case 2 
        slope=(x(:,2)-x(:,1))/(t(2)-t(1));
        x_0=slope*(t_0-t(1))+x(1);
    case 3
        for i=1:size(x,1)
            %since polyfit takes in only scalar functions, for loop is needed

            p=polyfit(t,x(i,:),2);
            x_0(i)=t_0^2*p(1)+t_0*p(2)+p(3);
        end
end
end

