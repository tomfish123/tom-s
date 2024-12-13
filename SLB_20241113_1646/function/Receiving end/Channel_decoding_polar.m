function [data_output,bit_decoded] = Channel_decoding_polar(EncodedBit_LLR, Encode_Parameters)

    K = Encode_Parameters.K;
    M = Encode_Parameters.M;
    Q_N_I = Encode_Parameters.Q_N_I;
    E_RV0 = Encode_Parameters.E_RV0;
    C = Encode_Parameters.C;

    EncodedBit_LLR(isinf(EncodedBit_LLR) & EncodedBit_LLR < 0) = -10^10;
    EncodedBit_LLR(isinf(EncodedBit_LLR)) = 10^10;
    %解扰
    c = generate_gold_sequence(E_RV0*C);
    scrambling_sequence = 1 - 2 * c;
    if length(EncodedBit_LLR) > E_RV0*C
        EncodedBit_LLR= EncodedBit_LLR(1:E_RV0*C);
    end
    descrambled_LLR = EncodedBit_LLR .* scrambling_sequence';
    

    % 解码块级联
    segmented_LLR = deCode_Block_Cascading(descrambled_LLR, Encode_Parameters);
    
    C = length(segmented_LLR);
    
    bit_decoded = cell(1,C);
    for i = 1:C
        % 解信道交织
        E_RV0 = Encode_Parameters.E_RV0;
        deinterleaved_LLR = deChannel_interleave(segmented_LLR{i}, E_RV0);
        
        % 解打孔、缩短、重复
        punctured_LLR = deChannel_bit_sequence_generate(deinterleaved_LLR, Encode_Parameters.Coding_mode, E_RV0, K, M);
        
        % 解子块交织
        sub_block_deinterleaved_LLR = deSub_block_interleave(punctured_LLR, M);
        
        % 译码
        bit_decoded{i} = deCoding_SCL(sub_block_deinterleaved_LLR, sort(Q_N_I));
    end
    
    % 码块级联
    bit_decoded_temp = bit_decoded;
    if C > 1
        for i = 1:C
            bit_decoded_temp{i} = bit_decoded_temp{i}(1:end-24);
        end
    end
    data_output = [];
    for i = 1:C
        data_output = [data_output, bit_decoded_temp{i}];  % 组合成一个向量
    end
    data_output = data_output(1:end-24);
    data_output = data_output';
    
end





