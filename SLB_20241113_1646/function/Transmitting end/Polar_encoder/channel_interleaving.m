function output_bits = channel_interleaving(input_bits, E)
    % 输入:
    % input_bits: 输入比特序列
    % E: 速配匹配参数
    
    % 输出:
    % output_bits: 交织后的输出比特

    % 初始化输出比特矩阵
    v = NaN(14,ceil(E/14)); % 使用 NaN 作为 NULL 的标记
    output_bits = zeros(E,1);
    
    % 第一部分交织
    k = 0; % 初始化 k
    for i = 0:13
        for j = 0:(ceil(E/14) - 1)
            if k < E
                v(i+1, j+1) = input_bits(k+1); % 注意 MATLAB 索引从 1 开始
            end
            k = k + 1;
        end
    end

    % 第二部分交织
    k = 0; % 重新初始化 k
    for j = 0:(ceil(E/14) - 1)
        for i = 0:13
            if ~isnan(v(i+1, j+1))
                output_bits(k+1) = v(i+1, j+1);
                k = k + 1;
            end
        end
    end

end
