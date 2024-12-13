function deinterleaved_LLR = deChannel_interleave(segmented_LLR, E)
    % 功能：解信道交织
    % 输入：segmented_LLR
    % 输出：deinterleaved_LLR

    % 初始化输出比特矩阵
    v = NaN(14,ceil(E/14)); % 使用 NaN 作为 NULL 的标记
    output_bits = zeros(E,1);

    % 第一部分交织
    k = 0; % 初始化 k
    for i = 0:13
        for j = 0:(ceil(E/14) - 1)
            if k < E
                v(i+1, j+1) = 1; 
            end
            k = k + 1;
        end
    end

    % 第二部分交织
    k = 0; % 重新初始化 k
    for j = 0:(ceil(E/14) - 1)
        for i = 0:13
            if ~isnan(v(i+1, j+1))
                v(i+1, j+1) = segmented_LLR(k+1); % 注意 MATLAB 索引从 1 开始
                k = k + 1;
            end 
        end
    end
    
    % 第一部分交织
    k = 0; % 初始化 k
    for i = 0:13
        for j = 0:(ceil(E/14) - 1)
            if ~isnan(v(i+1, j+1))
                output_bits(k+1) = v(i+1, j+1);
                k = k + 1;
            end
        end
    end

    deinterleaved_LLR = output_bits; 
end