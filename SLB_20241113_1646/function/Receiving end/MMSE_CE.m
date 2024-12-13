function H_MMSE = MMSE_CE(Y,Xp,pilot_loc,N_sc, Ng, Nps, SNR)
%function H_MMSE = MMSE_CE(Y,Xp,pilot_loc,Nfft,Nps,h,ts,SNR)
% MMSE channel estimation function
% Inputs:
%       Y         = Frequency-domain received signal       FFT��õ�Ƶ���ź�
%       Xp        = Pilot signal                           ��Ƶ�ź�
%       pilot_loc = Pilot location                         ��Ƶλ��
%       Nfft      = FFT size                               FFT����
%       Nps       = Pilot spacing                          ��Ƶ���
%       h         = Channel impulse response               �ź�ͨ���ŵ��������ʱ�Ӻ�˥�����ԣ�·�����ŵ����棨ȡ����
%       ts        = Sampling time                          ����ʱ��
%       ts        = Sampling time                          ����ʱ��
%       SNR       = Signal-to-Noise Ratio[dB]              �����
% output:
%      H_MMSE     = MMSE channel estimate                  ����ŵ�����ֵ


%H = fft(h,N);
snr = 10^(SNR*0.1);    % �������ת��Ϊ������λ

Np=length(pilot_loc);           % ÿ��OFDM�����а�����Ƶ����
k=1:Np;                % ��Ƶ�����������

H_tilde(k) = Y(pilot_loc(k))./Xp(pilot_loc(k));  % LS estimate  LS�ŵ������㷨�õ�H~
H_LS = interpolate(H_tilde,pilot_loc,N_sc,'linear'); 
h_LS = ifft(H_LS);
h_LS = h_LS(1:Ng);   % ȡǰ�ŵ����ȴ�С���ŵ�ϵ���������Խ������������ŵ�ϵ��
% % h_LS = [h_LS zeros(1, N_fft - length(h_LS))];
% H_DFT = fft(h_LS, N_fft);   % ������Nfft���Ⱥ����fft������DFT���ŵ�����
% H_DFT = H_DFT(length(low_freq_zero)+1 : length(low_freq_zero) + N_sc);
% H_tilde = H_DFT;
% H_tilde = H_tilde(pilot_loc);
h = h_LS;

k=0:length(h)-1; %k_ts = k*ts;  % ·��ʱ������
hh = h*h';             % �ŵ�����h * h����ת�ã������ŵ��������·���ܹ���   
tmp = h.*conj(h).*k; %tmp = h.*conj(h).*k_ts;  ����·����ʱ�ӳ��Զ�Ӧ·���Ĺ���
r = sum(tmp)/hh;       % �ź�������·���ϵļ�Ȩƽ��ʱ��
r2 = tmp*k.'/hh; %r2 = tmp*k_ts.'/hh;   ÿ��·����ʱ��ƽ�����Թ��ʵļ�Ȩ�ͣ���ʾʱ��ƽ���ļ�Ȩƽ��
tau_rms = sqrt(r2-r^2);     % rms delay  �ྶЧӦƽ��ʱ��rms

df = 1/N_sc;  %1/(ts*Nfft);   ���ز������1/fft����
j2pi_tau_df = j*2*pi*tau_rms*df;
K1 = repmat([0:N_sc-1].',1,Np);    % Nfft*Np ��С�ľ������ز�����*��Ƶ�������е���
K2 = repmat([0:Np-1],N_sc,1);      % Nfft*Np ��С�ľ������ز�����*��Ƶ�������е���
rf = 1./(1+j2pi_tau_df*(K1-K2*Nps));   % Ƶ�����rf������ʽ��RHH~����СΪNfft*Np

K3 = repmat([0:Np-1].',1,Np);       % Np*Np ��С�ľ��󣬵�Ƶ����*��Ƶ�������е���
K4 = repmat([0:Np-1],Np,1);         % Np*Np ��С�ľ��󣬵�Ƶ����*��Ƶ�������е���
rf2 = 1./(1+j2pi_tau_df*Nps*(K3-K4));   % RHH����СNp*Np

Rhp = rf;
Rpp = rf2 + eye(length(H_tilde),length(H_tilde))/snr; % ��RHH + �����^(-1)�ĶԽǾ��󣩣���СΪNp*Np
H_MMSE = transpose(Rhp*inv(Rpp)*H_tilde.');  % MMSE channel estimate ���빫ʽ����ŵ�����ֵ

% H_MMSE = H_LS;