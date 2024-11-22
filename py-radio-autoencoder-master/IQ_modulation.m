clear; clc

%% 全局变量
Ts=0.01;                    % 时间分辨率（时间间隔），抽样时间间隔
t=0:Ts:10;                  % 时间坐标
N=length(t);                % 时间坐标点数
fs=1/Ts;                    % 抽样频率
df=fs/(N-1);                % df为频率分辨率（频率间隔）
n=-(N-1)/2:(N-1)/2;         % 频率坐标点数
f=n*df;                     % 频率坐标

%基带信号
figure
p=[1 0 1 1 0 1 0 0 1 1];            % 待传送的编码
d1=0:1:t(end)-1;                    % 每个编码的发送延迟时间
p1=zeros(length(d1)-length(p));     % 在发送串后补零
d=[d1;p1];         %产生d矩阵
tm=pulstran(t-0.5, d, 'rectpuls');
subplot(2, 1, 1)
plot(tm)
axis([t(1) t(end) -0.5 1.5])
grid on
title('基带信号p')

%基带信号频谱
M=fft(tm);
M=fftshift(M);
subplot(2, 1, 2)
plot(abs(M)/N)
title('基带信号频谱')

%抽取IQ信号  BPSK只映射一路I。QPSK两个基带符号为一组，映射到一对IQ
figure
pQI=reshape（p25）;
pQ=pQI（1:）;
pI=pQI（2:）;
d2=[0:2:t（end）-2];
dQ=[d2;pQ]‘;
dI=[d2;pI]‘;
mI=pulstran（t-1dI‘rectpuls‘2）;
mQ=pulstran（t-1dQ‘rectpuls‘2）;
subplot（211）
plot（tmI）
axis（[t（1） t（end） -0.5 1.5]）
grid on
title（‘I路抽取‘）
subplot（212）
plot（tmQ）
axis（[t（1） t（end） -0.5 1.5]）
grid on
title（‘Q路抽取‘）
%IQ值映射   “0”映射成1，“1”映射成-1
figure
I（pI==1）=-1;
I（pI==0）=1;
Q（pQ==1）=-1;
Q（pQ==0）=1;
dImap=[d2;I]‘;
dQmap=[d2;Q]‘;
mImap=pulstran（t-1dImap‘rectpuls‘2）;
mQmap=pulstran（t-1dQmap‘rectpuls‘2）;
subplot（211）
plot（tmImap）
axis（[t（1） t（end） -1.5 1.5]）
grid on
title（‘映射后的I路信号‘）
subplot（212）
plot（tmQmap）
axis（[t（1） t（end） -1.5 1.5]）
grid on
title（‘映射后的Q路信号‘）

%载波信号
fc=5                 %载波频率;
c1=cos（2*pi*fc*t）;
c2=sin（2*pi*fc*t）;
%载波信号频谱
figure
C1=fft（c1）;
C1=fftshift（C1）;
subplot（211）
plot（fabs（C1）/N）
title（‘载波cos频谱‘）
C2=fft（c2）;
C2=fftshift（C2）;
subplot（212）
plot（fabs（C2）/N）
title（‘载波sin频谱‘）;

%已调信号
figure
s1=mImap.*c1;
subplot（311）
plot（ts1）
axis（[t（1） t（end） -1.5 1.5]）
title（‘I路调制cos‘）
grid on
s2=mQmap.*c2;
subplot（312）
plot（ts2）
axis（[t（1） t（end） -1.5 1.5]）
title（‘Q路调制sin‘）;
grid on
s=s1-s2;
subplot（313）
plot（ts）
axis（[t（1） t（end） -1.5 1.5]）
title（‘进入信道的信号s=s1-s2‘）
grid on

%已调信号频谱
figure
S1=fft（s1）;
S1=fftshift（S1）;
subplot（311）
plot（fabs（S1）/N）
title（‘s1频谱‘）
S2=fft（s2）;
S2=fftshift（S2）;
subplot（312）
plot（fabs（S2）/N）
title（‘s2频谱‘）
S=fft（s）;
S=fftshift（S）;
subplot（313）
plot（fabs（S）/N）
title（‘s频谱‘）

%通过信道后接收到信号
figure
r=awgn（s10）;
subplot（211）
plot（tr）
axis（[t（1） t（end） -1.5 1.5]）
title（‘接收信号时域‘）
%接收信号的频谱
R=fft（r）;
R=fftshift（R）;
subplot（212）
plot（fabs（R）/N）
title（‘接收信号频域‘）

%解调
figure
y1=r.*c1;
subplot（211）
plot（ty1）
axis（[t（1） t（end） -1.5 1.5]）
title（‘I路解调‘）
y2=r.*（-c2）;
subplot（212）
plot（ty2）
axis（[t（1） t（end） -1.5 1.5]）
title（‘Q路解调‘）


%解调后从时域积分（求和）判决
y1sum=0;
y2sum=0;
for i=1:5
    y1sum（i）=sum（y1（200*（i-1）+1:200*i））;
    y2sum（i）=sum（y2（200*（i-1）+1:200*i））;
end 
y1d=sign（y1sum）;
y2d=sign（y2sum）;

%反映射
y1rmap（y1d==1）=0;
y1rmap（y1d==-1）=1;


