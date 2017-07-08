function [x,error,reg_timing,reg_iter,cond_timing,cond_iter,runtime]=assignment3
%Main function of assignment 3
%   May return the following outputs, depending on which section of
%   assignment:
%   x, the circuit solution
%   the iteration error, for the iterative methods
%   reg_timing and reg_iter, time and iteration 
%   to convergence for non-conditioned case
%   cond_timing and cond_iter, time and iteration to convergence for
%   conditioned case
%   runtime, time to solve matrix for LU decomposition

epsilon=10^-3;
error=0;
%op_amp_v=cg_optimization(x_0,G,b,epsilon,maxiter);

%part b
% N=40;
%      R=[0.1 0.1 10^6 0.1];
%      V=2;
%      Vpos=[(N+1)^2+1 0];
%      Vpos=[1,0];
%      I=[0.1;0.01; 0.05];
%  reg_timing=zeros([1 10]);
%  reg_iter=zeros([1 10]);
%  runtime=zeros([1 10]);
%  cond_timing=reg_timing;
%  cond_iter=reg_iter;
%  index=1;
% for N=5:5:50
%      maxiter=(N+1)^2+10;
%      Ipos=[[3,0];[ceil((N+1)^2/2)+1,0];[(N+1)^2-10,0]];
%      filepath='circuit.txt';
%      network_gen1(N,N,R,filepath,V,Vpos,I,Ipos);
%      [G,b]=circuit_solver('circuit.txt');
     %G=full(G);
%     tic
%     x=LU_decomp(G,b);
%     runtime(index)=toc;
%     %eigenval=eig(G);
%     %cond_num=cond(G);
%     x_0=ones([size(G,2) size(b,2)]);
 %    P=diag(diag(G,0))+diag(diag(G,1),1)+diag(diag(G,-1),-1); %tridiagonal conditioner
%     tic
%     [x,error,reg_iter(index)]=cg_optimization(x_0,G,b,epsilon,maxiter);
%     reg_timing(index)=toc;
%     tic
%     [x,error,cond_iter(index)]=cg_optimization(x_0,G,b,epsilon,maxiter,P);
%     cond_timing(index)=toc;
%     index=index+1;
% end

%part h,i,j
N=20;
maxiter=(N+1)^2+10;
Ipos=[[3,0];[ceil((N+1)^2/2)+1,0];[(N+1)^2-10,0]];
filepath='circuit.txt';
R_grid=[0.1,1,10];
for index=1:3
    R=[R_grid(index) R_grid(index) 10^6 0.1];
    network_gen1(N,N,R,filepath,V,Vpos,I,Ipos);
    [G,b]=circuit_solver('circuit.txt');
    G=full(G);
    %gershgorin_circ(G);
    P=diag(diag(G,0))+diag(diag(G,1),1)+diag(diag(G,-1),-1);
    x_0=ones([size(G,2) size(b,2)]);
    [x,error,reg_iter(index)]=cg_optimization(x_0,G,b,epsilon,maxiter);
    figure (1)
    hold on
    plot(error)
    %gershgorin_circ(P^-0.5*G*P^-0.5);
    [x,error,reg_iter(index)]=cg_optimization(x_0,G,b,epsilon,maxiter,P);
    figure (2)
    hold on
    plot(error)
end
figure (1)
legend('R=0.1','R=1','R=10');
figure (2)
legend('R=0.1','R=1','R=10');

end