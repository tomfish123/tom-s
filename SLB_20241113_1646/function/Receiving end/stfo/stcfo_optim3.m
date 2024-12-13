function [sto_est,cfo_est,u1,cp_num] = stcfo_optim3(recv,sys_Parameter,t_off)
% 时偏频偏联合估计方法 优化的 版本3
% 输入：
%   recv 接收信号
%   subcarrier_spacing 子载波间隔
%   dt T_s
% 输出：
%   sto_est 估计的sto
%   cfo_est 估计的归一化 cfo
%   u1 fts序列 u值
%   cp_num 循环前缀采样点数

dt = sys_Parameter.dt;
subcarrier_spacing = sys_Parameter.subcarrier_spacing;


[fts_k_all,sts_k_all] = trainSeq_t_gen_All();

%fts峰值最大可能的检测区域
max_scane_sto = 256+384+128+16; %时偏
sto_scan = 1: max_scane_sto;
sto_scan_len = length(sto_scan);
cfo_scan = -2:0.2:2;%频偏
cfo_scan_len = length(cfo_scan);

seg_num = 4; %分段数

% 先估计时偏和u1
cr_sto1 = zeros(2,sto_scan_len);
cr_sto1_maxs = zeros(2,2);%位置
cr_sto1_maxv = zeros(2,2);%值
cr_sto1_postion = [0 0]; % i k
for i = 1:2
    for k = sto_scan
        % 接收信号段
        recv_slots = recv(k:k+256-1);
        recv_slots_seg = reshape(recv_slots,[seg_num,256/seg_num]);
        recv_slots_energy = sum(abs(conj(recv_slots_seg).*recv_slots_seg).^2,2); %能量计算
        recv_slots_energy(recv_slots_energy == 0) = 1; %避免出现nan
        % 相关运算
        cur_fts_ref = reshape(fts_k_all(:,i),[seg_num,256/seg_num]);
        cur_cr = abs(sum(recv_slots_seg.* conj(cur_fts_ref),2)).^2;
        cr_sto1(i,k) = sum(cur_cr) ./ sum(recv_slots_energy);
    end

    % 最大值查找 估计噪声水平
    [loc1,pk1] = noise_holdup_findpeaks(cr_sto1(i,:),0.005);
    loc_max1a = loc1((pk1==max(pk1)));
    cr_sto1_maxs(i,1) = loc_max1a(1);
    cr_sto1_maxv(i,1) = pk1(pk1==max(pk1));
    % 次最大值查找
    pk1((pk1==max(pk1))) = 0;
    for j = 1: length(loc1)%禁用不符合距离的极大值
        if(abs(loc1(j)-loc_max1a(1))<=256 || loc1(j)<256)
            pk1(j) = -1 * pk1(j);
        end
    end
    loc_max1b = loc1((pk1==max(pk1)));
    cr_sto1_maxs(i,2) = loc_max1b(1);
    cr_sto1_maxv(i,2) = pk1(pk1==max(pk1));
end
[u1,tmp] = find(cr_sto1_maxv==max(cr_sto1_maxv,[],"all"));
if(cr_sto1_maxs(u1,1)>cr_sto1_maxs(u1,2))
    cr_sto1_postion = [u1,cr_sto1_maxs(u1,2),cr_sto1_maxs(u1,1)];
else
    cr_sto1_postion = [u1,cr_sto1_maxs(u1,1),cr_sto1_maxs(u1,2)];
end
peake=abs(cr_sto1_postion(2)-cr_sto1_postion(3))-256-18;
if(peake>5)
    disp([abs(cr_sto1_postion(3)-256-18-18-t_off) abs(cr_sto1_postion(3)-256-256-18-18-18-t_off)]);
