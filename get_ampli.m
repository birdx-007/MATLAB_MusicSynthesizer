function [f,ampli]=get_ampli(y,fs)
    t = 0:(1/fs):(length(y)-1)/fs;
    n = pow2(nextpow2(length(t))); % 大于原始长度的最邻近的2的幂，提升fft效率
    f = (0:n/2-1)*(fs/n);
    Y = fftshift(fft(y,n));
    ampli = abs(Y);
    ampli=ampli(floor(length(ampli)/2)+1:end)+ampli(floor(length(ampli)/2):-1:1);
    ampli=ampli/2;
end