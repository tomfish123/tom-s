function [fts_k_all,sts_k_all] = trainSeq_t_gen_All()
%接收端全部训练序列 时域生成
    % sym_cp_length = [18,39,64,128,0];

    fts_k_all = zeros(256,2);
    u1s = [1,160];
    for i = 1:2
        fts_cur = trainSeq_gen(u1s(i),1);
        fts_k_all(:,i) = seq_t_gen(fts_cur);
    end

    sts_k_all = zeros(256,20);
    for i = 1:20
        sts_cur = trainSeq_gen(i,2);
        sts_k_all(:,i)  =seq_t_gen(2*sqrt(2)*sts_cur);
    end
    
end