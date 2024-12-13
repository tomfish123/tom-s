function tx_FT_block = sync_mapping(tx_FT_block,sys_Parameter,frame_Parameter,index)

u1 = frame_Parameter.u(1);
u2 = frame_Parameter.u(2);

% FTS mapping
n = 0:160;
d_FTS = exp(-1j*pi*u1*n.*(n+1)/161).*(n~=80);
tx_FT_block(:,index.sync_FTS_symbol{1,1}(1)) = d_FTS;
tx_FT_block(:,index.sync_FTS_symbol{1,1}(2)) = d_FTS;

% STS mapping
d_STS = exp(-1j*(pi*u2*n/8.*(n/8+1)/21)).*(mod(n,8)==0);
d_STS(81) = 0;
tx_FT_block(:,index.sync_STS_symbol{1,1}(1)) = 2*sqrt(2)*d_STS;



% G_node_identification = frame_Parameter.G_node_identification;
% mul_syn_capability = frame_Parameter.mul_syn_capability;
% syn_transmission_cycle = frame_Parameter.syn_transmission_cycle;
% nfft = sys_Parameter.nfft;

% syn_signal_coding
% calculate crc
%polynomial = [1 1 0 1 1 0 0 1 0 1 0 1 1 0 0 0 1 0 0 0 1 0 1 1 1];
% polynomial = [1,1,0,1,1,0,0,1,0,1,0,1,1,0,0,0,1,0,0,0,1,0,1,1,1];
% data_dec = [G_node_identification,mul_syn_capability,syn_transmission_cycle,zeros(1,14)];
% solution1
%lnum = length(data_dec);
%data = [data_dec,zeros(1,lpol-1)];
%lpol = length(polynomial);
%n = find(data==1,1);
%while n<=lnum
%for i=1:lpol
%    if polynomial(i)==data(n+i-1)
%        data(n+i-1)=0;
%    else
%        data(n+i-1)=1;
%    end
%end
% n=find(data==1,1);
%end
% syn_information = transpose([data_dec,data(lnum+1:end)]);
%
% solution2
%H = crc.generator(polynomial);
%syn_information = generate(H,data_dec);
%g_k = polarEncode(syn_information, 161);

%QPSK
% for i = 1:2:length(g_k)-1
%     b_2i = g_k(i);
%     b_2i_1 = g_k(i+1);
%     tx_FT_block(i,4) = 1/sqrt(2)*((2*b_2i-1)+1j*(2*b_2i_1-1));
%     tx_FT_block(i,5) = 1/sqrt(2)*((2*b_2i-1)+1j*(2*b_2i_1-1));
% end

end
