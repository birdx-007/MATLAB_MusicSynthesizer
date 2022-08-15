function [envinfo,envelop] = envelopeAnalysis(x,fs)
    samplenum=340; %e1处理时采样点数目
    kmax=length(x)/800000/fs; %尖峰处理时的阈值斜率

    totalT=length(x)/fs;
    dt=1/fs;
    t=[0:dt:totalT-dt];
    %e1 曲线包络
    e1=abs(hilbert(x));
    e1=resample(e1,samplenum,length(x),5,20);
    e1=resample(e1,length(x),samplenum,5,20);
    e1=max(0,e1);
    e1(length(t)+1:end)=[];
    %e2 折线包络
    de1=diff(e1);
    d1=de1(1:length(de1)-1);
    d2=de1(2:length(de1));
    idx2=[1;find(d1.*d2<0)+1;length(e1)];
    e2=interp1(t(idx2),e1(idx2),t)';
    e2(isnan(e2))=0;
    
    figure;
    subplot(4,1,1),box on;
    plot(t,x),hold on,plot(t,e1),plot(t,e2),hold off;
    set(gca,'XTick',[]);
    
    % 尖峰
    de2=diff(e2);
    d1=de2(1:length(de2)-1);
    d2=de2(2:length(de2));
    peaks=e2;
    peaks(d1.*d2>0)=0;
    peaks(de2<kmax)=0;
    [a3,idx3]=findpeaks(e2,'MinPeakDistance',0.1*fs,'MinPeakProminence',0.04);
    peaks(idx3-1)=a3;
    peakspos=find(peaks>1e-3);
    peaksampli=peaks(peakspos);
    % 起音点+结束点
    starts=e2;
    starts(1)=0;
    starts(end)=0;
    starts(starts<1e-2)=max(starts,[],'all');
    starts=-starts;
    [~,idx4]=findpeaks(starts,'MinPeakDistance',0.1*fs,'MinPeakProminence',0.008);
    startspos=idx4;

    subplot(4,1,2),box on;
    plot(t,x),hold on,plot(t,peaks),plot(idx3/fs,a3,'ro'),plot(t,starts),plot(idx4/fs,0,'ro'),hold off;
    set(gca,'XTick',[]);
    
    % 将每个音符的信息打包成矩阵，并生成平均包络
    envinfo=zeros(length(peakspos),4);
    envelop=zeros(1000,1);
    envinfo(:,3)=peakspos;
    envinfo(:,4)=peaksampli;
    notecnt=1;
    for i=1:length(peakspos)
        % 根据峰值位置定位音符的始终
        while peakspos(i)<startspos(notecnt) || peakspos(i)>startspos(notecnt+1)
            notecnt=notecnt+1;
        end
        % 抛去太短的结束点
        j=1;
        while startspos(notecnt+j)-peakspos(i)<0.065*fs
            j=j+1;
        end
        envinfo(i,1)=startspos(notecnt);
        envinfo(i,2)=startspos(notecnt+j);
        esample=e1(startspos(notecnt):startspos(notecnt+j));
        envelop=envelop+resample(esample,1000,length(esample))*peaksampli(i);
    end
    envelop=max(envelop-envelop(end),0);
    envelop=envelop/max(envelop,[],'all');
    
    subplot(4,1,3),box on;
    plot(t,x),hold on,plot(envinfo(:,3)/fs,envinfo(:,4),'rx'),plot(envinfo(:,1)/fs,0,'rx'),plot(envinfo(:,2)/fs,0,'rx'),hold off;
    set(gca,'XTick',[]);
    subplot(4,1,4),box on;
    plot([0:1000-1],envelop);
    set(gca,'XTick',[]);
end