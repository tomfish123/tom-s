function H_interpolated = interpolate(H_est,pilot_loc,Nfft,method)
% Input:        H_est    = Channel estimate using pilot sequence   ��ֵǰ����ֵ
%           pilot_loc    = location of pilot sequence    ��Ƶ��Ӧ���ز����
%                Nfft    = FFT size      FFT�ܳ��ȣ������ز���
%              method    = 'linear'/'spline'   ��ֵ��ʽ
% Output: H_interpolated = interpolated channel

if pilot_loc(1)>1       %����һ����Ƶ��Ӧ���ز���ŷ�1ʱ
  slope = (H_est(2)-H_est(1))/(pilot_loc(2)-pilot_loc(1));  % ����ǰ������Ƶ��Ӧ����ֵ��б��
  H_est = [H_est(1)-slope*(pilot_loc(1)-1)  H_est];         % ͨ��б�ʼ�������ز����Ϊ1�ĵ�嵽H_est��ͷ
  pilot_loc = [1 pilot_loc];                                % �ڵ�Ƶ��Ӧ���ز���ſ�ͷ�������1 
end
if pilot_loc(end)<Nfft    %�����Ƶ��Ӧ���ز���ŷ�Nfft�����ز�������ʱ
  slope = (H_est(end)-H_est(end-1))/(pilot_loc(end)-pilot_loc(end-1));    % �����������Ƶ��Ӧ����ֵ��б��
  H_est = [H_est  H_est(end)+slope*(Nfft-pilot_loc(end))];                % ͨ��б�ʼ�������ز����ΪNfft�ĵ�嵽H_est��ͷ
  pilot_loc = [pilot_loc Nfft];                                           % �ڵ�Ƶ��Ӧ���ز���ſ�ͷ�������������ز����Nfft
end
if lower(method(1))=='l'
    H_interpolated = interp1(pilot_loc,H_est,[1:Nfft]);              % ����2+��Ƶ�������ȵĹ���ֵ���Բ�ֵ��Nfft���ȵĹ���ֵ
else
    H_interpolated = interp1(pilot_loc,H_est,[1:Nfft],'spline');     % ����������ֵ
end  