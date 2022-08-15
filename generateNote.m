function w = generateNote(fs,t,f0,varargin)
    time=[0:1/fs:t-1/fs];
    w=sin(2*pi*f0*time);
    A=1;
    R=cell2mat(varargin);
    for i=1:length(R)
        f=f0*(i+1);
        r=R(i);
        w=w+sin(2*pi*f*time)*r;
        A=A+r;
    end
    w=w/A;
end