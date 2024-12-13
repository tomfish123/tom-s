function [tx_FT_block, index] = Ch_st_ref_sig_mapping(tx_FT_block, sys_Parameter, frame_Parameter, index)

    symbol_num              = frame_Parameter.symbol_num;
    n_subcarriers           = sys_Parameter.sc_num;
    G_node_identification   = frame_Parameter.G_node_identification;
    symbol_type             = frame_Parameter.symbol_type;
    num_frames              = frame_Parameter.frame_num_in_hyperframes;
    ref_frame               = index.ref_frame;
    ref_symbol              = index.ref_symbol;

    % 单天线的情况（多天线加个判断条件即可）
    % 索引是否为空判断 
    if isempty(ref_frame)
        % disp('状态参考索引为空，本超帧无状态参考信号');
        return; 
    end

    % 遍历每个无线帧
    for n = 1:length(ref_frame)
        current_frame = ref_frame(n);  % 当前无线帧索引
          % 当前无线帧中有内容的符号索引

        % 遍历当前无线帧的每个符号位置
        for l = 1:length(ref_symbol{n})
        symbols_in_frame = ref_symbol{n}(l);
        % 生成伪随机 QPSK 序列
        r_nl = qpsk_random_seq(G_node_identification, current_frame-1, symbols_in_frame-1, symbol_type, n_subcarriers);
        
        % 赋值为 r_nl
        tx_FT_block(:, symbols_in_frame + (current_frame - 1) * symbol_num) = r_nl;
            
        % 处理特殊情况，当 k = 81 时，赋值为 0
        tx_FT_block((n_subcarriers+1)/2, symbols_in_frame + (current_frame - 1) * symbol_num) = 0;
        end
    end
end
