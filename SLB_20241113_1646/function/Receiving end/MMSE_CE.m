function H_MMSE = MMSE_CE(Y,Xp,pilot_loc,N_sc, Ng, Nps, SNR)
%function H_MMSE = MMSE_CE(Y,Xp,pilot_loc,Nfft,Nps,h,ts,SNR)
% MMSE channel estimation function
% Inputs:
%       Y         = Frequency-domain received signal       FFT后得到频域信号
%       Xp        = Pilot signal                           导频信号
%       pilot_loc = Pilot location                         导频位置
%       Nfft      = FFT size                               FFT长度
%       Nps       = Pilot spacing                          导频间隔
%       h         = Channel impulse response               信号通过信道后产生的时延和衰减特性，路径的信道增益（取消）
%       ts        = Sampling time                          采样时间
%       ts        = Sampling time                          采样时间
%       SNR       = Signal-to-Noise Ratio[dB]              信噪比
% output:
%      H_MMSE     = MMSE channel estimate                  输出信道估计值


%H = fft(h,N);
snr = 10^(SNR*0.1);    % 将信噪比转化为比例单位

Np=length(pilot_loc);           % 每个OFDM符号中包括导频总数
k=1:Np;                % 导频计数序号索引

H_tilde(k) = Y(pilot_loc(k))./Xp(pilot_loc(k));  % LS estimate  LS信道估计算法得到H~
H_LS = interpolate(H_tilde,pilot_loc,N_sc,'linear'); 
h_LS = ifft(H_LS);
h_LS = h_LS(1:Ng);   % 取前信道长度大小的信道系数，即忽略仅包含噪声的信道系数
% % h_LS = [h_LS zeros(1, N_fft - length(h_LS))];
% H_DFT = fft(h_LS, N_fft);   % 补零至Nfft长度后进行fft，基于DFT的信道估计
% H_DFT = H_DFT(length(low_freq_zero)+1 : length(low_freq_zero) + N_sc);
% H_tilde = H_DFT;
% H_tilde = H_tilde(pilot_loc);
h = h_LS;

k=0:length(h)-1; %k_ts = k*ts;  % 路径时延索引
hh = h*h';             % 信道增益h * h共轭转置，根据信道增益计算路径总功率   
tmp = h.*conj(h).*k; %tmp = h.*conj(h).*k_ts;  所有路径的时延乘以对应路径的功率
r = sum(tmp)/hh;       % 信号在所有路径上的加权平均时延
r2 = tmp*k.'/hh; %r2 = tmp*k_ts.'/hh;   每条路径的时延平方乘以功率的加权和，表示时延平方的加权平均
tau_rms = sqrt(r2-r^2);     % rms delay  多径效应平均时延rms

df = 1/N_sc;  %1/(ts*Nfft);   子载波间隔，1/fft点数
j2pi_tau_df = j*2*pi*tau_rms*df;
K1 = repmat([0:N_sc-1].',1,Np);    % Nfft*Np 大小的矩阵，子载波总数*导频总数，列递增
K2 = repmat([0:Np-1],N_sc,1);      % Nfft*Np 大小的矩阵，子载波总数*导频总数，行递增
rf = 1./(1+j2pi_tau_df*(K1-K2*Nps));   % 频域相关rf，即公式中RHH~，大小为Nfft*Np

K3 = repmat([0:Np-1].',1,Np);       % Np*Np 大小的矩阵，导频总数*导频总数，列递增
K4 = repmat([0:Np-1],Np,1);         % Np*Np 大小的矩阵，导频总数*导频总数，行递增
rf2 = 1./(1+j2pi_tau_df*Nps*(K3-K4));   % RHH，大小Np*Np

Rhp = rf;
Rpp = rf2 + eye(length(H_tilde),length(H_tilde))/snr; % （RHH + 信噪比^(-1)的对角矩阵），大小为Np*Np
H_MMSE = transpose(Rhp*inv(Rpp)*H_tilde.');  % MMSE channel estimate 带入公式求出信道估计值

% H_MMSE = H_LS;