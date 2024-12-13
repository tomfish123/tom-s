function symbols = get_symbol(TF_block,frame_Parameter,index,type)

% TF_block 待取数据的时频资源块
% index 索引变量
% type 要取的数据名称，与索引变量名一致；例如要把所有数据部分取出来，type = 'data'

switch type
    case'sync_STS'
        frame = index.sync_STS_frame;
        symbol = index.sync_STS_symbol;
        % sc = index.sync_STS_sc;
        sc = 1:161;
    case'sync_FTS'
        frame = index.sync_FTS_frame;
        symbol = index.sync_FTS_symbol;
        % sc = index.sync_FTS_sc;
        sc = 1:161;
    case 'dection'
        frame = index.dection_frame;
        symbol = index.dection_symbol;
        % sc = index.dection_sc;
        sc = 1:161;
    case'status_ref'
        frame = index.status_ref_frame;
        symbol = index.status_ref_symbol;
        % sc = index.status_ref_sc;
        sc = 1:161;
    case 'data_demod'
        frame = index.data_demod_frame;
        symbol = index.data_demod_symbol;
        % sc = index.data_demod_sc;
        sc = 1:161;
    case 'data'
        frame = index.data_frame;
        symbol = index.data_symbol;
        %sc = index.data_sc;
        sc = 1:161;
    otherwise 
        error('Signals not exist');
end

% 根据 frame、symbol 和 sc 取出符号
% symbols = TF_block(sc,(frame-1)*frame_Parameter.symbol_num+symbol);
symbols = [];
colofout = 1;
for i = 1:length(frame)
    symbol_incell = symbol{i};
    for m = 1:length(symbol_incell)
        for k = 1:length(sc)
            symbols(k,colofout) = TF_block(sc(k),(frame(i)-1)*frame_Parameter.symbol_num+symbol{i}(m));
        end
        colofout = colofout+1;
    end
end

if(isempty(symbols))
    symbols = [];
end



end