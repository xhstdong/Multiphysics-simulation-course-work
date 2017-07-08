function [ t_time, t ,input] = adaptive_step_v2( G, C, B, u, delta, t_start, t_end)
%adaptive_step implementation with interpolation functionality
%   Input: G,C,B are circuit matrices
%   u is the incoming excitation. Currently it is just a dummy value, the
%   actual u variation is implemented inside this function
%   delta is the initial step size
%   t_start is simulation start time
%   t_end is simulation end time
%   Output: t is a N by T matrix. N is the number of nodes, and T is the
%   number of time steps
%   t_time is a 1 by T array of time values corresponding to t
%   input is the generated signal
%  currently a 1-step trapezoidal rule and a 2-step trapezoidal rule is
%  used

%note: after getting the entire t, we need another function to do some
%interpolation so there would be an output at every time point where there
%is an input
%initial guess of time step (may be too large)
%delta=10^-11; % this value seems to work

%the following parameters may affect results significantly
% epsilon is maximum tolerable difference between two methods
epsilon_max=0.00003; 
% largest allowable step
delta_max=(t_end-t_start)/50;
% smallest allowable step
delta_min=(t_end-t_start)/10^6;

%generate input signal
[u_time, input]=clk_wave_gen(delta*10^9,t_start*10^9,t_end*10^9);
u_time=u_time*10^-9;

%this records the time of time stepping
t_time=zeros([1 10^6]); 
t=zeros([size(G,1) 10^6]); %final result stored here
%assumed initial condition =0

%result from second method stored here
tr=zeros([size(G,1) 10^6*2]);
t_index=1;
while t_index<length(u_time) && t_time(t_index)<t_end
    t_index=t_index+1;
    epsilon=epsilon_max+2; %epsilon reinitialized to random large value
    u_original=u; %input of previous step is stored temporarily
    while epsilon>epsilon_max
        %2 step trapezoidal:
        for i=1:2
            % update boundary
            u_prev=u;
            time_temp=t_time(t_index-1)+i*delta/2;
            u=find_input(time_temp, u_time,input);      
            tr(:,(t_index-1)*2+i)=(G/2+C/(delta/2))\(-(G/2-C/(delta/2))*tr(:,(t_index-1)*2+i-1)+B/2*(u+u_prev));
        end
        %1 step trapezoidal
        t(:,t_index)=(G/2+C/(delta))\(-(G/2-C/(delta))*t(:,(t_index-1))+B/2*(u+u_original));

        %error is calculated using l2 norm and normalized to size of
        %circuit
        epsilon=norm(t(:,t_index)-tr(:,t_index*2),2)/size(G,2);
        
        %compare error
        if epsilon<epsilon_max
            %can proceed to next time step
            t_time(t_index)=time_temp;

            %2 step trapezoidal is more accurate than 1 step; therefore,
            %store the results of the 2-step method
            t(:,t_index)=tr(:,2*t_index);
            
            %error is very small, can try larger steps
            delta=min(0.9*sqrt(epsilon_max/epsilon)*delta,delta_max);
        elseif epsilon>epsilon_max
            % error is too large, must redo with smllaer steps
            delta=max(0.9*epsilon_max/epsilon*delta,delta_min);
            %return to previous excitation value
            u=u_original;
        end
    end
end

%cut out 0-value elements
t_time=t_time(1:t_index);
t=t(:,1:t_index);

%optional: interpolate to match timing with input signal
t_real=zeros([size(G,1) length(u_time)]);

for i=1:length(u_time)
    t_real(:,i)=find_input(u_time(i),t_time,t);
end

end

