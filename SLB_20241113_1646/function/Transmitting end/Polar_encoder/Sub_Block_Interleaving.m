function [Y_M, J] = Sub_Block_Interleaving(M, D_M)
%{
    This function will be used in the first step of rate matching - sub-block interleaving.
    input: 
        1. M (length of the input bit sequence)
        2. D_M (input bit sequence for sub-block interleaving, whose length is M)
    output:
        1. Y_M (output bit sequence for sub-block interleaving, whose length is M too)
        2. J (an intermediate parameter of sub-block interleaving, which will be used later to obtain the bit index of polar coding)
    README:
        1.if don't input D_M, then our objective is just to get J for later obtaining the bit index of polar coding.
%}
    
    if nargin < 2
       D_M = zeros([1, M]);
    end
    
    load('Table_8.mat');
    Y_M = zeros([1, M]);
    J = zeros([1, M]);
    for m = 1:M
        i = floor(32*(m-1)/M);
        J(m) = Table_8(i+1, 2)*(M/32)+mod(m-1, M/32)+1;
        Y_M(m) = D_M(J(m));
    end
    
end

