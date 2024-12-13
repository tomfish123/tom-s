
function [mout] = msequence_generate(n, taps, inidata,out_length)

% ****************************************************************
% n         : The order n of the m-sequence
% taps      : Feedback register connection position
% inidata   : Sequence of initial values of registers
% out_length: Output length
% mout      : The output m-sequence
% ****************************************************************

inidata = reshape(inidata,1,[]);

mout = zeros(out_length,1);
fpos = zeros(n,1);

fpos(taps) = 1;     % Set the connection to 1

for i=1:out_length+1600

    mout(i) = inidata(n);                        % The output m-sequence
    temp = mod(inidata*fpos,2);              % Calculation of feedback data

    inidata(2:n) = inidata(1:n-1);                  % Register shifted once
    inidata(1) = temp;                          % Update the value of the 1st register

end
mout(1:1600)=[];

end