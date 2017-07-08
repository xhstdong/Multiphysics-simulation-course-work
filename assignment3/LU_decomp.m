function [ x ] = LU_decomp( M,b )
%LU_decomp calculates the solution Mx=b using LU decomposition
%   Input: M,b
%   Output: the solved unknown vector x

thresh=1e-7*max(max(M));%to account for numerical artifats
M_size=size(M);
%swap_hist_row=[1 1]; %keeps track of the amount of pivot changes
swap_hist_col=[1 1];
singular_flag=0;

for row=1:(M_size(1)-1)
    col=row;
    if abs(M(row,col))<=thresh%pivot switching needed
        %search for suitable row replacement
        found_flag=0;
        new_row=row+1;
        while found_flag==0 && new_row<=M_size(1)
            if abs(M(new_row,col))>=thresh 
                %new non zero pivot found
                found_flag=1;
                M([row new_row],:)=M([new_row row],:); %swap rows
                b([row new_row])=b([new_row row]);
                %swap_hist_row=[swap_hist_row; row, new_row];
            end
            new_row=new_row+1;
        end
        if found_flag==0 %if no suitable row found
            %look for suitable columns
            new_col=col+1;
            while found_flag==0 && new_col<=M_size(2)
                if abs(M(row,new_col))>=thresh
                    found_flag=1;
                    M(:,[col new_col])=M(:,[new_col col]);
                    swap_hist_col=[swap_hist_col; col, new_col];
                end
                new_col=new_col+1;
            end
        end
        if found_flag==0 
            %if no suitable row or column exist, this matrix may not be
            %invertible
            singular_flag=1;
           % display('Warning: Matrix may be singular');
        end
    end

    M((row+1):M_size(1),col)= M((row+1):M_size(1),col)/M(row,col);
    for index=(col+1):M_size(2)
       M((row+1):M_size(1),index)=M((row+1):M_size(1),index)-M(row,index)*M((row+1):M_size(1),col);
    end

end
if singular_flag==1
     display('Warning: Matrix may be singular');
end
U=triu(M);
L=tril(M,-1)+eye(M_size); %by convention

%matrix operations
%forward substitution to find y=L\b
%y=L\b;
y=zeros(M_size(1),1);
y(1)=b(1);
for i=2:M_size(1)
    y(i)=b(i)-L(i,1:(i-1))*y(1:(i-1));% L(i,i)is always 1
end

%backward substitution to find x=U\y
%x=U\y;
x=zeros(M_size(1),1);
x(M_size(1))=y(M_size(1))/U(M_size(1),M_size(2));
for i=(M_size(1)-1):-1:1
    x(i)=(y(i)-U(i,(i+1):M_size(2))*x((i+1):M_size(1)))/U(i,i);
end

%switch back the switched columns
changed_size=size(swap_hist_col);
for i=2:changed_size(1)
    % the first row is garbage initialization
    x([swap_hist_col(i,1) swap_hist_col(i,2)])= x([swap_hist_col(i,2) swap_hist_col(i,1)]);
end

end
