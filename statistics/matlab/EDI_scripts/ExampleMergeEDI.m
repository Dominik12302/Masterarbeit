% merge edi files
edipath = 'D:\MONGOLEI_PROJECT\INVERSION\2D_inversion_Emilia\EDIS\l2_n';
% provide the edi path, the output name and pairs of input edifiles, period
% range to be merged
MergeEDI(edipath,'2920T-2950B_ExEy-BxBy_ct0.9-1_512Hz_13h_20170609170001-20170610055959_2cc.edi','2980B-ref3950B_ExEy-BxBy_ct0.8-1_Bz-BxBy_ct0-1_64Hz_38h_20170612130000-20170614030000_512Hz_10h_20170613100001-20170613195959.edi',[0.001 1000])