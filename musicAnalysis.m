[w,fs]=audioread('.\data\fmt.wav');
[envinfo,envelop]=envelopeAnalysis(w,fs);
freqinfo=frequencyAnalysis(w,fs,envinfo,envelop);
wr=generateMusic(fs,freqinfo,envinfo,envelop);
wr=wr/max(wr,[],'all')*max(w,[],'all');
figure,plot(w),hold on, plot(wr),hold off;
audiowrite("data\result.wav",wr,fs);