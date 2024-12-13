function [out_FT_block,data,pcode,Encode_Parameters] = data_mapping(tx_TF_block,sys_Parameter,frame_Parameter,index)

%% polar code
sc_num = sys_Parameter.sc_num;
symbol_num = frame_Parameter.symbol_num;
datainfo_type = sys_Parameter.datainfo_type;

N_RE = 0;
for i = 1:size(index.data_symbol,2)
    N_RE = N_RE + (sc_num-1)*numel(index.data_symbol{1,i});
end

if datainfo_type == 2
    %parameters 
    MCS_idx = frame_Parameter.MCS_index;
    load('Table_6.mat');
    Q_m = Table_6(MCS_idx+1, 2); 
    Q_m = log2(Q_m);   
    R = Table_6(MCS_idx+1, 3)/1024; 
%     N_RE = sys_Parameter.datainfo_N_RE;
    v = sys_Parameter.stream_num;   
    Retransmission_flag = sys_Parameter.datainfo_retranFlag;
    Information_type = 3;

    %Calculation of the information bit length
    N_info = N_RE*R*Q_m*v;
    n = max(3,floor(log2(N_info-24))-5);
    N_info_1 = max(24,2^n*round((N_info-24)/(2^n)));
    K_cb = ceil(4096*R/8)*8; 
    if N_info_1 > (K_cb-24)
        C = ceil((N_info_1+24)/(K_cb-24));
    else
        C = 1;
    end
    A_TBS = 8*C*ceil((N_info_1+24)/(8*C)) - 24;
    a = randi([0 1],A_TBS,1); %Information bit sequence
    g_CRC24A = [1 1 0 0 0 0 1 1 0 0 1 0 0 1 1 0 0 1 1 1 1 1 0 1 1];
    crcEncoder = comm.CRCGenerator(g_CRC24A);
    b = crcEncoder(a);
    %Calculation of the channel bit length
    E_total = N_RE*Q_m*v;
    if C == 1
        E = E_total;
    else
        E = floor(E_total/C);
    end

    %% stage1——Encode_Parameters_Gen.m
    Encode_Parameters = Encode_Parameters_Gen(Retransmission_flag, Information_type);
    %% Code_Block_Segmentation.m
    [B_seq_segmented] = Code_Block_Segmentation(b', R);
    U_seq_segmented = {};
    D_seq_segmented = {};
    Y_seq_segmented = {};
    E1_seq_segmented = {};
    E2_seq_segmented = {};
    for i = 1:C
        %% initial transmission——Code_Len_Determination.m
        K = length(B_seq_segmented{i});
        [n] = Code_Len_Determination(K, E, Encode_Parameters.n_max, Encode_Parameters.Coding_mode);
        N_seq_segmented = 2^n;
        %% stage2——Encode_Parameters_Gen.m
        Encode_Parameters = Encode_Parameters_Gen(Retransmission_flag, Information_type, K, N_seq_segmented, E);
        %% Get J(n)——Sub_Block_Interleaving.m
        [~, J] = Sub_Block_Interleaving(Encode_Parameters.M_r);
        %% Polar_Bitidx_Determination.m
        [Q_N_I, Q_N_F, Q_N_Iext, Q_N_Ichk] = Polar_Bitidx_Determination(Encode_Parameters, K, N_seq_segmented, E, J);
        Encode_Parameters.Q_N_I = Q_N_I;
        %% Polar_Encoderinput_Gen.m
        B_seq = B_seq_segmented{i};
        [u] = Polar_Encoderinput_Gen(Encode_Parameters, B_seq, N_seq_segmented, Q_N_I);
        U_seq_segmented = [U_seq_segmented u];
        %% Polar_Encode.m
        [d] = Polar_Encode(N_seq_segmented, u);
        D_seq_segmented = [D_seq_segmented d];
        %% Sub_Block_Interleaving.m
        D_M = d;
        M = length(D_M);
        [Y_M, ~] = Sub_Block_Interleaving(M, D_M);
        Y_seq_segmented = [Y_seq_segmented Y_M];
        %% channel_bit_sequence_generate.m
        E_RV0 = E;  % for initial transmission
        E_RV1 = 0;  % for initial transmission
        RMmode = 0;  % for initial transmission
        Encode_Parameters.E_RV0 = E_RV0;
        E1_E_RV0 = channel_bit_sequence_generate(Y_M, Encode_Parameters.Coding_mode, RMmode, K, M, E_RV0, E_RV1);
        E1_seq_segmented = [E1_seq_segmented E1_E_RV0];
        %% channel_interleaving.m
        E2_E_RV0 = channel_interleaving(E1_E_RV0', E);
        E2_seq_segmented = [E2_seq_segmented E2_E_RV0'];
    end
    %% Code_Block_Cascading.m
    [E_seq] = Code_Block_Cascading(E2_seq_segmented);
    

elseif  sys_Parameter.datainfo_type == 1
      error('Data type 1 is not support yet');
end

Encode_Parameters.Q_m = Q_m;
Encode_Parameters.M = M;
Encode_Parameters.K = K;
Encode_Parameters.C = C;
data = a;
if length(E_seq)<E_total
    E_seq =[E_seq zeros(1,E_total-length(E_seq))];
end
c = generate_gold_sequence(length(E_seq));
F_seq = mod(E_seq+c,2);
S_modded = qammod(F_seq',2^Q_m,"gray",'InputType','bit','UnitAveragePower',true);


out_FT_block = reshape(tx_TF_block,sc_num,symbol_num,[]);
data_frame = index.data_frame;
data_symbol = index.data_symbol;
start_idx = 1;
end_idx = sc_num - 1;
for i = 1:length(data_frame)
    data_symbol_temp = data_symbol{i};
    for j = 1:length(data_symbol_temp)
        out_FT_block([1:floor(sc_num/2) floor(sc_num/2)+2:sc_num],data_symbol_temp(j),data_frame(i)) = S_modded(start_idx:end_idx);
        start_idx = start_idx + sc_num - 1;
        end_idx = end_idx + sc_num - 1;
    end
end
out_FT_block = reshape(out_FT_block,sc_num,[]);
out_FT_block(floor(sc_num/2)+1,:) = 0;
pcode = F_seq;
%% uncoded
% sc_num = sys_Parameter.sc_num;
% symbol_num = frame_Parameter.symbol_num;
% 
% tx_TF_block = reshape(tx_TF_block,sc_num,symbol_num,[]);
% 
% mod_order = 4;
% data = [];
% symbol_index = 1;
% for frame_index = index.data_frame
%     bits= randi([0 1],(sc_num-1)*log2(mod_order),numel(index.data_symbol{1,symbol_index}));
%     data = [data,bits];
%     tx_TF_block([1:floor(sc_num/2) floor(sc_num/2)+2:sc_num],index.data_symbol{1,symbol_index},frame_index) = qammod(bits,mod_order,"gray",'InputType','bit','UnitAveragePower',true);
%     symbol_index = symbol_index + 1;
% end
% 
% data = reshape(data,[],1);
% out_FT_block = reshape(tx_TF_block,sc_num,[]);
% Encode_Parameters = 0;

end



