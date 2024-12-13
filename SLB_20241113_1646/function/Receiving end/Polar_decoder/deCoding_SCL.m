function data_out = deCoding_SCL(LLR_deRM, Info_ind, L)
% SCL解码器，用于极化码的顺序列表解码（Successive Cancellation List Decoder）
% 输入参数：
%   LLR_deRM   - 解调后的对数似然比 (LLR)
%   Info_Set_Id - 信息集标识符
%   Info_ind   - 信息比特索引
%   data_ind   - 数据比特索引
%   L          - 列表长度（List Size）
%   n          - 极化码参数，决定码字长度为2^n
%   TBS        - 传输块大小（Transport Block Size）
%
% 输出：
%   data_out   - 解码后的传输块数据

if nargin <= 3
    L = 32; %% SCL 译码参数
end

N  = length(LLR_deRM);
n = log2(N);

Info_Set_Id           = zeros(1,2^n);
Info_Set_Id(Info_ind) = 1;    %% 先声明一个N全零向量，然后将index为Info_ind的位置置1，信息bit位置置1，冻结bit位置置0
Info_Set_Id           = logical(Info_Set_Id); %% double型转化为logic型
data_ind = Info_ind;

for i=1:N
    str = dec2bin(i);
    depth(i) = 1+length(str)-find(str=='1',1,'last'); %% 找到最后一个非0值的序号
end
depth(N) = 1;%%用于SCL译码的输入参数

% 初始化LLR序列和码字长度
LLR = LLR_deRM;
N = 2^n;  % 码字长度为2^n
Chk_Set_Id = [];  % 空的校验集标识符

% 调用polardecoder进行初步的Polar码解码
% 返回估计的u序列（zz1）和路径度量（PM）
[zz1, PM] = polardecoder(single(LLR), single(Info_Set_Id), single(N), single(L), single(depth), single(Chk_Set_Id));

% 从解码结果中提取估计的信息比特
u_estimate = zz1(:, data_ind);
PM_L = PM;  % 保存路径度量

[~, Max_index] = min(PM_L);


% 提取最终估计的传输块数据
data_out = u_estimate(Max_index,:);
end
