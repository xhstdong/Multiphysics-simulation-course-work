% generate the GCBL matrices of assignment 6
%this is step one of the assignment
N=500;
alpha=0.01;
del_x=1/N;
%C=spdiags(del_x^2*ones([N 1]),0,N,N);
C=diag(del_x^2*ones([N 1]),0);
G=spdiags(ones([N 1])*[-1 2+alpha*del_x^2 -1],[-1,0,1],N,N);
G=full(G);
G(1,1)=1+alpha*del_x^2;
G(N,N)=1+alpha*del_x^2;
B=zeros([N,1]);
B(1)=del_x^2;
%B=sparse(B);
L=zeros([N,1]);
L(end)=1;
%L=sparse(L);