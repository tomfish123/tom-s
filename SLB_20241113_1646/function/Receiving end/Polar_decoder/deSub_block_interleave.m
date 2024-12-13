function sub_block_deinterleaved_LLR = deSub_block_interleave(punctured_LLR, M)
    % 功能：解子块交织
    % 输入：punctured_LLR
    % 输出：sub_block_deinterleaved_LLR
    
    D_M = 1:M;
    [Y_M, ~] = Sub_Block_Interleaving(M, D_M);
    [~,B] = sort(Y_M);
    sub_block_deinterleaved_LLR = punctured_LLR(B);

end