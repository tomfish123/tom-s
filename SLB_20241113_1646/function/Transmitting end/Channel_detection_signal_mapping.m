function tx_FT_block = Channel_detection_signal_mapping(tx_FT_block,sys_Parameter,frame_Parameter,index)

if(isempty(index.dection_frame))
    return;
end

symbol_num              =   frame_Parameter.symbol_num;
n_subcarriers           =   sys_Parameter.sc_num;
G_node_identification   =   frame_Parameter.G_node_identification;
symbol_type             =   frame_Parameter.symbol_type;
num_frames              =   frame_Parameter.frame_num_in_hyperframes;
%%单天线的情况（多天线加个判断条件即可）

% 遍历每个无线帧
for n = 0:num_frames-1

    l = index.dection_symbol{1,n+1}(1);
    % 生成伪随机 QPSK 序列
    r_nl = qpsk_random_seq(G_node_identification, n, l, symbol_type, n_subcarriers);

    % 遍历每个子载波 k
    for k = 1:n_subcarriers
        % 根据条件赋值到 tx_FT_block
        if k == 81
            tx_FT_block(k, l + n * symbol_num) = 0;  % 当 k=80 时，赋值为 0
        else
            tx_FT_block(k, l + n * symbol_num) = r_nl(k);  % 其他情况下赋值为 r_{n, l}(k)
        end
    end

end



end

