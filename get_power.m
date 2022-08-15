function [f,power]=get_power(y,fs)
    t = 0:(1/fs):(length(y)-1)/fs;
    n = pow2(nextpow2(length(t))); % 大于原始长度的最邻近的2的幂，提升fft效率
    f = (0:n/2-1)*(fs/n);
    Y = fftshift(fft(y,n));
    power = abs(Y).^2/n;
    power=power(floor(length(power)/2)+1:end)+power(floor(length(power)/2):-1:1);
    power=power/2;
end