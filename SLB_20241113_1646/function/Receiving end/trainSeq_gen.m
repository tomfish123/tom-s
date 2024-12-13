function fsts_n = trainSeq_gen(u12,seq_sel)
%TRAINSEQ_GEN  生成训练序列
%   seq_sel 选择1fts 还是2 sts
    % u1 = 1,160 u2 = 1,...,20
    fsts_n = zeros(161,1);
    for i = 0:160
        if(seq_sel == 1 &&(i <= 79 || i >= 80))
            fsts_n(i+1) = exp(-1j*pi*u12*i*(i+1)/161);
        end
        if(seq_sel == 2 && mod(i,8)==0 &&(i <= 72 || i >= 88))
            fsts_n(i+1) = exp(-1j * pi*u12*i/8.0*(i/8.0+1)/21);
        end
    end
end