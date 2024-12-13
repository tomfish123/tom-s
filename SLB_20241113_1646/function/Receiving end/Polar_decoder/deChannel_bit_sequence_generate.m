function punctured_LLR = deChannel_bit_sequence_generate(deinterleaved_LLR, Codingmode, E_RV0, K, M)
    % 功能：解打孔、缩短、重复
    % 输入：deinterleaved_LLR
    % 输出：punctured_LLR
    
    deinterleaved_LLR = deinterleaved_LLR';

    if Codingmode == 0 % 初传编码
        if E_RV0 > M
            punctured_LLR = deinterleaved_LLR(1:M); %重复
        else
            if K / E_RV0 <= 7/16 % 打孔处理
                punctured_LLR = [10^10*ones(1, M-E_RV0) deinterleaved_LLR];
            else    % 缩短
                punctured_LLR = [deinterleaved_LLR  10^10*ones(1, M-E_RV0)];
            end
        end

    elseif Codingmode == 1 % 重传新编码

    elseif Codingmode == 2 % 重传不编码

    elseif Codingmode == 3 % 重传不编码

    end



end