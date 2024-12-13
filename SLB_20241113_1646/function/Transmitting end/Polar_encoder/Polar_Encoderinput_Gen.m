function [u] = Polar_Encoderinput_Gen(Encode_Parameters, B_seq, N, Q_N_I)
%{
    This function is used to calculate the code block's number of bits after encoding.
    input: 
        1. Encode_Parameters (the parameters for polar encoding and rate matching)
        2. B_seq (one of the segmented input bit sequences)
        3. N (the code block's length after encoding)
        4. Q_N_I (the set composed of bit indexes of information bits)
    output:
        1. u (the input bit sequences set for encoder)
%}
    
    % Currently, only the situation without parity bits is supported. Others will be added later.
    k = 1;
    l = 1;
    u = zeros([1, N]);
    if Encode_Parameters.Coding_mode == 0
        if Encode_Parameters.n_PC > 0  % with parity bits
            % To be continued.——6.9.2.2.2
        else  % without parity bits
            for n = 1:N
                if ismember(n, Q_N_I)
                    u(n) = B_seq(k);
                    k = k+1;
                else
                    u(n) = 0;
                end
            end
        end
    end
end

