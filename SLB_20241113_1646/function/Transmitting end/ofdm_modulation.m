function [tx_waveform,judge_coef] = ofdm_modulation(tx_FT_block,frame_Parameter,sys_Parameter)

nfft = sys_Parameter.nfft;
sc_num = sys_Parameter.sc_num;
symbol_num = frame_Parameter.symbol_num;
cp_length = frame_Parameter.cp_length;
gap1_length = frame_Parameter.gap1_length;
gap2_length = frame_Parameter.gap2_length;
frame_type_index = frame_Parameter.frame_type_index;
frames_num = frame_Parameter.frame_num_in_hyperframes;

% OFDM modulation
waveform = ifft([zeros(floor((nfft - sc_num)/2),size(tx_FT_block,2)); ...
    tx_FT_block; ...
    zeros(ceil((nfft - sc_num)/2),size(tx_FT_block,2));],nfft).*sqrt(nfft);

% Add CP
waveform = [waveform(end-cp_length+1:end,:);waveform];

% Parallel transformation
waveform = reshape(waveform,[],1);

% Power normalize
[waveform,judge_coef] = power_normalize(waveform);

% & Add Gap
switch frame_type_index
    case {13,14}
        tx_waveform = waveform;
        return;
    otherwise
        waveform = reshape(waveform,[],frames_num);
        tx_waveform = [waveform(1:(nfft+cp_length)*(frame_type_index+1),:);...
            zeros(gap1_length,frames_num);...
            waveform((nfft+cp_length)*(frame_type_index+1)+1:end,:);...
            zeros(gap2_length,frames_num)];
        tx_waveform = reshape(tx_waveform,[],1);
end





end

