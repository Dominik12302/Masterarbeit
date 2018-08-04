% example code
sp = EMSpectra('D:\DCtrain\A02\fd\346_V01_C00_R007_BL_512H.afc');
% sp = EMSpectra('D:\local\Dropbox\RadioMT_HeiligesMeer\4\fd\122_V01_C05_R000_BH_524288H.afc');
% sp = EMSpectra('D:\data\TestmessungRMT\fd\122_V01_C05_R003_BH_524288H.afc');
=======

spAnode = EMSpectra('/local/Promotion/Software/tmpfun/Shift_Ede_data/corrected/ADU/anode/fd/125_V01_C00_R000_BL_64H.afc');
spS002   = EMSpectra('/local/Promotion/Software/tmpfun/Shift_Ede_data/corrected/ADU/s002/fd/002_EDE_C01_R000_BL_64H.afc');
>>>>>>> .r271
name = '1';
idec        = 5;
chs         = {'Ex'};
% for every decimation level: intersect window ids
widanode = spAnode.header.W(idec,1):sum(spAnode.header.W(idec,:)-1);
wids002 = spS002.header.W(idec,1):sum(spS002.header.W(idec,:)-1);
[c, ia, ib] = intersect(widanode, wids002);
spAnode.setrange = [ia];
spS002.setrange  = [ib];
% Ex tfthres
fi = 0;
<<<<<<< .mine
for ib = 9:12
    fi = fi+1;
    f(fi)   = sp.bs.fcenter{idec}(ib);
    disp(['   +++ Target frequency is ' num2str(f(fi)/1000,'%1.f') ' kHz +++']);
    sp.fcrange  = [sp.bs.fc{idec}{ib}(1) sp.bs.fc{idec}{ib}(end)];
    %     if ib ==3, sp.fcrange = [1000 1180];  end
    %     if ib ==5, sp.fcrange = [465   495];  end
    %     if ib ==6, sp.fcrange = [300   350];  end
    sp.dec      = idec;
=======
for ib  = 1:12
    fi          = fi+1;
    f(fi)       = spAnode.bs.fcenter{idec}(ib);
    spAnode.fcrange  = [1 63]; %[spAnode.bs.fc{idec}{ib}(1) spAnode.bs.fc{idec}{ib}(end)];
    spAnode.dec      = idec;
    spS002.fcrange   = [1 63]; %[spS002.bs.fc{idec}{ib}(1) spS002.bs.fc{idec}{ib}(end)];
    spS002.dec = idec;
    
    
>>>>>>> .r271
    for ich = 1:numel(chs)
<<<<<<< .mine
        sp.output   =  chs(ich);
        sp.input    = {'Bx' 'By'};
        Y = sp.Y;
        switch sp.output{1}
            case 'Ex'
                dim = size(Y);
                ff  = sqrt(f(fi)./sp.f');
                fac =  ff(:,ones(1,dim(2:end)));
            case 'Ey'
                dim = size(Y);
                ff  = sqrt(f(fi)./sp.f');
                fac = ff(:,ones(1,dim(2:end)));
            otherwise
                fac = 1;
        end
%         fac         = 1;
        proc        = EMRobustProcessing(Y.*fac,sp.X);
        proc.f      = sp.f;
        proc.t      = sp.t;
        proc.input  = sp.input;
        proc.output = sp.output;
        proc.avrange= [4 4];
=======
        spAnode.output   = {''};
        spAnode.input    = {'Ex'};
         spS002.output   = {'Ex'};
        spS002.input    = {''};
        figure; 
        imagesc(spS002.setrange,spS002.f,log10(abs(spS002.Y)));
        proc        = EMRobustProcessing(sp.f,spAnode.Y,spAnode.X);
        proc.avrange= [2 10];
>>>>>>> .r271
        proc.smooth = 'runav';
        switch sp.output{1}
            case 'Bz'
                proc.bicohthresf = {};
                proc.bicohthresg = {[0.7 1]};
                proc.bicohthrest = {};
            otherwise
                if ib > 6
                    proc.bicohthresf = {};
                    proc.bicohthresg = {};
                    proc.bicohthrest = {[0.7 1]};
                else
                    proc.bicohthresf = {};
                    proc.bicohthresg = {[0.7 1]};
                    proc.bicohthrest = {};
                end
        end
        proc.reg         = 'fc';
        [Zf,Zfse]        = computetf(proc);
        Z(ich,:,fi)      = Zf;
        Zse(ich,:,fi)    = Zfse;
    end
end
%
tf.locname = name;
tf.lnch    = numel(chs);
tf.lchname = chs;
tf.lchid   = [1:numel(chs)]+2;
tf.bname  =  name;
tf.bnch    = proc.Ninput;
tf.bchname = sp.input;
tf.bchid   = 1:numel(sp.input);
% if irs, tf.rname = snames(rbs); end
tf.nper = numel(f);
tf.periods = 1./f';
tf.tf   = Z;
tf.tf_se = Zse;
sp_plottf(tf);

%%
% plotbicoh(sp,proc,'kHz','relative s')
% set(gcf,'Paperpositionmode','auto');
% fname = ['bicoh' sp.output{1} num2str(round(f/1000)) 'kHz_tfp.eps'];
% print('-depsc',fullfile('D:\data\Baumberge_311013\fd\',fname));
% plottfs(sp,proc,[-1.5 0.5])
% set(gcf,'Paperpositionmode','auto');
% fname = ['tfs' sp.output{1} num2str(round(f/1000)) 'kHz_tfp.eps'];
% print('-depsc',fullfile('D:\data\Baumberge_311013\fd\',fname));
% % ib = 12: proc.tfsthres    = {[-0.71 -0.55 0.2 2]}; 6 kHz
% % ib = 11: proc.tfsthres    = {[-0.66 -0.63 0.2 2]}; 8 kHz
% % ib = 10: proc.tfsthres    = {[-0.68 -0.69 0.2 2]};
% % ib = 09: proc.tfsthres    = {[-0.61 -0.68 0.2 2]};
% % ib = 08: proc.tfsthres    = {[-0.64 -0.74 0.2 2]};
% % ib = 07: proc.tfsthres    = {[-0.57 -0.69 0.2 2]};
% % ib = 06: proc.tfsthres    = {[-0.55 -0.63 0.2 2]};
% % ib = 05: proc.tfsthres    = {[-0.45  -0.65 0.2 2]};
% % ib = 04: proc.tfsthres    = {[-0.44 -0.6 0.2 2]};
% % ib = 03: proc.tfsthres    = {[-0.42 -0.6 0.2 2]};
% % ib = 02: proc.tfsthres    = {[-0.39 -0.66 0.2 2]};
% % ib = 01: proc.tfsthres    = {[-0.33 -0.64 0.2 2]};
