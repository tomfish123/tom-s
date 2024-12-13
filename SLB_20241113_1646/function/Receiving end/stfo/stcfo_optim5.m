function [sto_est,cfo_est,u1,cp_num] = stcfo_optim5(recv,sys_Parameter,f_off,t_off)
    % 时偏频偏联合估计方法 优化的 版本5 使用二维搜索
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
    
        %% FTS 粗估计 sto和cp_num u1
        seg_num_fts0 = 1;
        max_scane_sto1 = 256+384*3; %最大估计区域
        sto_scan_fts = 1:(max_scane_sto1-256);
        cr_fts = zeros(2,length(sto_scan_fts));
        cr_fts_max_peaks = zeros(2,2);
        for i = 1:2
            for j =sto_scan_fts
                % 接收信号段
                recv_slots = recv(j:j+256-1);
                recv_slots_seg = reshape(recv_slots,[seg_num_fts0,256/seg_num_fts0]);
                % recv_slots_energy = sum(abs(conj(recv_slots_seg).*recv_slots_seg).^2,2); %能量计算
                % recv_slots_energy(recv_slots_energy == 0) = 1; %避免出现nan
                % 相关运算
                cur_fts_ref = reshape(fts_k_all(:,i),[seg_num_fts0,256/seg_num_fts0]);
                cur_cr = abs(sum(recv_slots_seg.* conj(cur_fts_ref),2)).^2;
                cr_fts(i,j) = sum(cur_cr) ;%./ sum(recv_slots_energy);
            end
            [loc1,pk1,pk1b] = noise_holdup_findpeaks(cr_fts(i,:),8);
            loc_max1a = loc1(pk1==max(pk1));
            cr_fts_max_peaks(i,1) = loc_max1a(1); %最高数值峰位置
            cr_fts_max_peaks(i,2) = max(pk1);  %最高数值峰
            % 寻找第二高峰
            pk1(pk1==max(pk1)) = -1.0 * max(pk1);
            loc_max1b = loc1(pk1==max(pk1));
            cr_fts_max_peaks(i,3) = loc_max1b(1); %第二高峰位置
        end
        u1s = find(cr_fts_max_peaks(:,2)==max(cr_fts_max_peaks(:,2)));
        u1 = u1s(1);
        cp_num_list = [18,39,64,128];
        cp_err = cp_num_list-(abs(cr_fts_max_peaks(u1,1)-cr_fts_max_peaks(u1,3))-256);
        cp_num = cp_num_list(cp_err==min(cp_err));
        if(cr_fts_max_peaks(u1,1)>cr_fts_max_peaks(u1,3))
            sto_est_r = cr_fts_max_peaks(u1,3)-cp_num*2-256-1;
        else
            sto_est_r = cr_fts_max_peaks(u1,1)-cp_num*2-256-1;
        end
        if(u1 ~=1 || cp_num ~= 18 || sto_est_r < 0)
        % if(abs(sto_est-t_off)~=0 || u1 ~=1)
            fprintf(2,"sts err: %+-d u1: %d\n",abs(sto_est_r-f_off),u1);
        end
    
        % %% STS 细估计 sto u2
        % seg_num_sts = 1;
        % sto_sts_scanlen = 3; %滑动扫描距离
        % sto_scan_sts = sto_est_r+1+cp_num-sto_sts_scanlen:sto_est_r+1+cp_num+sto_sts_scanlen;
        % cr_sts = zeros(20,length(sto_scan_sts));
        % for i = 1: length(sto_scan_sts)
        %     for j = 1:20
        %         if(sto_scan_sts(i)<1)
        %             ans = 1;
        %             continue;
        %         end
        %         % 接收信号段
        %         recv_slots = recv(sto_scan_sts(i):sto_scan_sts(i)+256+cp_num-1);
        %         recv_slots_seg = reshape(recv_slots,[seg_num_sts,(256+cp_num)/seg_num_sts]);
        %         % recv_slots_energy = sum(abs(conj(recv_slots_seg).*recv_slots_seg).^2,2); %能量计算
        %         % recv_slots_energy(recv_slots_energy == 0) = 1; %避免出现nan
        %         % 相关运算
        %         cur_fts_ref = reshape([sts_k_all(end-cp_num+1:end,j);sts_k_all(:,j)],[seg_num_sts,(256+cp_num)/seg_num_sts]);
        %         cur_cr = abs(sum(recv_slots_seg.* conj(cur_fts_ref),2)).^2;
        %         cr_sts(j,i) = sum(cur_cr) ;%./ sum(recv_slots_energy);                
        %     end
        % end
        % [u2s,max_crs] = find(cr_sts==max(max(cr_sts)));
        % u2 = u2s(1);
        % sto_est = sto_scan_sts(max_crs(1))-cp_num-1;
        % if(u2 ~= 1)
        %     ans = 1;
        % end

        %% STS 估计 sto
        % seg_num_sts = 1;
        % max_scane_sto0 = 256+384; %最大估计区域
        % sts_len=256+cp_num;
        % sto_scan_sts = 1:(max_scane_sto0-sts_len);
        % cr_sts = zeros(20,length(sto_scan_sts));
        % cr_sts_max_peaks = zeros(20,3);
        % for i = 1:20
        %     for j = sto_scan_sts
        %         % 接收信号段
        %         recv_slots = recv(j:j+sts_len-1);
        %         recv_slots_seg = reshape(recv_slots,[seg_num_sts,sts_len/seg_num_sts]);
        %         % recv_slots_energy = sum(abs(conj(recv_slots_seg).*recv_slots_seg).^2,2); %能量计算
        %         % recv_slots_energy(recv_slots_energy == 0) = 1; %避免出现nan
        %         % 相关运算
        %         cur_fts_ref = reshape([sts_k_all(end-cp_num+1:end,i);sts_k_all(:,i)],[seg_num_sts,sts_len/seg_num_sts]);
        %         cur_cr = abs(sum(recv_slots_seg.* conj(cur_fts_ref),2)).^2;
        %         cr_sts(i,j) = sum(cur_cr) ;%./ sum(recv_slots_energy);
        %     end
        %     [loc1,pk1,pk1b] = noise_holdup_findpeaks(cr_sts(i,:),8);
        %     loc_max1a = loc1((pk1==max(pk1)));
        %     cr_sts_max_peaks(i,1) = loc_max1a(1);
        %     cr_sts_max_peaks(i,2) = max(pk1);  %最高数值峰
        %     cr_sts_max_peaks(i,3) = max(pk1b); %最高相对峰值
        % end
        % u2_maxs = find(cr_sts_max_peaks(:,3)==max(cr_sts_max_peaks(:,3)));
        % u2 = u2_maxs(1);
        % % sto_est = cr_sts_max_peaks(u2,1)-18-1;
        % if(abs(sto_est-t_off)~=0 || u2 ~=1)
        %     fprintf("sts err: %+-d\n",abs(sto_est-t_off));
        % end
    
        %% 确定cpnum,u1 方法1
        % seg_num_cp = 4;
        % cp_num_list = [18,39,64,128];
        % scan_len = length(cp_num_list);
        % cr_cp = zeros(2,scan_len);
        % for j = 1:2
        %     for i = 1:scan_len
        %         for k = -3:3 %左右滑动2点 减小误差
        %             % 切片处理
        %             recv_clip = recv(sto_est+1+256+cp_num_list(i)*2+k:sto_est+1+256+cp_num_list(i)*2+255+k);
        %             recv_slots_seg = reshape(recv_clip,[seg_num_cp,256/seg_num_cp]);
        %             % recv_slots_energy = sum(abs(conj(recv_slots_seg).*recv_slots_seg).^2,2); %能量计算
        %             % recv_slots_energy(recv_slots_energy == 0) = 1; %避免出现nan
        %             % 相关运算
        %             cur_fts_ref = reshape(fts_k_all(:,j),[seg_num_cp,256/seg_num_cp]);
        %             cur_cr = abs(sum(recv_slots_seg.* conj(cur_fts_ref),2)).^2;
        %             if(k==-3 || cr_cp(j,i)<sum(cur_cr))
        %                 cr_cp(j,i) = sum(cur_cr) ;%./ sum(recv_slots_energy);
        %             end
        %         end
        %     end
        % end
        % [u1s,cp_num_p] = find(cr_cp==max(max(cr_cp)));
        % cp_num = cp_num_list(cp_num_p(1));
        % u1=u1s(1);
        % if(cp_num~=18 || u1~=1)
        %     disp(cp_num);
        % end
        
        %% cpnum u1 估计方法2 寻找双峰 稳健性更强但复杂度高
        % seg_num_cp = 4;
        % cp_scan = sto_est+1:256+384*3-255;
        % cr_cp = zeros(length(cp_scan),2);
        % cr_maxs = zeros(2,3);
        % for i = 1:2
        %     for j = 1:length(cp_scan)
        %         if(cp_scan(j)<=0)
        %             ans = 1 ;
        %         end
        %         recv_clip = recv(cp_scan(j):cp_scan(j)+255);
        %         recv_slots_seg = reshape(recv_clip,[seg_num_cp,256/seg_num_cp]);
        %         % recv_slots_energy = sum(abs(conj(recv_slots_seg).*recv_slots_seg).^2,2); %能量计算
        %         % recv_slots_energy(recv_slots_energy == 0) = 1; %避免出现nan
        %         % 相关运算
        %         cur_fts_ref = reshape(fts_k_all(:,i),[seg_num_cp,256/seg_num_cp]);
        %         cur_cr = abs(sum(recv_slots_seg.* conj(cur_fts_ref),2)).^2;
        %         cr_cp(j,i) = sum(cur_cr) ;%./ sum(recv_slots_energy);
        %     end
        %     cr_cp_cur = cr_cp(:,i);
        %     cr_max1a=find(cr_cp_cur==max(cr_cp_cur));
        %     cr_maxs(i,1) = cr_max1a(1);
        %     cr_maxs(i,2)=max(cr_cp_cur);
        %     cr_cp_cur(cr_cp_cur==max(cr_cp_cur))= -1 *max(cr_cp_cur);
        %     cp_max1b=find(cr_cp_cur==max(cr_cp_cur));
        %     cr_maxs(i,3) = cp_max1b(1);
        % end
        % u1s = find(cr_maxs(:,2)==max(cr_maxs(:,2)));
        % u1 = u1s(1);
        % cp_num_list = [18,39,64,128];
        % cp_err = cp_num_list-(abs(cr_maxs(u1,1)-cr_maxs(u1,3))-256);
        % cp_num = cp_num_list(cp_err==min(cp_err));
        % if(cp_num~=18 || u1~=1)
        %     disp(cp_num);
        % end
        

        %% cfo 估计方法 联合2个fts估计
        sto_est = sto_est_r;
        seg_num_cfo = 2;
        cfo_scan = -2:0.2:2; %频偏扫描范围
        cfo_scan_len = length(cfo_scan);
        cr_cfo = zeros(cfo_scan_len,7);
        fts_ref = [fts_k_all(end-cp_num+1:end,u1) ; fts_k_all(:,u1) ; fts_k_all(end-cp_num+1:end,u1) ; fts_k_all(:,u1)];
        % clip_len = 512;
        for i = 1:cfo_scan_len
            for k = -3:3 %左右滑动矫正误差
                if(sto_est+1+256+cp_num*1+k<1)
                    continue;
                end
                seq_order = 256+cp_num*1+1:cp_num*3+256*3;
                fts_ref_cfed = fts_ref.* exp(1i*2*pi*cfo_scan(i)*subcarrier_spacing.*(seq_order)*dt).';
                fts_ref_cfed_cliped = fts_ref_cfed;
                clip_len = length(fts_ref_cfed);
                % fts_ref_cfed_cliped = [fts_ref_cfed(cp_num+1:cp_num+1+255);fts_ref_cfed(cp_num*2+256+1:end)];
                % 切片处理
                recv_clip = recv(sto_est+1+256+cp_num*1+k:sto_est+256*3+cp_num*3+k);
                % recv_clip = [recv(sto_est+1+256+cp_num*2+k:sto_est+1+256+cp_num*2+k+255) ;...
                %              recv(sto_est+1+256*2+cp_num*3+k:sto_est+1+256*2+cp_num*3+k+255)];
                recv_slots_seg = reshape(recv_clip,[seg_num_cfo,clip_len/seg_num_cfo]);
                % recv_slots_energy = sum(abs(conj(recv_slots_seg).*recv_slots_seg).^2,2); %能量计算
                % % recv_slots_energy(recv_slots_energy == 0) = 1; %避免出现nan
                % 相关运算
                cur_fts_ref = reshape(fts_ref_cfed_cliped,[seg_num_cfo,clip_len/seg_num_cfo]);
                cur_cr = abs(sum(recv_slots_seg.* conj(cur_fts_ref),2)).^2;
                cr_cfo(i,k+4) = sum(cur_cr);           
            end
        end
        [cfo_est_maxs,sto_est_adds] = find(cr_cfo==max(max(cr_cfo)));
        ests = zeros(2,2);
        ests(1,:) = [cfo_scan(cfo_est_maxs(1)) ; sto_est + sto_est_adds(1)-4];
        cr_cfo(cr_cfo==max(max(cr_cfo))) = -1*max(max(cr_cfo));
        [cfo_est_maxs,sto_est_adds] = find(cr_cfo==max(max(cr_cfo)));
        ests(2,:) = [cfo_scan(cfo_est_maxs(1)) ; sto_est + sto_est_adds(1)-4];
        if(~(abs(ests(1,2)-t_off)==0 || abs(ests(2,2)-t_off)==0))
            fprintf(2,"2d scan err!\n");
            ans = 1;
        end
        % cfo_est = cfo_scan(cr_cfo(:,1)==max(cr_cfo(:,1)));
        % sto_est = sto_est + cr_cfo(cr_cfo(:,1)==max(cr_cfo(:,1)),2);
        % if(abs(sto_est-t_off)>1)
        %     ans=1;
        % end
        % disp(cr_cfo(cr_cfo(:,1)==max(cr_cfo(:,1)),2));
        % [xx,yy] = meshgrid(cfo_scan,-3:3);surf(xx,yy,cr_cfo.');

        %% 联合估计方法的校准 方法1
        cr_cfo2 = zeros(20,2);
        seg_num_cfo2 = 4;
        clip_len = 256;
        for i = 1:20
            for j = 1:2
                % sts_ref_cfed = [sts_k_all(end-cp_num+1:end,i);sts_k_all(:,i)].* exp(1i*2*pi*ests(j,1)*subcarrier_spacing.*(1:cp_num+256)*dt).';
                % recv_clip = recv(ests(j,2)+1:ests(j,2)+1+cp_num*1+255);
                sts_ref_cfed = sts_k_all(:,i).* exp(1i*2*pi*ests(j,1)*subcarrier_spacing.*(cp_num+1:cp_num+256)*dt).';
                recv_clip = recv(ests(j,2)+1+cp_num*1+j:ests(j,2)+1+cp_num*1+255+j);
                recv_slots_seg = reshape(recv_clip,[seg_num_cfo2,clip_len/seg_num_cfo2]);
                % 相关运算
                cur_sts_ref = reshape(sts_ref_cfed,[seg_num_cfo2,clip_len/seg_num_cfo2]);
                cur_cr = abs(sum(recv_slots_seg.* conj(cur_sts_ref),2)).^2;
                cr_cfo2(i,j) = sum(cur_cr);
            end
        end
        [u2,new_ests]=find(cr_cfo2==max(max(cr_cfo2)));
        sto_est = ests(new_ests(1),2);
        cfo_est = ests(new_ests(1),1);

        %% 联合估计方法的校准 方法2
        % cr_cfo3 = zeros(2,1);
        % for j = 1:2
        %     recv1 = recv(ests(j,2)+1:ests(j,2)+cp_num).*exp(1i*2*pi*ests(j,1)*subcarrier_spacing.*(1:cp_num)*dt).';
        %     recv2 = recv(ests(j,2)+256+1:ests(j,2)+cp_num+256).*exp(1i*2*pi*ests(j,1)*subcarrier_spacing.*(256+1:256+cp_num)*dt).';
        %     % cr_cfo3(j,1) = sum(abs(recv1.*conj(recv2)));
        %     cr_cfo3(j,1) = sum((abs(recv1)-abs(conj(recv2))).^2);
        % end
        % new_ests = find(cr_cfo3 == max(cr_cfo3));
        % sto_est = ests(new_ests(1),2);
        % cfo_est = ests(new_ests(1),1);
        %% sto cfo 联合估计 利用sts
        % % sto_est = sto_est_r;
        % cfo_scan = 0; %频偏扫描范围
        % seg_num_cfo2 = 1;
        % cfo_scan_len = length(cfo_scan);
        % cr_cfo = zeros(cfo_scan_len,20,2);
        % clip_len = 256+cp_num;
        % for i = 1:20
        %     for j = 1:cfo_scan_len
        %         sts_ref = [sts_k_all(end-cp_num+1:end,i);sts_k_all(:,i)];
        %         for k = [-3 0 3]
        %             sts_ref_cfed = sts_ref .* exp(1i*2*pi*cfo_scan(j)*subcarrier_spacing.*(1:256+cp_num)*dt).';
        %             recv_clip = recv(sto_est+1+k:sto_est+1+k+255+cp_num);
        %             recv_slots_seg = reshape(recv_clip,[seg_num_cfo2,clip_len/seg_num_cfo2]);
        %             % recv_slots_energy = sum(abs(conj(recv_slots_seg).*recv_slots_seg).^2,2); %能量计算
        %             % % recv_slots_energy(recv_slots_energy == 0) = 1; %避免出现nan
        %             % 相关运算
        %             cur_fts_ref = reshape(sts_ref_cfed,[seg_num_cfo2,clip_len/seg_num_cfo2]);
        %             cur_cr = abs(sum(recv_slots_seg.* conj(cur_fts_ref),2)).^2;
        %             if(k==-3 || cr_cfo(j,i,1)<(sum(cur_cr)))
        %                 cr_cfo(j,i,1) = sum(cur_cr); %./sum(recv_slots_energy));
        %                 cr_cfo(j,i,2) = k;
        %             end            
        %         end
        %     end
        % end
        % [cfo_ests,u2s] = find(cr_cfo(:,:,1)==max(max(cr_cfo(:,:,1))));
        % u2 = u2s(1);
        % cfo_est = cfo_scan(cfo_ests(1));
        % sto_est = sto_est + cr_cfo(cfo_ests(1),u2,2);

        %% 再估计频偏 找峰值周边最多平移正负3个点
        % cfo_scan = -2:0.2:2;%频偏
        % cfo_scan_len = length(cfo_scan);
        % cr_cfo1 = zeros(cfo_scan_len,2);
        % cr_cfo1_max = inf;
        % cr_cfo1_postion = 0; % i k
        % for i = 1:2
        %     % 防止越界 目前不会出现这种情况
        %     % if( i <= 0)
        %     %     continue;
        %     % end
        %     for k = 0:2
        %         for j = 1:cfo_scan_len
        %             % 当前检测段索引
        %             seq_order = sto_est+1+256+18*2+k:sto_est+1+256+18*2+256-1+k;
        %             % 接收信号段
        %             recv_slots = recv(seq_order);
        %             % 频偏估计
        %             recv_slots = recv_slots .* exp(-1i*2*pi*cfo_scan(j)*subcarrier_spacing.*(seq_order)*dt).';
        %             recv_slots_seg = reshape(recv_slots,[seg_num,256/seg_num]);
        %             recv_slots_energy = sum(abs(conj(recv_slots_seg).*recv_slots_seg).^2,2); %能量计算
        %             recv_slots_energy(recv_slots_energy == 0) = 1; %避免出现nan
        %             % 相关运算
        %             cur_fts_ref = reshape(fts_k_all(:,i),[seg_num,256/seg_num]);
        %             cur_cr = abs(sum(recv_slots_seg.* conj(cur_fts_ref),2)).^2;
        %             cr_cfo1(j,i) = sum(cur_cr) ;%./ sum(recv_slots_energy);
        %             % 最大值查找
        %             if(cr_cfo1_max== inf || cr_cfo1_max < cr_cfo1(j,i))
        %                 cr_cfo1_max = cr_cfo1(j,i);
        %                 cr_cfo1_postion = j;
        %             end
        %         end
        %     end
        % end
        % cfo_est = cfo_scan(cr_cfo1_postion);
     
        %% 防止报错
        if(sto_est < 0 )
            sto_est = 0;
        end
    
    end
    
    