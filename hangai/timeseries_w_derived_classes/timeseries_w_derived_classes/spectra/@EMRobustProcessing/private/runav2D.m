function y = runav2D(y,avrange)
nsets = avrange(2);
nf    = avrange(1);

if nsets>1
    windowSize = min(nsets,size(y,2));
    y = filter(ones(1,windowSize)/windowSize,1,y,[],2);
end

if nf>1
        windowSize = min(nf,size(y,1));
        y = filter(ones(1,windowSize)/windowSize,1,y,[],1);
end

