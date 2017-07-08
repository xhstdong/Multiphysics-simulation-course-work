function prima_procedure(G,C,B,L,q)
%prima_procedure performs prima truncation before rearranging the matrices
%into state space formulation

%Input: G,C,B,L are the circuit matrices
%Input: q= order of accuracy of truncation

tic
%perform prima
[G_2,C_2,B_2,L_2,V_2]=prima(G,C,B,L,q);

%arrange into state space formulation
A=-C_2\G_2;
[V,D]=eig(A); %this is now much faster since A is truncated
B_temp=C_2\B_2;
B_temp=V\B_temp;
C_2=C_2\C_2; %identity matrix
L_2=V'*L_2;

%w=logspace(-8,4,500);
%plotFreqResp(w,-D,C_2,B_temp,L_2);
toc


 [ u_time,t,comp_time ]= TR_circuit(-D,C_2,B_temp,0,1,0,1000);
 y=L_2'*t;
plot(u_time,y)
end