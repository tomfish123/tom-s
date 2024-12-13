function segmented_LLR = deCode_Block_Cascading(EncodedBit_LLR, Encode_Parameters)
    % 功能：对LLR进行块级联
    % 输入：EncodedBit_LLR, N_seq_segmented
    % 输出：segmented_LLR

    E_RV0 = Encode_Parameters.E_RV0;
    
    row = length(EncodedBit_LLR)/E_RV0;
    segmented_LLR = cell(1,row);
    index_start = 1;
    index_end = E_RV0;
    for i=1:row
        segmented_LLR_Matrix = EncodedBit_LLR(index_start:index_end);
        segmented_LLR{i} = segmented_LLR_Matrix;

        index_start = index_start + E_RV0;
        index_end = index_end + E_RV0;
    end
end