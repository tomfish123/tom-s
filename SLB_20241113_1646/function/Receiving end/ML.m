function H_ML = ML(Y,Xp,pilot_loc,Nfft,M,int_opt)
% LS channel estimation function
% Inputs:
%       Y         = Frequency-domain received signal  FFT后得到频域信号
%       Xp        = Pilot signal   导频信号
%       pilot_loc = Pilot location   导频位置
%       Nfft      = FFT size   FFT长度
%       Nps       = Pilot spacing   导频间隔
%       M         = 假设的有效信道长度
%       int_opt   = 'linear' or 'spline'   插值方式
% output:
%       H_ML      = ML channel etimate     输出信道估计值

Np=length(pilot_loc);    %  每个OFDM符号中包括导频总数
k=1:Np;         %  导频计数序号

Fm = zeros(Np, M); % 初始化
for k_n = 1:Np
    for i_n = 1:M
        Fm(k_n,i_n) = exp(-1i*2*pi*(i_n-1)*(k_n-1)/Nfft);
    end
end

Q = Fm*inv(Fm'*Fm)*Fm';
LS_est(k) = Y(pilot_loc(k))./Xp(pilot_loc(k));  % LS channel estimation 导频总数长度的信道估计值
ML_est = Q*(LS_est.');
if  lower(int_opt(1))=='l'
    method='linear';         %% 选择线性插值
else
    method='spline';         %% 选择三次样条插值
end

%将导频总数长度的估计值，插值成全部子载波数Nfft长度的估计值作为输出，得到完整的信道响应
H_ML = interpolate((ML_est.'),pilot_loc,Nfft,method); % Linear/Spline interpolation
