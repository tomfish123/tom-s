function H_est_final = Channel_Est(Y, Xp, pilot_loc, Nfft, N_sc, Ng, Nps, low_freq_zero, high_freq_zero, SNR, algo)
% function H_DFT = Channel_Est(Y, Xp, pilot_loc, Nfft, N_sc, Ng, Nps, low_freq_zero, high_freq_zero, SNR, algo)
% 信道估计函数
% Inputs:
%       Y         = Frequency-domain received signal       FFT后得到频域信号
%       Xp        = Pilot signal                           导频信号
%       pilot_loc = Pilot location                         导频位置
%       Nfft      = FFT size                               FFT长度
%       N_sc      = Pilot length                           导频长度
%       Ng        = CP length                              CP长度
%       Nps       = Pilot spacing                          导频间隔
%       low_freq_zero         = Zero padding index of LF   低频补充0的子载波索引
%       high_freq_zero        = Zero padding index of HF   高频补充0的子载波索引
%       SNR       = Signal-to-Noise Ratio[dB]              信噪比
%       algo      = Algorithm type                         算法类型
%                                                          'LS_linear'
%                                                          'LS_spline'
%                                                          'ML_linear'
%                                                          'ML_spline'
%                                                          'MMSE'
% output:
%       H_est_final     = Channel estimation result        输出信道估计值

            if strcmp(algo, 'LS_linear')
                H_est = LS_CE(Y, Xp, pilot_loc, N_sc,'linear'); 
                method = 'LS-linear'; % 使用线性插值的LS估计
            elseif strcmp(algo, 'LS_spline')
                H_est = LS_CE(Y, Xp, pilot_loc, N_sc ,'spline'); 
                method = 'LS-spline'; % 使用三次样条插值的LS估计
            elseif strcmp(algo, 'ML_linear')
                H_est  = ML(Y, Xp, pilot_loc, N_sc, Ng,'linear'); 
                method = 'ML_linear'; % 使用线性插值的ML估计
            elseif strcmp(algo, 'ML_spline')
                H_est = ML(Y, Xp, pilot_loc, N_sc, Ng,'spline'); 
                method = 'ML_spline'; % 使用三次样条插值的ML估计
            elseif strcmp(algo, 'MMSE')
                H_est = MMSE_CE(Y, Xp, pilot_loc, N_sc, Ng, Nps, SNR); 
                method = 'MMSE'; % MMSE估计
            end
            
            % H_est = [zeros(1, length(low_freq_zero)) H_est zeros(1, length(high_freq_zero))];
            h_est = ifft(H_est);   % 计算估计的信道系数
            h_DFT = h_est(1:Ng);   % 取前信道长度大小的信道系数，即忽略仅包含噪声的信道系数
            H_DFT = fft(h_DFT, Nfft);   % 补零至Nfft长度后进行fft，基于DFT的信道估计
            H_DFT = H_DFT(length(low_freq_zero)+1 : length(low_freq_zero) + N_sc);
            H_est_final = H_DFT.';

end