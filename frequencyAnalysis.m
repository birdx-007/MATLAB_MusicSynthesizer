function freqinfo=frequencyAnalysis(w,fs,envinfo,envelop)
    % 傅里叶区域的起点在音符中的位置
    rstart=find(envelop>=max(envelop,[],'all')*0.85,1)/length(envelop);
    %rstart=0.2;
    % 傅里叶区域的长度在音符中的占比
    rlen=find(envelop>=max(envelop,[],'all')*0.85,1,'last')/length(envelop)-rstart;
    %rlen=0.4;
    n=40; % 区域重复次数

    startspos=envinfo(:,1);
    endspos=envinfo(:,2);
    peakspos=envinfo(:,3);
    peaksampli=envinfo(:,4);
    noteslen=endspos-startspos;
    basefreqs=zeros(length(noteslen),1);
    %wb=waitbar(0,'0.00%','Name','Analyzing...');
    freqinfo=zeros(length(basefreqs),2+9);
    for i=1:length(peakspos)
        start=startspos(i,1)+round(noteslen(i,1)*rstart);
        len=round(noteslen(i,1)*rlen);
        f=w(start:start+len-1);
        f=repmat(f,[n,1]);
        % 加窗
        window=[zeros(floor(len*n/3),1);hanning(ceil(len*n*2/3))];
        window=window+[hanning(ceil(len*n*2/3));zeros(floor(len*n/3),1)];
        f=f.*window;
        [freq,F]=get_power(f,fs);
        [m,midx]=max(F);
        mfreq=freq(midx);
        Fh=F; % 分析谐波用
        F(F<m/2.5)=0; % 去除功率过小点
        dF=diff(F);
        F(find(dF(1:end-1).*dF(2:end)>0)+1)=0; % 去除非极大值点
        basefreqs(i,1)=mfreq;
        baseidx=midx;
        basepower=m;
        F(midx:end,1)=0; % 基频点必然不大于最大功率点
        candidates=find(F>0)';
        candidates=candidates(end:-1:1);
        for cidx=candidates
            r=midx/cidx;
            delta=min([r-floor(r),ceil(r)-r]);
            if delta<0.1
                basefreqs(i,1)=freq(cidx);
                baseidx=cidx;
                basepower=F(cidx);
            end
        end

        Fh(Fh<basepower*0.01)=0; % 去除功率过小点
        h=zeros(1,9);
        rmin=2^(-1/12);
        rmax=2^(1/12);
        for j=2:10
            hidx=j*baseidx;
            if ceil(hidx*rmin)>=length(Fh)
                break;
            end
            range=[ceil(hidx*rmin):min(floor(hidx*rmax),length(Fh))];
            hcandidates=find(Fh(range)>0)+range(1)-1;
            if ~isempty(hcandidates)
                [~,hcidx]=min(abs(hcandidates-hidx));
                hcpower=Fh(hcandidates(hcidx));
                h(j-1)=hcpower/basepower;
            end
        end
        freqinfo(i,3:end)=h;
        %waitbar(i/length(pos),wb,sprintf('%12.2f%%: %12.2fHz %12.2fs',i/length(pos)*100,basefreqs(i,1),notelen(i,1)/fs));
    end
    %delete(wb);
    freqinfo(:,1)=basefreqs(:,1); % notebasefreq
    freqinfo(:,2)=peaksampli; % noteampli
end