end
% if(~(abs(cr_sto1_postion(3)-256-18-18-t_off)<5 || abs(cr_sto1_postion(3)-256-256-18-18-18-t_off)<5))
%     disp([abs(cr_sto1_postion(3)-256-18-18-t_off) abs(cr_sto1_postion(3)-256-256-18-18-18-t_off)]);
% end
% 再估计频偏 找峰值周边最多平移正负3个点
cr_cfo1 = zeros(cfo_scan_len,7);
cr_cfo1_max = inf;
cr_cfo1_postion = 0; % i k
for i = cr_sto1_postion(3)-3:cr_sto1_postion(3)+3
    % 防止越界 目前不会出现这种情况
    % if( i <= 0)
    %     continue;
    % end
    for j = 1:cfo_scan_len
        % 当前检测段索引
        seq_order = i:i+256-1;
        % 接收信号段
        recv_slots = recv(seq_order);
        % 频偏估计
        recv_slots = recv_slots .* exp(-1i*2*pi*cfo_scan(j)*subcarrier_spacing.*(seq_order)*dt).';
        recv_slots_seg = reshape(recv_slots,[seg_num,256/seg_num]);
        recv_slots_energy = sum(abs(conj(recv_slots_seg).*recv_slots_seg).^2,2); %能量计算
        recv_slots_energy(recv_slots_energy == 0) = 1; %避免出现nan
        % 相关运算
        cur_fts_ref = reshape(fts_k_all(:,u1),[seg_num,256/seg_num]);
        cur_cr = abs(sum(recv_slots_seg.* conj(cur_fts_ref),2)).^2;
        cr_cfo1(j,i) = sum(cur_cr) ./ sum(recv_slots_energy);
        % 最大值查找
        if(cr_cfo1_max== inf || cr_cfo1_max < cr_cfo1(j,i))
            cr_cfo1_max = cr_cfo1(j,i);
            cr_cfo1_postion = j;
        end
    end
end
cfo_est = cfo_scan(cr_cfo1_postion);

% 次极大值查找

% 纠正频偏
max_scane_sto2 = max_scane_sto + 384;
seq_order = 1:max_scane_sto2;
recv_cfo_corrected = recv(seq_order).* exp(-1i*2*pi*cfo_est*subcarrier_spacing.*(seq_order)*dt).';
% 查找最大值和次极大值
cr_sto2 = zeros(length(seq_order),1);
cr_sto2_postion = 0;
for k = 1:max_scane_sto2-256
    % 接收信号段
    recv_slots = recv_cfo_corrected(k:k+256-1);
    recv_slots_seg = reshape(recv_slots,[seg_num,256/seg_num]);
    recv_slots_energy = sum(abs(conj(recv_slots_seg).*recv_slots_seg).^2,2); %能量计算
    recv_slots_energy(recv_slots_energy == 0) = 1; %避免出现nan
    % 相关运算
    cur_fts_ref = reshape(fts_k_all(:,u1),[seg_num,256/seg_num]);
    cur_cr = abs(sum(recv_slots_seg.* conj(cur_fts_ref),2)).^2;
    cr_sto2(k) = sum(cur_cr) ./ sum(recv_slots_energy);
end
% 最大值和次极大值查找 考虑了噪声水平
% 最大值查找 估计噪声水平
[loc2,pk2] = noise_holdup_findpeaks(cr_sto2,0.005);
loc_max2 = loc2(pk2==max(pk2));
sto_peak1 = loc_max2(1);
% 次极大值查找
pk2(pk2==max(pk2)) = 0;% 最高峰值 去掉
for j = 1: length(pk2)
    if(abs(loc2(j)-sto_peak1)<256)
        pk2(j)= -1 * pk2(j);
    end
end
loc_max3 = loc2(pk2==max(pk2));% 寻找另一峰值
sto_peak2 = loc_max3(1);
% cp_num 确定
cp_num_list = [18,39,64,128];
cp_num_est = abs(sto_peak1-sto_peak2)-256;
cp_num_err = abs(cp_num_list - cp_num_est);
cp_num = cp_num_list(cp_num_err == min(cp_num_err));
% sto 估计
if(sto_peak1 > sto_peak2)
    sto_est = round((sto_peak2-cp_num*2-256-1)+(sto_peak1-cp_num*3-256*2-1))/2;
else
    sto_est =  round((sto_peak1-cp_num*2-256-1)+(sto_peak2-cp_num*3-256*2-1))/2;
end

% 防止报错
if(sto_est < 0 )
    sto_est = 0;
end

end

