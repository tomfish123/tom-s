%% Parameter check
%% Parameter check for 480e3
if(sys_Parameter.subcarrier_spacing == 480e3)

    switch frame_Parameter.cp_type
        case 'normal'
            if(frame_Parameter.frame_type_index < 0 || frame_Parameter.frame_type_index > 15)
                error('unsuported wireless frame structure index for normal CP');
            end
            if(frame_Parameter.frame_type_index < 14 )
                warning('Configuring frame_Parameter.gap_position does not take effect with the current parameter');
            end
        case 'extended'
            if(frame_Parameter.frame_type_index < 0 || frame_Parameter.frame_type_index > 13)
                error('unsuported wireless frame structure index for normal CP');
            end
            if(frame_Parameter.frame_type_index < 12 )
                warning('Configuring frame_Parameter.gap_position does not take effect with the current parameter');
            end
        otherwise
            error('unsuported CP type');
    end


end



%% Parameter check for 120e3
if(sys_Parameter.subcarrier_spacing == 120e3)
    

    if(frame_Parameter.frame_type_index < 13)
        error(['Currently, only upstream and downstream separate simulation is supported.',...
            'Please set the frame index to 13 or 14']);
    end


    


end

































