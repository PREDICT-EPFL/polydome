function Hankel = compute_Hankel_matrix(x,nx,Hankel_row, Hankel_col)
%COMPUTE_HANKEL_MATRIX 
    % Build Hankel matrix by x vector sequences

    if Hankel_row+Hankel_col-1 ~= size(x,2)
        error("The length of history data is wrong!")
    end
    Hankel = zeros(nx*Hankel_row, Hankel_col);
    for i = 1:Hankel_row
        Hankel((i-1)*nx+1:i*nx,:) = x(:,i:i+Hankel_col-1);
    end
end


