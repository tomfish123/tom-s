function H_est = channel_estimate(tx_TF_block,rx_TF_block,SNR,sys_Parameter,frame_Parameter,index)

equ_type = sys_Parameter.equ_type;
symbol_num = frame_Parameter.symbol_num;
sc_num = sys_Parameter.sc_num;
nfft = sys_Parameter.nfft;
cp_length = frame_Parameter.cp_length;
pilot_type = frame_Parameter.data_demod_ref_type;

switch pilot_type
    case 'continuous'
        N_comb = 1;%1表示连续导频
        pilot_loc = [1 : 80,82 : sc_num];% 导频在一个符号中的位置
    case 'pectinate'
        N_comb = 2;%2表示梳状导频
        pilot_loc = 1:2:161;% 导频在一个符号中的位置
        pilot_loc(pilot_loc == 80) = 0;
    otherwise
        error('wrong pilot type');
end


rx_pilot_symbol = get_symbol(rx_TF_block,frame_Parameter,index,'status_ref');
tx_pilot_symbol = get_symbol(tx_TF_block,frame_Parameter,index,'status_ref');

H_est = [];
for i = 1:size(rx_pilot_symbol,2)
    Xp = tx_pilot_symbol(:,i);
    % H_est 每一列对应一个frame的频域信道
    % 信道估计方法类型 'LS_linear', 'LS_spline', 'ML_linear', 'ML_spline' 'MMSE'
    H_est = [H_est, Channel_Est(rx_pilot_symbol(:,i), Xp, pilot_loc, ...,
        nfft, sc_num, cp_length, N_comb, ...,
        index.low_freq_zero, index.high_freq_zero, SNR, equ_type)];
end






end

