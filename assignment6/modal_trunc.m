function  [G_1,C_1,B_1,L_1]=modal_trunc( G,C,B,L,q )
%modal_trunc uses eigenvalue decomposition to reduce the parameter space
%   Input: G,C,B,L are the circuit matrices
%   Input: q is the number of orders we want to preserve
%   Output: G_1, C_1, B_1, L_1 are the reduced circuit matrices


tic
%compute state space matrices
A=-C\G;
B_1=C\B;
%obtain the eigenvectors V and eigenvalue matrix D,
[V,D]=eig(A);
% start from the end of D matrix
max_eig=size(D,2)-q+1;
%apply the eigenvector decompositions
B_1=V\B_1;
L_1=L'*V;

%truncate all matrices
D=D(max_eig:end,max_eig:end);
B_1=B_1(max_eig:end,:);
L_1=L_1(:,max_eig:end);
C_1=eye(size(D));
G_1=-D;
L_1=L_1';

toc
%calculate frequncy response
w=logspace(-8,4,500);
plotFreqResp(w,G_1,C_1,B_1,L_1);
%in the reduced model
%G=-D
%C=C_1=I
%B=B_1
%L=L_1'

end