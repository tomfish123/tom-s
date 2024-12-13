function r_nl = qpsk_random_seq(G_node_identification, frame_index, symbol_index, symbol_type, seq_length)
% ****************************************************************
% 输入:
% G_node_identification G节点同步比特
% frame_index - 一个超帧中的无线帧索引 [0,7]
% symbol_index - 一个无线帧中符号的索引
% symbol_type 无线帧类型
% seq_length QPSK序列长度
% 输出:
% r_nl - 生成的伪随机 QPSK 序列 r_{n, l}(m)
% ****************************************************************
%% 参数确定
switch symbol_type % N_CP - 循环前缀类型 (0: 极限覆盖, 1: 扩展, 2: 常规, 3: 高谱效)
case 1
N_CP = 3;
case 2
N_CP = 2;
case 3
N_CP = 1;
case 4
N_CP = 0;
otherwise
error('Invalid symbol_type');
end
%N_ID确定
% 提取低8位
low_8_bits = G_node_identification(1:8); % 从左到右取低8位
% 转换为十进制数
N_ID = bi2de(low_8_bits, 'right-msb'); % 'right-msb'表示最右为高位
%% 伪随机序列生成
c_init = 2^10 *(15*(frame_index+1)+symbol_index+1) * (4 * N_ID + 1) + 4*N_ID +N_CP; % 计算 c_init
% 初始化 M 序列
M_PN = 2*seq_length+1;
c = zeros(1, M_PN);
% 生成 m 序列 x1 和 x2
x1 = zeros(1, 31);
x1(1) = 1;  % x1 初始值
x2 = zeros(1, 31);
for i = 1:31
        x2(i) = bitget(c_init, i);  % x2 初始值由 c_init 决定
end
x1 = msequence_generate(31, [1, 4], x1,M_PN); % 生成第一个 m 序列
x2 = msequence_generate(31, [1, 2, 3, 4], x2,M_PN); % 生成第二个 m 序列
% 生成 Gold 序列 c(i)

for i = 1:M_PN
c(i) = xor(x1(i),x2(i));
end
%% 生成伪随机QPSK 序列 r_{n, l}(m)
r_nl = zeros(1, seq_length); % 初始化
for m = 0:seq_length-1
real_part = (2 * c(2 * m + 1) - 1) / sqrt(2); % 实部
imag_part = (2 * c(2 * m + 2) - 1) / sqrt(2); % 虚部
r_nl(m + 1) = real_part + 1j * imag_part;
end
end

