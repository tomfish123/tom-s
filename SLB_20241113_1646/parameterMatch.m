
%% Parameter match
if(sys_Parameter.subcarrier_spacing == 120e3)

    sys_Parameter.nfft = sys_Parameter.sample_rate/sys_Parameter.subcarrier_spacing;
    sys_Parameter.sc_num = 161;
    sys_Parameter.dt = 1/sys_Parameter.sample_rate;

    frame_Parameter.frame_num_in_hyperframes = 3;

    switch frame_Parameter.symbol_type
        case 1
            frame_Parameter.symbol_num = 14;
            frame_Parameter.cp_length = 18;
            frame_Parameter.gap1_length = 274;
            frame_Parameter.gap2_length = 278;
        case 2
            frame_Parameter.symbol_num = 13;
            frame_Parameter.cp_length = 39;
            frame_Parameter.gap1_length = 295;
            frame_Parameter.gap2_length = 300;
        case 3
            frame_Parameter.symbol_num = 12;
            frame_Parameter.cp_length = 64;
            frame_Parameter.gap1_length = 320;
            frame_Parameter.gap2_length = 320;
        case 4
            frame_Parameter.symbol_num = 10;
            frame_Parameter.cp_length = 128;
            frame_Parameter.gap1_length = 384;
            frame_Parameter.gap2_length = 384;
        otherwise
            error('unsupport symbol type');
    end

    switch frame_Parameter.n_ch
        case 1
            sys_Parameter.channel_bandwith = 'CBW20';
        case 2
            sys_Parameter.channel_bandwith = 'CBW40';
        case 4
            sys_Parameter.channel_bandwith = 'CBW80';
        case 8
            sys_Parameter.channel_bandwith = 'CBW160';
        case 16
            sys_Parameter.channel_bandwith = 'CBW320';
        otherwise
            sys_Parameter.channel_bandwith = 'CBW80';
            warning('The current channel does not support the specified bandwidth.Channel bandwidth is changed to CBW80 ');
    end

    switch frame_Parameter.frame_type_index
        case 13
            frame_Parameter.transmissionDirection = "Downlink";
            disp("Downlink");
        case 14
            frame_Parameter.transmissionDirection = "Uplink";
            disp("Uplink");
    end

    % Default Symbol placement Settings
    % By default, all symbols are transmitted in every frame as much as possible
    position.STS_position = 1;
    position.FTS_position = [2;3];
    position.detection_position = [];
    position.status_position = 6;
    position.demodulation_ref_position = [{7}];
    position.data_position = [num2cell((8:frame_Parameter.symbol_num).',1),...
        num2cell(repmat([1:5,7:frame_Parameter.symbol_num].',1,frame_Parameter.frame_num_in_hyperframes-1),1)];









    


end




























