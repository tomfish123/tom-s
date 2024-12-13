function [Encode_Parameters] = Encode_Parameters_Gen(Retransmission_flag, Information_type, K_r, N_r, E_r, N_RV0)
%{
    This function is used to obtain the parameters for polar encoding and rate matching.——6.9.2.5 & 6.9.2.6
    input: 
        1. Retransmission_flag (0 for initial transmission and 1 for retransmission)
        2. Information_type (1 for the first type of data information array transmission; 2 for Control information transmission; 3 for the first type of data information encapsulated transmission, second type of data information transmission and variable-length part information transmission of preamble)
        3. K_r (the r_th code block's length)
        4. N_r (the r_th code block's length after encoding)
        5. E_r (the r_th code block's length after rate matching)
        6. N_RV0 ()
    output:
        1. Encode_Parameters (the parameters for polar encoding and rate matching)
%}

    if nargin < 3
        if Retransmission_flag == 0
            Encode_Parameters.Coding_mode = 0;
        else
            Encode_Parameters.Coding_mode = 1;
        end
        
        if Information_type == 1
            Encode_Parameters.n_max = 7;
        elseif Information_type == 2
            Encode_Parameters.n_max = 10;
        elseif Information_type == 3
            Encode_Parameters.n_max = 12;
        end
    elseif nargin < 6  % only for initial transmission
        if Information_type == 1
            if K_r<18 || K_r>25
                Encode_Parameters.Coding_mode = 0;
                Encode_Parameters.n_max = 7;
                Encode_Parameters.n_ext_CRC = 0;
                Encode_Parameters.n_PC = 0;
            else
                Encode_Parameters.Coding_mode = 0;
                Encode_Parameters.n_max = 7;
                Encode_Parameters.n_ext_CRC = 0;
                Encode_Parameters.n_PC = 3;
                if E_r-K_r+3 > 192
                    Encode_Parameters.n_wm_PC = 1;
                else
                    Encode_Parameters.n_wm_PC = 0;
                end
            end
            Encode_Parameters.M_r = N_r;  % M_r is the length of the bit sequence input for rate matching
        elseif Information_type == 2
            if K_r<18 || K_r>25
                Encode_Parameters.Coding_mode = 0;
                Encode_Parameters.n_max = 10;
                Encode_Parameters.n_ext_CRC = 0;
                Encode_Parameters.n_PC = 0;
            else
                Encode_Parameters.Coding_mode = 0;
                Encode_Parameters.n_max = 10;
                Encode_Parameters.n_ext_CRC = 0;
                Encode_Parameters.n_PC = 3;
                if E_r-K_r+3 > 192
                    Encode_Parameters.n_wm_PC = 1;
                else
                    Encode_Parameters.n_wm_PC = 0;
                end
            end
            Encode_Parameters.M_r = N_r;  % M_r is the length of the bit sequence input for rate matching
        elseif Information_type == 3
            Encode_Parameters.Coding_mode = 0;
            Encode_Parameters.n_max = 12;
            Encode_Parameters.n_ext_CRC = 0;
            Encode_Parameters.n_PC = 0;
            Encode_Parameters.M_r = N_r;
        end
    else  % for retransmission
        % To be continued.——6.9.2.6.2
    end
end

