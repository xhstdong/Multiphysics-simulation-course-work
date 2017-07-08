%%
%this script tests the simple fuzz circuit as seen in fuzz.txt
%Appears to give reasonable result when dx is limited to less than dx_max
%in Newton_Trap function
clear;

filename = 'fuzz.txt';

% parse netlist
[G,C,b,B,H,Q,D] = NodalAnalysisTransientNonlinear(filename);


% Newton method parameters
%epsilon = 1e-10;
epsilon = 1e-5;
NiterMax = 10000;

% size of G matrix
N = size(G,2);
x0 = zeros(N,1); % first initial guess

% sources
%  t = 0:1e-6:0.005;
%  f = 400;
%  A = 0.001;
%  u(2,:) = A*sin(2*pi*f*t); % AC input
[t,V,FS]=Wave_Read('guitar_sam.wav');
t=t(1:floor(length(t)/3));
u(2,:)=V(1:length(t),1)'/10; %scale by 10
Vcc = 5;
u(1,:) = Vcc*ones(1,length(u(2,:))); % DC biasing
%note: DC source always provided before AC source

% need to set the element of b that should be varied for cases with mixed
% DC and AC sources
srcNode = 3; 

x  = Newton_Trap( G,H,C,B,D,Q,u,t,NiterMax,epsilon,x0,N,0 );
%Wave_Write(x(5,:),FS); 
% [ x ] = timeStepSimple( G,H,b,u,srcNode,D,N,NiterMax,epsilon );
% x  = timeStepSimple2( G,H,b,u,srcNode,D,Q,N,NiterMax,epsilon );

figure;
hold all;
plot(t,x(1,:));
plot(t,x(5,:)); % output
grid on;
xlabel('Time')
ylabel('Voltage')
legend('Input','Output')







