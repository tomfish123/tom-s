function index = index_generation(sys_Parameter,frame_Parameter,position)

nfft = sys_Parameter.nfft;
sc_num = sys_Parameter.sc_num;
hyperframes_num = sys_Parameter.hyperframes_num;
symbol_num = frame_Parameter.symbol_num;
cp_length = frame_Parameter.cp_length;
gap1_length = frame_Parameter.gap1_length;
gap2_length = frame_Parameter.gap2_length;
frame_type_index = frame_Parameter.frame_type_index;
frames_num = frame_Parameter.frame_num_in_hyperframes;
sync_period = frame_Parameter.sync_period;

STS_position = position.STS_position;
FTS_position = position.FTS_position;
detection_position = position.detection_position;
status_position = position.status_position;
demodulation_ref_position = position.demodulation_ref_position;
data_position = position.data_position;

% index for Synchronization information block
if(~isempty(STS_position))
    index.sync_STS_time = 1:length(STS_position)*nfft;
    index.sync_STS_frame = 1:sync_period*frames_num:frames_num*hyperframes_num;
    index.sync_STS_symbol = num2cell(repmat(STS_position,1,length(index.sync_STS_frame)),1);
else
    index.sync_STS_time = [];
    index.sync_STS_frame = [];
    index.sync_STS_symbol = [];
    warning('Does not contain STS in frames');
end

if(~isempty(FTS_position))
    index.sync_FTS_time = length(STS_position)*nfft+1:(length(STS_position)+length(FTS_position))*nfft;
    index.sync_FTS_frame  = 1:sync_period*frames_num:frames_num*hyperframes_num;
    index.sync_FTS_symbol = num2cell(repmat(FTS_position,1,length(index.sync_FTS_frame)),1);
else
    index.sync_FTS_time = [];
    index.sync_FTS_frame  = [];
    index.sync_FTS_symbol = [];
    warning('Does not contain FTS in frames');
end

% index for channel detection signal
if(~isempty(detection_position))
    index.dection_frame = 1:frames_num*hyperframes_num;
    index.dection_symbol = num2cell(detection_position*ones(1,length(index.dection_frame)));
else
    index.dection_frame = [];
    index.dection_symbol = [];
    warning('Does not contain channel detection signals in frames');
end


% index for Channel status information reference signal
if(~isempty(status_position))
    index.status_ref_frame = 1:frames_num*hyperframes_num;
    index.status_ref_symbol = num2cell(status_position*ones(1,length(index.status_ref_frame)));
else
    index.status_ref_frame = [];
    index.status_ref_symbol = [];
    warning('Does not contain channel status information reference signals in frames');
end


% index for data demodulation reference signal
if(~isempty(demodulation_ref_position))
    index.data_demod_frame = 1:numel(demodulation_ref_position);
    index.data_demod_symbol = repmat(demodulation_ref_position,1,hyperframes_num);
else
    index.data_demod_frame = [];
    index.data_demod_symbol = [];
    warning('Does not contain data demodulation reference signals in frames');
end

% index for data
if(~isempty(data_position))
    index.data_frame = 1:frames_num*hyperframes_num;
    index.data_symbol = repmat(data_position,1,hyperframes_num);
end

% index for frequency symbol 
index.low_freq_zero = 1:floor((nfft - sc_num)/2);
index.high_freq_zero = nfft-ceil((nfft - sc_num)/2)+1:nfft;
index.sc = floor((nfft - sc_num)/2)+1:floor((nfft - sc_num)/2)+sc_num;

% index for gap
switch frame_type_index
    case {13,14}
        index.gap1_time = [];
        index.gap2_time = [];
    otherwise
        index.gap1_time = repmat(((nfft+cp_length)*(frame_type_index+1)+1:(nfft+cp_length)*(frame_type_index+1)+gap1_length).',1,frames_num*hyperframes_num) ...
            + (0:frames_num*hyperframes_num-1)*(symbol_num*(nfft+cp_length)+gap1_length+gap2_length) ;
        index.gap2_time = repmat((((nfft+cp_length)*symbol_num + gap1_length + 1):((nfft+cp_length)*symbol_num + gap1_length + gap2_length)).',1,frames_num*hyperframes_num) ...
            + (0:frames_num*hyperframes_num-1)*(symbol_num*(nfft+cp_length)+gap1_length+gap2_length) ;
end




end

