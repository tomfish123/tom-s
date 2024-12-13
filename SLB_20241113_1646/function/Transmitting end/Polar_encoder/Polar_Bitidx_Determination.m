function [Q_N_I, Q_N_F, Q_N_Iext, Q_N_Ichk] = Polar_Bitidx_Determination(Encode_Parameters, K, N, E, J)
%{
    This function is used to calculate the code block's number of bits after encoding.
    input: 
        1. Encode_Parameters (the parameters for polar encoding and rate matching)
        2. K (the  code block's length)
        3. N (the code block's length after encoding)
        4. E (the code block's length after rate matching)
        5. J (the intermediate parameter of sub-block interleaving from Sub_Block_Interleaving.m)
    output:
        1. Q_N_I (the set composed of bit indexes of information bits)
        2. Q_N_F (the set composed of indexes of frozen bits)
        3. Q_N_Iext (the set composed of bit indexes of extended information bits)
        4. Q_N_Ichk (the set composed of bit indexes of copied bits)
%}

    if nargin < 6  % for initial transmission
        if Encode_Parameters.Coding_mode == 0
            
            % get the Q_N_1, which represents Q^(N-1)_0 in 6.9.2.2.2
            load('Table_C_1.mat')
            Q_Nmax_1 = Table_C_1(:, 2)';
            Q_N_1 = Q_Nmax_1(Q_Nmax_1 <= N-1)+1;
            
            Q_N_F_tmp = [];
            if E<N
                if K/E <= 7/16
                    for n = 1:N-E
                        Q_N_F_tmp = union(Q_N_F_tmp, J(n));
                    end
                    if E >= 3*N/4
                        Q_N_F_tmp = union(Q_N_F_tmp, [1:ceil(3*N/4-E/2)]);
                    else
                        Q_N_F_tmp = union(Q_N_F_tmp, [1:ceil(9*N/16-E/4)]);
                    end
                else
                    for n = E+1:N
                        Q_N_F_tmp = union(Q_N_F_tmp, J(n));
                    end
                end
            end
            Q_N_I_tmp = Q_N_1(~ismember(Q_N_1, Q_N_F_tmp));
            Q_N_I = Q_N_I_tmp(end+1-K-Encode_Parameters.n_ext_CRC-Encode_Parameters.n_PC: end);
            Q_N_F = Q_N_1(~ismember(Q_N_1, Q_N_I));
            Q_N_Iext = [];
            Q_N_Ichk = [];
    else  % for retransmission
        % To be continued.——6.9.2.3.2
    end
end

