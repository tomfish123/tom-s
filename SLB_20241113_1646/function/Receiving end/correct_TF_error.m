function rx_waveform = correct_TF_error(rx_waveform,sto_est,cfo_est,time_offset,sys_Parameter,SNR)

subcarrier_spacing = sys_Parameter.subcarrier_spacing;
dt = sys_Parameter.dt;

% get sampling point for time synchronization
rx_waveform(1:sto_est) = [];
if(sto_est ~= time_offset)
    if(sto_est > time_offset)
        rx_waveform = [rx_waveform;awgn(zeros(sto_est-time_offset,1),SNR)];
    else
        rx_waveform(end-(time_offset-sto_est)+1:end) = [];
    end
end

% CFO correct
frequency_offset_esti = cfo_est*subcarrier_spacing;
rx_waveform = rx_waveform .* exp(-1i*2*pi*frequency_offset_esti*(0:length(rx_waveform)-1)*dt).';




end

