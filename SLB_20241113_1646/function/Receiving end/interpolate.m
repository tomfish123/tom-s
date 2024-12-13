function H_interpolated = interpolate(H_est,pilot_loc,Nfft,method)
% Input:        H_est    = Channel estimate using pilot sequence   插值前估计值
%           pilot_loc    = location of pilot sequence    导频对应子载波序号
%                Nfft    = FFT size      FFT总长度，即总载波数
%              method    = 'linear'/'spline'   插值方式
% Output: H_interpolated = interpolated channel

if pilot_loc(1)>1       %当第一条导频对应子载波序号非1时
  slope = (H_est(2)-H_est(1))/(pilot_loc(2)-pilot_loc(1));  % 计算前两个导频对应估计值的斜率
  H_est = [H_est(1)-slope*(pilot_loc(1)-1)  H_est];         % 通过斜率计算出子载波序号为1的点插到H_est开头
  pilot_loc = [1 pilot_loc];                                % 在导频对应子载波序号开头插入序号1 
end
if pilot_loc(end)<Nfft    %当最后导频对应子载波序号非Nfft（子载波总数）时
  slope = (H_est(end)-H_est(end-1))/(pilot_loc(end)-pilot_loc(end-1));    % 计算后两个导频对应估计值的斜率
  H_est = [H_est  H_est(end)+slope*(Nfft-pilot_loc(end))];                % 通过斜率计算出子载波序号为Nfft的点插到H_est开头
  pilot_loc = [pilot_loc Nfft];                                           % 在导频对应子载波序号开头插入序号最大子载波序号Nfft
end
if lower(method(1))=='l'
    H_interpolated = interp1(pilot_loc,H_est,[1:Nfft]);              % 将（2+导频数）长度的估计值线性插值成Nfft长度的估计值
else
    H_interpolated = interp1(pilot_loc,H_est,[1:Nfft],'spline');     % 三次样条插值
end  