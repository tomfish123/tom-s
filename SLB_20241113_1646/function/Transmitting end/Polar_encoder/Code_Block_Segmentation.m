function [B_seq_segmented] = Code_Block_Segmentation(B_seq, R)
%{
    This function is used to segment the input sequence into code blocks.
    input: 
        1. B_seq (the input bit sequence, and its length is B=K+L)
        2. R (the target code rate)
    output:
        1. B_seq_segmented (is a cell variable, which means the segmented input bit sequence)
%}

    K_cb = ceil(4096*R/8)*8;  % length of the biggest code block
    
    % obtain the number of code blocks C
    if length(B_seq) <= K_cb
        L = 0;
        C = 1;
        B = length(B_seq);
    else
        L = 24;
        C = ceil(length(B_seq)/(K_cb-L));
        B = length(B_seq)+C*L;
    end
    
    % obtain the segmented result
    K = ceil(B/C);  % length of every code block
    B_seq_segmented = {};
    crcGen = comm.CRCGenerator('Polynomial',[1 1 0 1 1 0 0 1 0 1 0 1 1 0 0 0 1 0 0 0 1 0 1 1 1]);  % make a CRC generator based on generating polynomial
    for r = 1:C
        if r <= C-1
            B_n = B_seq((r-1)*(K-L)+1:r*(K-L));
        elseif r == C
            B_n = B_seq((C-1)*(K-L)+1:end);  % the last code block
        end
        if C > 1
            B_n = crcGen(B_n');  
        end
        B_seq_segmented = [B_seq_segmented B_n'];
    end
    % add zeros for rate-matching of the last code block
    B_seq_segmented{C} = [zeros([1, K-length(B_seq_segmented{C})]) B_seq_segmented{C}];
end

