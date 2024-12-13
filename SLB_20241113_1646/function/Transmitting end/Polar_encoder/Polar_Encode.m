function [d] = Polar_Encode(N, u)
%{
    This function is used to calculate the code block's number of bits after encoding.
    input: 
        1. N (the code block's length after encoding)
        4. u (the input bit sequences set for encoder)
    output:
        1. d (the output bit sequences set of encoder)
%}
    
    % obtain matrix G
    G_2 = [1 0; 1 1];
    G_N = G_2;
    for i = 1:log2(N)-1
        G_N = kron(G_N,G_2);
    end
    d = mod(u*G_N, 2);
end

