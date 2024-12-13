function tx_TF_block = data_demod_ref_mapping(tx_TF_block,sys_Parameter,frame_Parameter,index)

if(isempty(index.data_demod_frame))
    return;
end


symbol_type = frame_Parameter.symbol_type;
G_node_id = frame_Parameter.G_node_identification;
ref_type = frame_Parameter.data_demod_ref_type;
sc_num = sys_Parameter.sc_num;
symbol_num = frame_Parameter.symbol_num;
tx_TF_block = reshape(tx_TF_block,sc_num,symbol_num,[]);


for frame_index = index.data_demod_frame
    for symbol_index = index.data_demod_symbol{1,frame_index}.'
        qpsk = qpsk_random_seq(G_node_id,frame_index,symbol_index,symbol_type,sc_num);
        tx_TF_block(:,symbol_index,frame_index) = [qpsk(1,1:floor(sc_num/2)),0,qpsk(1,floor(sc_num/2)+2:end)];
    end
end


switch ref_type
    case 'pectinate'
        for i = 1:numel(index.data_demod_symbol)
            tx_TF_block(2:2:end,index.data_demod_symbol{1,i},index.data_demod_frame) = 0;
        end
end


tx_TF_block = reshape(tx_TF_block,sc_num,[],1);









end

