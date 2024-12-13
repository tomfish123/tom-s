function [n] = Code_Len_Determination(K, E, n_max, Coding_mode, N_RV0)
%{
    This function is used to calculate the code block's number of bits after encoding.
    input: 
        1. K (the code block's number of bits)
        2. E (the number of bits after rate-matching)
        3. n_max (2^n_max is the max length of the sequence after encoding)
        4. Coding_mode (0 for initial transmission and 1 for retransmission)
        5. N_RV0 (an optional argument--N_RV0 is not empty only when Coding_mode=1, and it means the initial transmission's code block length after encoding)
    output:
        1. n (the code block's number of bits after encoding)
%}
    if nargin < 4
       N_RV0 = 0;
    end
    
    if Coding_mode == 0
       if (E <= (9/8)*2^(ceil(log2(E))-1)) && (K/E < 9/16)
           n_1 = ceil(log2(E))-1;
       else
           n_1 = ceil(log2(E));
       end
       R_min = 1/8;
       n_2 = ceil(log2(K/R_min));
       n_min = 5;  % the minimum code length is 32, the maximum depends on the type of business
       n = max(min([n_1, n_2, n_max]), n_min);
    elseif Coding_mode == 1
       n = log2(N_RV0)+1;
    end   
end

