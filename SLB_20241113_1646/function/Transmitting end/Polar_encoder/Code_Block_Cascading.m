function [E_seq] = Code_Block_Cascading(E_seq_segmented)
%{
    This function is used to cascade encoded code blocks.
    input: 
        1. E_seq_segmented (is a cell variable, the encoded bit sequence set for every code block)
    output:
        1. E_seq (is a matrix variable, the cascaded encoded bit sequence for every code block)
%}

    C_total = length(E_seq_segmented);
    E_seq = [];
    for i = 1:C_total
        E_seq = [E_seq E_seq_segmented{i}];
    end
end
