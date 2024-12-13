function gen_wave = seq_t_gen(wave_symbol)
% 生成一个ofdm符号的时域波形
%  wave_symbol: 一个符合的子载波对应的序列

    % pad zero
    gen_wave_pad = zeros(256,1);
    gen_wave_pad(48:208) = wave_symbol;
    % ifft
    gen_wave = ifft(gen_wave_pad);
end