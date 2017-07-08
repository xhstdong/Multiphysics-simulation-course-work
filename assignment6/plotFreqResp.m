function plotFreqResp( w,G,C,B,L )
%plotFreqResp calculates and plots the transfer function
%   frequency response of circuit is L'*(G+sC)^-1*B
%   Input: range of frequencies w
%   Input: G,C,B,L are the circuit matrices

s=1i*w;%state space variable
H=zeros(size(w));
for i=1:length(w)
    x=(G+s(i)*C)\B;
    H(i)=L'*x;
end

%plot real component of transfer function
figure (1)
semilogx(w,real(H))
hold on
%xlabel('angular frequency (rad/s), log scale')
%ylabel('Transfer Function, real component')

%plot imaginary component of transfer function
figure (2)
semilogx(w,imag(H))
hold on
%xlabel('angular frequency (rad/s), log scale')
%ylabel('Transfer Function, imaginary component')
end

