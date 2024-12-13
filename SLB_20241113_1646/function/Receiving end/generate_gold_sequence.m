function c = generate_gold_sequence(M_PN, C_init)

    if nargin < 2
        C_init = 60;
    end

    length_x1x2 = M_PN + 1600;
    x1 = zeros(1, 31); 
    x1(1) = 1;
    for i = 1 : (length_x1x2-31)
        x1 = [x1 mod(x1(i+3)+x1(i),2)];
    end
    
    binaryString = dec2bin(C_init, 31);
    binaryArray = flip(double(binaryString) - '0');
    x2 = binaryArray;
    for i = 1 : (length_x1x2-31)
        x2 = [x2 mod(x2(i+3)+x2(i+2)+x2(i+1)+x2(i),2)];
    end 
    
    c = zeros(1,M_PN);
    for i = 1:M_PN
        c(i) = mod(x1(i+1600) + x2(i+1600),2);
    end

end
