function w=generateMusic(fs,freqinfo,envinfo,envelop)
    basefreq=freqinfo(:,1)';
    baseampli=freqinfo(:,2)';
    starts=envinfo(:,1)';
    ends=envinfo(:,2)';
    peakampli=envinfo(:,4)';
    len=ends(end);
    w=zeros(1,len);
    for i=1:length(basefreq)
%         time=[0:1/fs:(len-cur_len)/fs];
%         e=(2*t(i)*time).^0.15.*exp(-4/t(i)*time);
        idx=[starts(i):ends(i)];
        e=peakampli(i)*resample(envelop,length(idx),length(envelop))';
        h=freqinfo(i,3:end);
        note=baseampli(i)*generateNote(fs,length(idx)/fs,basefreq(i),h);
        w(idx)=w(idx)+(note).*(e);
    end
end