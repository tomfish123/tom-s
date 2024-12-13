function rx_waveform = through_channel(tx_waveform,SNR,sys_Parameter,frame_Parameter)

channel_type = sys_Parameter.channel_type;
delay_spread = sys_Parameter.delay_spread;
samp_rate = sys_Parameter.sample_rate;
max_fd = sys_Parameter.velocity * 2.4e9 /3e8;
sc_num = sys_Parameter.sc_num;
nfft = sys_Parameter.nfft;
TransmissionDirection = frame_Parameter.transmissionDirection;

switch channel_type
    case 'AWGN'
        rx_waveform = tx_waveform;
    case {'TDL-A','TDL-B','TDL-C','TDL-D','TDL-E'}
        channel = nrTDLChannel('DelayProfile',channel_type,...
            'DelaySpread',delay_spread,...
            'SampleRate',samp_rate,...
            'MaximumDopplerShift',max_fd, ...
            'NumTransmitAntennas',1,...
            'NumReceiveAntennas',1,...
            'Seed',randi([1 1e6]));


        channelInfo = info(channel);
        channelFilterDelay = channelInfo.ChannelFilterDelay;
        tx_waveform = [tx_waveform; zeros(channelFilterDelay, 1)];
        rx_waveform = channel(tx_waveform);
        rx_waveform = rx_waveform(1+channelFilterDelay:end);%消除抽头延迟

    case {'Model-A','Model-B','Model-C','Model-D','Model-E','Model-F'}

        channel = wlanTGaxChannel("CarrierFrequency",sys_Parameter.carrier_frequency,...
            "ChannelBandwidth",sys_Parameter.channel_bandwith,...
            "DelayProfile",channel_type,...
            "EnvironmentalSpeed",sys_Parameter.velocity*3.6,...
            "NormalizeChannelOutputs",true,...
            "TransmissionDirection",TransmissionDirection,...
            "TransmitReceiveDistance",1,...
            "NumReceiveAntennas",1,...
            "SampleRate",sys_Parameter.sample_rate,...
            "NumTransmitAntennas",1);

        channelInfo = info(channel);
        channelFilterDelay = channelInfo.ChannelFilterDelay;
        tx_waveform = [tx_waveform; zeros(channelFilterDelay, 1)];
        rx_waveform = channel(tx_waveform);
        rx_waveform = rx_waveform(1+channelFilterDelay:end);%消除抽头延迟

    otherwise
        error('unsupport channel type');
end

% tx_waveform = tx_waveform + 0*1i;
rx_waveform = awgn(rx_waveform,SNR+10*log10(sc_num/nfft));

end

