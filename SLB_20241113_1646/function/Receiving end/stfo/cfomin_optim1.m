function [cfo_est] = cfomin_optim1(recv_add,sto_est,cp_num,cfocase)
% 小数倍频偏估计方法
% 输入：
%   recv 接收信号
%   subcarrier_spacing 子载波间隔
%   dt T_s
%   u1 fts序列 u值
%   u2 sts序列 u值
%   cfocase 1:基于CP的小数频偏估计 2：基于重复FTS的小数频偏估计 3：基于重复FTS+CP的小数频偏估计 4:基于重复STS的小数频偏估计

% 输出：
%   cfo_est 估计的小数cfo
fft_len = 256;
sts_len = 32;
switch cfocase
    case 1
        cp1_begin = sto_est+fft_len+cp_num+1;
        cp1 = recv_add(cp1_begin:cp1_begin+cp_num-1);
        cp2 = recv_add(cp1_begin+fft_len:cp1_begin+cp_num+fft_len-1);
        cp_all = sum(cp1.*conj(cp2));
        cfo_est = -angle(cp_all)/(2*pi);
    case 2
        fts1_begin = sto_est+fft_len+2*cp_num+1;
        fts1 = recv_add(fts1_begin:fts1_begin+fft_len-1);
        fts2 = recv_add(fts1_begin+fft_len+cp_num:fts1_begin+fft_len+cp_num+fft_len-1);
        fts_all = sum(fts1.*conj(fts2));
        cfo_est = -angle(fts_all)/(2*pi)*fft_len/(cp_num+fft_len);
    case 3
        cp1_begin = sto_est+fft_len+cp_num+1;
        fts_cp1 = recv_add(cp1_begin:cp1_begin+fft_len+cp_num-1);
        fts_cp2 = recv_add(cp1_begin+fft_len+cp_num:cp1_begin+fft_len+cp_num+fft_len+cp_num-1);
        fts_cp_all = sum(fts_cp1.*conj(fts_cp2));
        cfo_est = -angle(fts_cp_all)/(2*pi)*fft_len/(cp_num+fft_len);
    case 4
        sts1_begin = sto_est+cp_num+1;
        sts_angle = zeros(7,1);

        for i=0:6
            sts1 = recv_add(sts1_begin+i*sts_len:sts1_begin+(i+1)*sts_len-1);
            sts2 = recv_add(sts1_begin+(i+1)*sts_len:sts1_begin+(i+2)*sts_len-1);
            sts_angle(i+1) = angle(sum(sts1.*conj(sts2)))/(2*pi)*fft_len/(sts_len);
        end
        cfo_est = -(sum(sts_angle)/7-1);%为什么-1有待研究
end



end