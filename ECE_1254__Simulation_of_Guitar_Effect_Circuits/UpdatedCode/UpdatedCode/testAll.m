%%
clear;

filename = 'halfWaveRect.txt';

% parse netlist
[G,C,b,B,H,Q,D] = NodalAnalysisTransientNonlinear(filename);


% Newton method parameters
epsilon = 1e-10;
NiterMax = 2000;

% size of G matrix
N = size(G,2);
x0 = zeros(N,1); % first initial guess

% source
t = 0:1e-4:0.15;
f = 60;
A = 10;
u = A*sin(2*pi*f*t);


% need to set the element of b that should be varied for cases with mixed
% DC and AC sources
srcNode = 3; 

x  = Newton_Trap( G,H,C,B,D,Q,u,t,NiterMax,epsilon,x0,N,0 );
 
% [ x ] = timeStepSimple( G,H,b,u,srcNode,D,N,NiterMax,epsilon );
% x  = timeStepSimple2( G,H,b,u,srcNode,D,Q,N,NiterMax,epsilon );

figure;
hold all;
plot(t,x(1,:));
plot(t,x(2,:)); % half wave recitifier
grid on;
xlabel('Time')
ylabel('Voltage')
legend('Input','Output')

%%
clear;

filename = 'bridgeRect.txt';

% parse netlist
[G,C,b,B,H,Q,D] = NodalAnalysisTransientNonlinear(filename);


% Newton method parameters
epsilon = 1e-10;
NiterMax = 2000;

% size of G matrix
N = size(G,2);
x0 = zeros(N,1); % first initial guess

% source
t = 0:1e-4:0.15;
f = 60;
A = 10;
u = A*sin(2*pi*f*t);

% need to set the element of b that should be varied for cases with mixed
% DC and AC sources
srcNode = 3; 

x  = Newton_Trap( G,H,C,B,D,Q,u,t,NiterMax,epsilon,x0,N,0 );
 
% [ x ] = timeStepSimple( G,H,b,u,srcNode,D,N,NiterMax,epsilon );
% x  = timeStepSimple2( G,H,b,u,srcNode,D,Q,N,NiterMax,epsilon );

figure;
hold all;
plot(t,x(1,:));
plot(t,x(2,:)-x(3,:)); %
grid on;
xlabel('Time')
ylabel('Voltage')
legend('Input','Output')


%%
% try a transistor circuit

clear;

filename = 'CEsimple1.txt';

% parse netlist
[G,C,b,B,H,Q,D] = NodalAnalysisTransientNonlinear(filename);

x = G\b;


% Newton method parameters
epsilon = 1e-10;
NiterMax = 2000;

% size of G matrix
N = size(G,2);
x0 = zeros(N,1); % first initial guess

% sources
t = 0:1e-6:0.02;
f = 1e3;
A = 0.2;
u(2,:) = A*sin(2*pi*f*t); % AC input

Vcc = 9;
u(1,:) = Vcc*ones(1,length(u(2,:))); % DC biasing


% need to set the element of b that should be varied for cases with mixed
% DC and AC sources
% srcNode = 3; 

x  = Newton_Trap( G,H,C,B,D,Q,u,t,NiterMax,epsilon,x0,N,0 );
 
% [ x ] = timeStepSimple( G,H,b,u,srcNode,D,N,NiterMax,epsilon );
% x  = timeStepSimple2( G,H,b,u,srcNode,D,Q,N,NiterMax,epsilon );


figure;
hold all;
plot(t,x(1,:));
plot(t,x(4,:)); %
% plot(t,x(2,:)-x(1,:));
grid on;
xlabel('Time')
ylabel('Voltage')
legend('Input','Output')


















