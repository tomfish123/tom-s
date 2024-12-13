function [sto_est,cfo_est,u1,cp_num] = stcfo_optim6(recv,sys_Parameter,f_off,t_off)
    % 时偏频偏联合估计方法 优化的 版本4 使用sts
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
        % if(abs(sto_est-t_off)>1)
        %     ans=1;
        % end
        % disp(cr_cfo(cr_cfo(:,1)==max(cr_cfo(:,1)),2));
        % [xx,yy] = meshgrid(cfo_scan,-3:3);surf(xx,yy,cr_cfo.');

        %% 联合估计方法的校准 方法2

        % % step1 精估计频偏
        % for i = 1:2
        %     fts1_begin = ests(i,2)+256+2*cp_num+1;
        %     fts1 = recv(fts1_begin:fts1_begin+256-1).* exp(-1i*2*pi*ests(i,1)*subcarrier_spacing.*(256+2*cp_num+1:256+2*cp_num+256)*dt).';
        %     % fts_cr = fts1 .* conj(fts_k_all(:,u1));
        %     fts2 = recv(fts1_begin+256+cp_num:fts1_begin+256+cp_num+256-1).* exp(-1i*2*pi*ests(i,1)*subcarrier_spacing.*(256*2+cp_num*3+1:256*3+cp_num*3)*dt).';
        %     fts1_k = fft(fts1); fts2_k = fft(fts2);
        %     cfo_est = 1/2/pi *256/(256+cp_num) * angle(sum(conj(fts1_k).*fts2_k));
        %     ests(i,1) = ests(i,1)+cfo_est;
        % end
        %% 联合估计方法的校准 方法1
        % cr_cfo2 = zeros(20,2);
        % seg_num_cfo2 = 4;
        % clip_len = 256;
        % for i = 1:20
        %     for j = 1:2
        %         % sts_ref_cfed = [sts_k_all(end-cp_num+1:end,i);sts_k_all(:,i)].* exp(1i*2*pi*ests(j,1)*subcarrier_spacing.*(1:cp_num+256)*dt).';
        %         % recv_clip = recv(ests(j,2)+1:ests(j,2)+1+cp_num*1+255);
        %         sts_ref_cfed = sts_k_all(:,i).* exp(1i*2*pi*ests(j,1)*subcarrier_spacing.*(cp_num+1:cp_num+256)*dt).';
        %         recv_clip = recv(ests(j,2)+1+cp_num*1+j:ests(j,2)+1+cp_num*1+255+j);
        %         recv_slots_seg = reshape(recv_clip,[seg_num_cfo2,clip_len/seg_num_cfo2]);
        %         % 相关运算
        %         cur_sts_ref = reshape(sts_ref_cfed,[seg_num_cfo2,clip_len/seg_num_cfo2]);
        %         cur_cr = abs(sum(recv_slots_seg.* conj(cur_sts_ref),2)).^2;
        %         cr_cfo2(i,j) = sum(cur_cr);
        %     end
        % end
        % [u2,new_ests]=find(cr_cfo2==max(max(cr_cfo2)));
        % sto_est = ests(new_ests(1),2);
        % cfo_est = ests(new_ests(1),1);

        %% 联合估计方法的校准 方法3
        ests(1,2)=max(0,ests(1,2));
        ests(2,2)=max(0,ests(2,2));
        cr_cfo2 = zeros(20,2,41);
        seg_num_cfo2 = 1;
        clip_len = 256;
        cr_cfo2_max_p = [0 0 0];
        cr_cfo2_max = -1;
        for j = 1:2    
            for i = 1:20
                cfo_min_scan=ests(j,1)-0.2:0.01:ests(j,1)+0.2;
                for k = 1:length(cfo_min_scan)
                    % sts_ref_cfed = [sts_k_all(end-cp_num+1:end,i);sts_k_all(:,i)].* exp(1i*2*pi*ests(j,1)*subcarrier_spacing.*(1:cp_num+256)*dt).';
                    % recv_clip = recv(ests(j,2)+1:ests(j,2)+1+cp_num*1+255);
                    sts_ref_cfed = sts_k_all(:,i).* exp(1i*2*pi*cfo_min_scan(k)*subcarrier_spacing.*(cp_num+1:cp_num+256)*dt).';
                    recv_clip = recv(ests(j,2)+1+cp_num*1:ests(j,2)+1+cp_num*1+255);
                    recv_slots_seg = reshape(recv_clip,[seg_num_cfo2,clip_len/seg_num_cfo2]);
                    % 相关运算
                    cur_sts_ref = reshape(sts_ref_cfed,[seg_num_cfo2,clip_len/seg_num_cfo2]);
                    cur_cr = abs(sum(recv_slots_seg.* conj(cur_sts_ref),2)).^2;
                    cr_cfo2(i,j,k) = sum(cur_cr);
                    if(cr_cfo2(i,j,k)>cr_cfo2_max)
                        cr_cfo2_max = cr_cfo2(i,j,k);
                        cr_cfo2_max_p = [i j k];
                    end
                end
            end
        end
        u2 = cr_cfo2_max_p(1);
        new_ests = cr_cfo2_max_p(2);
        cfo_ests = cr_cfo2_max_p(3);
        % [u2,new_ests,cfo_ests]=find(cr_cfo2==max(cr_cfo2,[],"all"));
        sto_est = ests(new_ests(1),2);
        cfo_est = ests(new_ests(1),1);
        % cfo_min_scan_tar=ests(new_ests(1),1)-0.2:0.01:ests(new_ests(1),1)+0.2;
        % cfo_est = cfo_min_scan_tar(cfo_ests(1));
        % ans=1;[xx,yy] = meshgrid(ests(ans,1)-0.2:0.01:ests(ans,1)+0.2,1:20);surf(xx,yy,squeeze(cr_cfo2(:,ans,:)));
        %% 防止报错
        if(sto_est < 0 )
            sto_est = 0;
        end
    
    end
    
    