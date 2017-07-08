function [ G,b ] = circuit_solver( file_path )
%circuit_solver solves a circuit using MNA
%   Input: file path of the text file containing circuit info in standard
%   SPICE format.e.g. 'test_circuit.txt'
%   Ouput: the solution vector x
%   Currently it can calculate resistors, independent current sources,
%   independent voltage sources, and dependent voltage sources

%get data
[R,I,V,E]=extract_data(parse(file_path));

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

%construct G matrix and b vector
%G=zeros(N);

G=sparse(N,N);
b=zeros(N,1);

%add resistors
G=resistor_calc(R,G);
%add current sources
b=is_calc(I,b);
%add voltage sources;
[G,b]=vs_calc(V,G,b);
[G,b]=es_calc(E,G,b);

%solve
%x=G\b;

end

