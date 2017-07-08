function [ x,runtime ] = assignment2
%Main function of assignment 2
%   Answers three problems

%part 1: solve last week's circuit using custom LU scheme
%[G,b]=circuit_solver('test_circuit.txt');
%op_amp_v=LU_decomp(G,b);

% %part 2: generate and solve resistor grid
%  runtime=[];
%  N=5;
%  %for N=5:5:50
%  x=zeros([N+1 N+1]);
%  network_gen1(N,N,[0.2,0.2],'circuit.txt',1,[1,0],[0.1;0.01;0.05],[[3,0];[ceil((N+1)^2/2)+1,0];[(N+1)^2-10,0]]);
%  [G,b]=circuit_solver('circuit.txt');
%  G=full(G); %to not exploit sparsity
%  tic
%  grid_v=LU_decomp(G,b);
%  runtime=[runtime,toc];
%  %end
%  for i=1:(N+1)
%      x(i,:)=grid_v(((i-1)*(N+1)+1):(i*(N+1)));
%  end
%  surf(x);

%part 3
%constants
Ka=0.001;
Km=0.1;
V_ambient=400;
V_bc=250; %part a
%I_bc=0; %part b
N=2;
del_x=1/N;
x_val=linspace(0,1,N+1); %I(1)=0
x_val=x_val(2:end); %part a
I=-del_x/Km*50*sin(2*pi*x_val).^2; %part a
%I=-del_x/Km*50*ones(size(x_val)); %part b
Ipos=[linspace(2,N+1,N);zeros([1 N])]; %part a
%Ipos=[linspace(1,N+1,N+1);zeros([1 N+1])]; %part b
R=[del_x, Km/Ka/del_x];
M=1;
x=zeros([M+1 N+1]);
V=zeros([N+3, 1]); %part a 
Vpos=zeros([N+3, 2]); %part a
%Vpos=zeros([N+1, 2]); %part b
for i=1:N+1
   Vpos(i,1)=M*(N+1)+i;
   Vpos(i,2);
end
V(1:(N+1))=V_ambient;
V((N+2):(N+3))=V_bc; %part a
Vpos(N+2,:)=[1, 0]; %part a
Vpos(N+3,:)=[N+1, 0]; %part a
%I=[I,I_bc,I_bc]; %part b
%Ipos_bc=[1, N+1; 2, N]; %part b
%Ipos=[Ipos, Ipos_bc]; %part b

network_gen1(N,M,R, 'circuit.txt', V,Vpos,I',Ipos');
[G,b]=circuit_solver('circuit.txt');
%grid_v=G\b;
grid_v=LU_decomp(G,b);
 for i=1:(M+1)
     x(i,:)=grid_v(((i-1)*(N+1)+1):(i*(N+1)));
 end
 plot([0,x_val],x(1,:)) %part a
 %plot(x_val,x(1,:)); %part b
end

