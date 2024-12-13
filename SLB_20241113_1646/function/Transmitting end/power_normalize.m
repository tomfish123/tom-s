function [outputsignal,judge_coef] = power_normalize(inputsignal)
    
    real_power = sum(abs(inputsignal).^2,"all")/numel(inputsignal);
    judge_coef = sqrt(real_power);
    outputsignal = inputsignal./judge_coef;

%     sum(abs(outputsignal).^2)/length(outputsignal)        % 测试输出功率

end