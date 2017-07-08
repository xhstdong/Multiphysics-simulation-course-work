function [ u_time,t,comp_time ] = TR_circuit( G, C, B, u, delta, t_start, t_end)
%TR_circuit uses Trapezoidal Rule to solve a circuit as seen in assignment
%6 through time stepping
%   Input: G,C,B,u are the circuit components
%   Input: delta is the size of the time step
%   Input: t_start and t_end defines the interval of time
%   Output: u_time is the list of simulated time values
%   Output: t is the matrix of solutions of all nodes over time
%   Output: comp_time measures the time taken for simulation

%note: for case 1 (step function), u=0

%generate waveform at node 1
%this represent a varying voltage source between n1 and ground

%case 1: constant step function
u_time=linspace(t_start,t_end,(t_end-t_start)/delta);
u_val=ones(length(u_time));

%case 2: sinusoidal
%u_val=sin(0.01*u_time);

tic
t=zeros([size(G,1) length(u_time)]);
%assume zero initial condiiton for t and u

for index=2:length(u_time)
    %only a place holder 0 value for the clock source is in u, replace this
    %value with the actual u values. Here it is
    %assumed that the voltage source is attached at the end of u vector.
    u_prev=u; %save last iteration excitations
    u(end)=u_val(index);
    t(:,index)=(G/2+C/delta)\(-(G/2-C/delta)*t(:,index-1)+B/2*(u+u_prev));
end
comp_time=toc;
% plot(u_time,t(1,:))
% %one of the output node
% figure
% plot(u_time,t(end,:))
end

