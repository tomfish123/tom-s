clear; clc

%% ȫ�ֱ���
Ts=0.01;                    % ʱ��ֱ��ʣ�ʱ������������ʱ����
t=0:Ts:10;                  % ʱ������
N=length(t);                % ʱ���������
fs=1/Ts;                    % ����Ƶ��
df=fs/(N-1);                % dfΪƵ�ʷֱ��ʣ�Ƶ�ʼ����
n=-(N-1)/2:(N-1)/2;         % Ƶ���������
f=n*df;                     % Ƶ������

%�����ź�
figure
p=[1 0 1 1 0 1 0 0 1 1];            % �����͵ı���
d1=0:1:t(end)-1;                    % ÿ������ķ����ӳ�ʱ��
p1=zeros(length(d1)-length(p));     % �ڷ��ʹ�����
d=[d1;p1];         %����d����
tm=pulstran(t-0.5, d, 'rectpuls');
subplot(2, 1, 1)
plot(tm)
axis([t(1) t(end) -0.5 1.5])
grid on
title('�����ź�p')

%�����ź�Ƶ��
M=fft(tm);
M=fftshift(M);
subplot(2, 1, 2)
plot(abs(M)/N)
title('�����ź�Ƶ��')

%��ȡIQ�ź�  BPSKֻӳ��һ·I��QPSK������������Ϊһ�飬ӳ�䵽һ��IQ
figure
pQI=reshape��p25��;
pQ=pQI��1:��;
pI=pQI��2:��;
d2=[0:2:t��end��-2];
dQ=[d2;pQ]��;
dI=[d2;pI]��;
mI=pulstran��t-1dI��rectpuls��2��;
mQ=pulstran��t-1dQ��rectpuls��2��;
subplot��211��
plot��tmI��
axis��[t��1�� t��end�� -0.5 1.5]��
grid on
title����I·��ȡ����
subplot��212��
plot��tmQ��
axis��[t��1�� t��end�� -0.5 1.5]��
grid on
title����Q·��ȡ����
%IQֵӳ��   ��0��ӳ���1����1��ӳ���-1
figure
I��pI==1��=-1;
I��pI==0��=1;
Q��pQ==1��=-1;
Q��pQ==0��=1;
dImap=[d2;I]��;
dQmap=[d2;Q]��;
mImap=pulstran��t-1dImap��rectpuls��2��;
mQmap=pulstran��t-1dQmap��rectpuls��2��;
subplot��211��
plot��tmImap��
axis��[t��1�� t��end�� -1.5 1.5]��
grid on
title����ӳ����I·�źš���
subplot��212��
plot��tmQmap��
axis��[t��1�� t��end�� -1.5 1.5]��
grid on
title����ӳ����Q·�źš���

%�ز��ź�
fc=5                 %�ز�Ƶ��;
c1=cos��2*pi*fc*t��;
c2=sin��2*pi*fc*t��;
%�ز��ź�Ƶ��
figure
C1=fft��c1��;
C1=fftshift��C1��;
subplot��211��
plot��fabs��C1��/N��
title�����ز�cosƵ�ס���
C2=fft��c2��;
C2=fftshift��C2��;
subplot��212��
plot��fabs��C2��/N��
title�����ز�sinƵ�ס���;

%�ѵ��ź�
figure
s1=mImap.*c1;
subplot��311��
plot��ts1��
axis��[t��1�� t��end�� -1.5 1.5]��
title����I·����cos����
grid on
s2=mQmap.*c2;
subplot��312��
plot��ts2��
axis��[t��1�� t��end�� -1.5 1.5]��
title����Q·����sin����;
grid on
s=s1-s2;
subplot��313��
plot��ts��
axis��[t��1�� t��end�� -1.5 1.5]��
title���������ŵ����ź�s=s1-s2����
grid on

%�ѵ��ź�Ƶ��
figure
S1=fft��s1��;
S1=fftshift��S1��;
subplot��311��
plot��fabs��S1��/N��
title����s1Ƶ�ס���
S2=fft��s2��;
S2=fftshift��S2��;
subplot��312��
plot��fabs��S2��/N��
title����s2Ƶ�ס���
S=fft��s��;
S=fftshift��S��;
subplot��313��
plot��fabs��S��/N��
title����sƵ�ס���

%ͨ���ŵ�����յ��ź�
figure
r=awgn��s10��;
subplot��211��
plot��tr��
axis��[t��1�� t��end�� -1.5 1.5]��
title���������ź�ʱ�򡮣�
%�����źŵ�Ƶ��
R=fft��r��;
R=fftshift��R��;
subplot��212��
plot��fabs��R��/N��
title���������ź�Ƶ�򡮣�

%���
figure
y1=r.*c1;
subplot��211��
plot��ty1��
axis��[t��1�� t��end�� -1.5 1.5]��
title����I·�������
y2=r.*��-c2��;
subplot��212��
plot��ty2��
axis��[t��1�� t��end�� -1.5 1.5]��
title����Q·�������


%������ʱ����֣���ͣ��о�
y1sum=0;
y2sum=0;
for i=1:5
    y1sum��i��=sum��y1��200*��i-1��+1:200*i����;
    y2sum��i��=sum��y2��200*��i-1��+1:200*i����;
end 
y1d=sign��y1sum��;
y2d=sign��y2sum��;

%��ӳ��
y1rmap��y1d==1��=0;
y1rmap��y1d==-1��=1;


