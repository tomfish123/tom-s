function e = channel_bit_sequence_generate(y, Codingmode, RMmode, K, M, E_RV0, E_RV1)
    % 输入参数：
    % Codingmode: 编码模式 
    % RMmode: 速率匹配模式 (1, 2, 3, 4, 5)
    % M: 信道编码长度
    % ERvo: 第一次传输的编码比特序列长度
    % ERv1: 第二次传输的编码比特序列长度
    % y: 输入比特序列

    if Codingmode == 0 % 初传编码
        e = zeros(1, E_RV0); % 初始化编码比特序列
        if E_RV0 > M
            for k = 0:E_RV0-1
                e(k + 1) = y(mod(k, M) + 1); % 模运算
            end
        else
            if K / E_RV0 <= 7/16 % 打孔处理
                for k = 0:E_RV0-1
                    e(k + 1) = y(k + M - E_RV0 + 1); 
                end
            else    % 缩短
                for k = 0:E_RV0-1 
                    e(k + 1) = y(k + 1); 
                end
            end
        end

    elseif Codingmode == 1 % 重传新编码
        e = zeros(1, E_RV1); 
        if RMmode == 1
            for k = 0:E_RV1-1
                e(k + 1) = y(mod(k, M) + 1); 
            end
        elseif RMmode == 2
            for k = 0:E_RV1-1
                e(k + 1) = y(mod(k + min(E_RV0, M) - E_RV1, M) + 1); 
            end
        elseif RMmode == 3
            for k = 0:E_RV1-1
                e(k + 1) = y(mod(k + M/2 - E_RV1, M/2) + 1); 
            end
        end

    elseif Codingmode == 2 % 重传不编码
        e = zeros(1, E_RV1); 
        if RMmode == 4
            for k = 0:E_RV1-1
                e(k + 1) = y(mod(k + min(E_RV0, M) - E_RV1, M) + 1);
            end
        elseif RMmode == 5
            for k = 0:E_RV1-1
                e(k + 1) = y(mod(k - (E_RV0 + E_RV1 - M), M) + 1); 
            end
        end

    elseif Codingmode == 3 % 重传不编码
        e = zeros(1, E_RV1); 
        if K / E_RV0 > 7/16     %缩短
            for k = 0:E_RV1-1
                e(k + 1) = y(mod(k + (min(E_RV0, M) - E_RV1), min(E_RV0, M)) + 1); 
            end
        elseif K / E_RV0 < 7/16 %打孔
            for k = 0:E_RV1-1
                e(k + 1) = y(mod(k - (E_RV0 + E_RV1 - M), M) + 1); 
            end
        end
    end

end
