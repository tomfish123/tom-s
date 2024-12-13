function [H_LS,LS_est] = LS_CE(Y,Xp,pilot_loc,N_sc,int_opt)
% LS channel estimation function
% Inputs:
%       Y         = Frequency-domain received signal  FFT��õ�Ƶ���ź�
%       Xp        = Pilot signal   ��Ƶ�ź�
%       pilot_loc = Pilot location   ��Ƶλ��
%       Nfft      = FFT size   FFT����
%       Nps       = Pilot spacing   ��Ƶ���
%       int_opt   = 'linear' or 'spline'   ��ֵ��ʽ
% output:
%       H_LS      = LS channel etimate     ����ŵ�����ֵ

Np=length(pilot_loc);    %  ÿ��OFDM�����а�����Ƶ����
k=1:Np;         %  ��Ƶ�������


LS_est(k) = Y(pilot_loc(k))./Xp(pilot_loc(k));  % LS channel estimation ��Ƶ�������ȵ��ŵ�����ֵ
if  lower(int_opt(1))=='l'
    method='linear';         %% ѡ�����Բ�ֵ
else
    method='spline';         %% ѡ������������ֵ
end

%����Ƶ�������ȵĹ���ֵ����ֵ��ȫ�����ز���Nfft���ȵĹ���ֵ��Ϊ������õ��������ŵ���Ӧ
H_LS = interpolate(LS_est,pilot_loc,N_sc,method); % Linear/Spline interpolation