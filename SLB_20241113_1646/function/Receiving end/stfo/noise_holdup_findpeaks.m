function [loc1,pk1,pk2] = noise_holdup_findpeaks(sequence,thres)
% 去掉噪声段的峰值
%   sequence: 输入序列
%   thres: 噪声门限
%   loc: 去除后的峰值位置
%   pk1: 去除后的峰值大小
%   pk2: 表征峰值的相对大小
    clip_max=length(sequence);
    [pk1,loc1] = findpeaks(sequence,"MinPeakDistance",50);
    pk2 = pk1;
    for j = 1:length(loc1)
        % 数据访问防止越界
        clip_l_start =loc1(j)-2-25;
        clip_l_end =loc1(j)-2;
        if(clip_l_start<1)
            clip_l_start = 1;
        end
        if(clip_l_end<1)
            clip_l_end = 0;
        end
        clip_r_start = loc1(j)+2;
        clip_r_end = loc1(j)+2+25;
        if(clip_r_start>clip_max)
            clip_r_start = clip_max;
        end
        if(clip_r_end>clip_max)
            clip_r_end = clip_max;
        end
        % 切片 计算噪声水平
        clip1 = squeeze(sequence(clip_l_start:clip_l_end));
        clip2 = squeeze(sequence(clip_r_start:clip_r_end));
        surround_e = (sum(clip1)+sum(clip2))/(length(clip1)+length(clip2));
        % disp(surround_e);
        if(thres*surround_e>pk1(j))
            pk1(j)=0; %屏蔽掉
        end
        pk2(j) = pk1(j)/surround_e;
    end
end