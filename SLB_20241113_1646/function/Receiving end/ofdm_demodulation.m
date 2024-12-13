function rx_TF_block = ofdm_demodulation(rx_waveform,judge_coef,sys_Parameter,frame_Parameter,index)

nfft = sys_Parameter.nfft;
cp_length = frame_Parameter.cp_length;

rx_waveform = rx_waveform .* judge_coef;

% delete gap1/2
rx_waveform([index.gap1_time;index.gap2_time]) = [];

% delete CP
rx_waveform = reshape(rx_waveform,nfft+cp_length,[]);
rx_waveform(1:cp_length,:) = [];

% ofdm demod
rx_TF_block = fft(rx_waveform./sqrt(nfft),nfft);
rx_TF_block = rx_TF_block(index.sc,:);
% rx_TF_block = reshape(rx_TF_block,sys_Parameter.sc_num,frame_Parameter.symbol_num,[]);




end

