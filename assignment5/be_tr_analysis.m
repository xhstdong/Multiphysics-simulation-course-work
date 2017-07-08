%this script completes the last 2 segments of assignment 5
%it computes the solutions of a circuit using BE and TR using a variety of
%time steps, and find their computational time and error convergence

delta_list=[0.01,0.005,0.001,0.0005,0.0001]; %length of time steps
T_num=6./delta_list; %total number of time intervals
N=length(delta_list); 
be_results=cell(1,N); %BE results
tr_results=be_results; %TR results
be_time=zeros([1 N]); 
tr_time=be_time;
be_err=zeros([1 N]); %Be error
tr_err=be_err; %TR error
%calculate the results iteratively over variety of time steps
for i=1:N
    [~,be_results{i},be_time(i)]=BE_circuit(G,C,B,u,delta_list(i),0,6);
    [~,tr_results{i},tr_time(i)]=TR_circuit(G,C,B,u,delta_list(i),0,6);
end
sol=tr_results{N}; %standard solution is the finst TR mesh

 for i=1:N

%matrix dimensions are mismatched, must use only time steps evaluted by
%both the standard and approximate solutions
%error is norm of difference between approx and final sols
    be_diff=be_results{i}-sol(:,1:(delta_list(i)/delta_list(N)):end);
     be_err(i)=norm(be_diff(1689,:),inf);
     tr_diff=tr_results{i}-sol(:,1:(delta_list(i)/delta_list(N)):end);
     tr_err(i)=norm(tr_diff(1689,:),inf);
 end
 
 %plot and fit results
figure
hold on
plot(log(T_num),log(be_time),'o')
plot(log(T_num),log(tr_time),'o')
legend('BE','TR')
xlabel('Log of Number of time steps')
ylabel('Log of Computation Time (s)')
title('Computation Time Comparison of Two Methods (Log plot)')
hold off
figure
hold on
plot(log(T_num),log(be_err),'o')
g=fit(log(T_num'),log(be_err'),'poly1')
plot(g,'green');
plot(log(T_num),log(tr_err),'o')
title('Error Convergence Comparison of Two Methods (Log Plot)')
f=fit(log(T_num(1:4)'),log(tr_err(1:4)'),'poly1')
plot(f);
xlabel('Log of Number of time steps')
ylabel('Log of Error')
legend('BE','BE fit','TR','TR fit')
hold off