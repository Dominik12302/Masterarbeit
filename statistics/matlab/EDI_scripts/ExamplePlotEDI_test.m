% merge edi files
edipath = 'D:\MONGOLEI_PROJECT\DATA_2016\processing_2016\FINAL_EDIS';
% provide the edi path, the output name and pairs of input edifiles, period
% range to be merged
%MergeEDI(edipath,'2105','2105b_512hz.edi',[0.003 0.1],'2105b_rr3300b_64hz.edi',[0.1 3000])
plotEDI(edipath,'1000B2','1000B.edi',[0.003 10000])
