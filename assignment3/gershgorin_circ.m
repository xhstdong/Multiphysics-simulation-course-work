function  gershgorin_circ( M )
%gershgorin_circ calculates and plots the Gershgorin circles and
%eigenvalues
%  Input: matrix M
%   output: none
figure
hold on
for i=1:size(M,1)
    % center of circle
    x=real(M(i,i)); y=imag(M(i,i)); 

    % radius=sum of the norm of the elements where i != j
    R=0;
    for j=1:size(M,2)
       if i ~= j 
           R=R+(norm(M(i,j)));
       end    
    end 
    
    % plot circle
    N=256;
    theta=linspace(0,N,N+1)*2*pi/N;
    plot( R*cos(theta)+x, R*sin(theta)+y ,'-');

end

axis equal;

% plot eigenvalues
eigenval=eig(M);
for i=1:size(eigenval)
    plot(real(eigenval(i)),imag(eigenval(i)),'ro');
end
hold off;

end

