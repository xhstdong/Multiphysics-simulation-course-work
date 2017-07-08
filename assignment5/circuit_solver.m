function [ G,C_mat,B,u ] = circuit_solver( file_path )
%circuit_solver solves a circuit using MNA
%   Input: file path of the text file containing circuit info in standard
%   SPICE format.e.g. 'test_circuit.txt'
%   Ouput: the solution vector x
%   Currently it can calculate resistors, independent current sources,
%   independent voltage sources, capacitors, inductors and dependent
%   voltage sources

%get data
[R,I,V,E,C,L]=extract_data(parse(file_path));

N=0;
%find number of nodes (excluding ground)
if size(R)~=[0,0]
    N=max([max(R(:,1)),max(R(:,2))]);
end
if size(I)~=[0,0]
    Imax=max([max(I(:,1)),max(I(:,2))]);
    N=max([N,Imax]);
end
if size(V)~=[0,0]
    Vmax=max([max(V(:,1)),max(V(:,2))]);
    N=max([N,Vmax]);
end
if size(E)~=[0,0]
    Emax=max([max(E(:,1)),max(E(:,2))]);
    N=max([N,Emax]);
end
if size(C)~=[0,0]
    Cmax=max([max(C(:,1)),max(C(:,2))]);
    N=max([N,Cmax]);
end
if size(L)~=[0,0]
    Lmax=max([max(L(:,1)),max(L(:,2))]);
    N=max([N,Lmax]);
end

%construct G matrix and b vector
%G=zeros(N);

G=sparse(N,N);
B=zeros(N,1);
C_mat=G;

%add resistors
G=resistor_calc(R,G);
%add current sources
[B,u]=is_calc(I,B);
%add capacitors
C_mat=cap_calc(C,C_mat);
%add inductors
[G,C_mat,B]=L_calc(L,G,C_mat,B);
%add voltage sources;
[G,C_mat,B,u]=vs_calc(V,G,C_mat,B,u);
[G,C_mat,B]=es_calc(E,G,C_mat,B);


%solve
%x=G\b;

end

