addpath(genpath(".\function\"));

clc
clear all

%% Parameter setting
sys_Parameter.carrier_frequency = 5.8e9; % carrier_frequency(Hz)
sys_Parameter.sample_rate = 30.72e6;    % sample rate(Hz)
sys_Parameter.subcarrier_spacing = 120e3;   %subcarrier spacing(Hz):'480e3'/'120e3'/'15e3'
sys_Parameter.hyperframes_num = 1;      % The number of hyperframes sent in once Monte Carlo simulation 
sys_Parameter.stream_num = 1;   % Transmission stream number
sys_Parameter.datainfo_retranFlag = 0;  %Retransmission indication:0/1
sys_Parameter.datainfo_type = 2;    % Transmission data type:1/2

sys_Parameter.channel_type = 'AWGN';    % Channel type:'AWGN' / 'TDL-A/B/C/D/E' / 'Model-A/B/C/D/E/F'
sys_Parameter.delay_spread = 30e-9;     % Delay spread for TDL(s)
sys_Parameter.CFO = 40; % initial carrier frequeccy offset(ppm)
sys_Parameter.velocity = 1;    % Receiver moving speed(m/s)
sys_Parameter.equ_type = 'MMSE'; % Channel equalization algorithm


switch sys_Parameter.subcarrier_spacing
    case 480e3
        % Parameter setting for 480kHz system
        frame_Parameter.cp_type = 'extended';   %Cyclic prefix configuration:'normal'/'extended'
        frame_Parameter.frame_type_index = 2;     % Wireless frame structure index:0~15 for nomal CP/ 0~13 for extended CP
        frame_Parameter.gap_position = 'two_sides';     % gap position for frame structure with all G/T symbols:'two_sides'/'tail'

    case 120e3
        % Parameter setting for 120kHz system
        frame_Parameter.symbol_type = 1;    % CP-OFDM symbol type:1~4
        frame_Parameter.frame_type_index = 13;   % Wireless frame structure index:13~14
        frame_Parameter.n_ch = 1;   % Channel width indication
        frame_Parameter.MCS_index = 19;    % MCS index for type 2 data transmission
        
        frame_Parameter.data_demod_ref_type = 'continuous'; % Data information transmission demodulation reference signal transmission form:'continuous'/'pectinate'
        
        frame_Parameter.G_node_identification = randi([0 1],1, 24);     % G Node Identification
        frame_Parameter.mul_syn_capability = [1,0,1,0,0,0,0,0];     % Multi-domain synchronization capability indicator
        frame_Parameter.sync_period = 1;    % Synchronization information block transmission period(ms):1/2/4/8
        frame_Parameter.u = [1,1];

    otherwise
        error_num('unsupported subcarrier spacing');
end



%% prepare
parameterCheck;
parameterMatch;
index = index_generation(sys_Parameter,frame_Parameter,position);

%% Monte Carlo simulation
SNR = 40;
SNR_linear = 10.^(SNR./10);  % Convert SNR from dB to a linear value
total_frame_num = 10000;
tic
for snr_index = 1:length(SNR)

    error_num = 0;
    for frame_index = 1:total_frame_num
        %% Initialize the time-frequency resource block
        tx_TF_block = zeros((sys_Parameter.sc_num+5)*frame_Parameter.n_ch-5,...
            frame_Parameter.symbol_num*sys_Parameter.hyperframes_num*frame_Parameter.frame_num_in_hyperframes);

        %% Synchronization signal mapping
        tx_TF_block = sync_mapping(tx_TF_block,sys_Parameter,frame_Parameter,index);

        %% Channel detection signal mapping
        tx_TF_block = Channel_detection_signal_mapping(tx_TF_block,sys_Parameter,frame_Parameter,index);

        %% Channel status information reference signal mapping
        tx_TF_block = Channel_status_ref_signal_mapping(tx_TF_block,sys_Parameter,frame_Parameter,index);

        %% Data demodulation reference signal
        tx_TF_block = data_demod_ref_mapping(tx_TF_block,sys_Parameter,frame_Parameter,index);

        %% data mapping
        [tx_TF_block,tx_bit,pcode,Encode_Parameters] = data_mapping(tx_TF_block,sys_Parameter,frame_Parameter,index);

        %% OFDM modulation
        [tx_waveform,judge_coef] = ofdm_modulation(tx_TF_block,frame_Parameter,sys_Parameter);

        %% Signal through channel
        rx_waveform = through_channel(tx_waveform,SNR(snr_index),sys_Parameter,frame_Parameter);

        % Add carrier frequency offset
        % frequency_offset = sys_Parameter.CFO*1e-6 * sys_Parameter.carrier_frequency;
        % rx_waveform = rx_waveform .* exp(1i*2*pi*frequency_offset*(0:length(rx_waveform)-1)*sys_Parameter.dt).';
        
        % Add time offset
        % time_offset = randi([1 sys_Parameter.nfft],1,1);
        % rx_waveform = [awgn(zeros(time_offset,1)+1e-16*1i,SNR(snr_index));rx_waveform];

        %% Receiving end
        %% Estimation and correction of time-frequency offset
%         % Estimated time offset and integer frequency offset
        % [sto_est,~,u1,cp_num] = stcfo_optim6(rx_waveform,sys_Parameter,frequency_offset,time_offset);
%         % correction of time-frequency offset
        % cfo_est = frequency_offset;
        % rx_waveform = correct_TF_error(rx_waveform,sto_est,cfo_est,time_offset,sys_Parameter,SNR(snr_index));
%         % Estimated time offset and decimal frequency offset
%         [cfo_est2] = cfomin_optim1(rx_waveform,sto_est,cp_num,2);
%         % Correct decimal frequency offset
%         rx_waveform = rx_waveform.* exp(-1i*2*pi*cfo_est2*sys_Parameter.subcarrier_spacing*(0:length(rx_waveform)-1)*sys_Parameter.dt).';

        %% OFDM demod
        rx_TF_block = ofdm_demodulation(rx_waveform,judge_coef,sys_Parameter,frame_Parameter,index);
        rx_TF_block = reshape(rx_TF_block,sys_Parameter.sc_num,frame_Parameter.symbol_num,[]);

        %% channel estimate
%         H_est = channel_estimate(rx_TF_block,rx_TF_block,SNR(snr_index),sys_Parameter,frame_Parameter,index);
        H_est = ones(161,8);

        %% Channel equalization  
        data_symbol_equ = [];
        for i = 1:length(index.data_frame)   %i-th wireless frame
            data_symbol_equ = [data_symbol_equ,rx_TF_block(:,index.data_symbol{1,i},index.data_frame(i))./H_est(:,i)];
        end

        %% Constellation point demodulation
        data_symbol_equ(81,:) = [];% delete DC
        rx_bit_llr = qamdemod(data_symbol_equ,2^Encode_Parameters.Q_m,...
            "gray",'UnitAveragePower',true,'OutputType','llr', ...
            'NoiseVariance',1/SNR_linear(snr_index));
%         rx_bit = qamdemod(data_symbol_equ,4,"gray",'UnitAveragePower',true,'OutputType','bit');
%         rx_bit = reshape(rx_bit_llr,[],1);
%         sum(xor(pcode.',rx_bit))
        
        %% polar decode
        [DecodedBit,bit_decoded] = Channel_decoding_polar(rx_bit_llr(:), Encode_Parameters);
        
        % Statistics bir error rate
        error_num = error_num + sum(xor(tx_bit,DecodedBit));
        sum(xor(tx_bit,DecodedBit))
        %% print progress
        fprintf("(%2.2f%%) SNR %d \n",100*frame_index/total_frame_num,SNR(snr_index))
        
    end
    BER(snr_index) = error_num / (length(tx_bit)*total_frame_num);
end
toc


%% 
figure;
semilogy(SNR,BER,'-s','LineWidth',2);hold on;grid on;
xlabel('SNR(dB)');ylabel('BER');


%% save results
filename = ['SLB_',num2str(sys_Parameter.subcarrier_spacing/1e3),'kHz_',...
    sys_Parameter.channel_type,'_',...
    'MCS_',num2str(frame_Parameter.MCS_index),'_',...
    datestr(now,'yymmdd_HHMM')];
% save(['result\',filename,'.mat']);



%% for test
% f_range = @(fs,signal) (-fs/2:fs/numel(signal):fs/2-fs/numel(signal)).';
% F = @(signal) abs((fft(signal)));
% plot(f_range(sys_Parameter.sample_rate,tx_waveform),F(tx_waveform));hold on;grid on;








