% plots table with runtimes between stations and also makes a cell with
% runtimes in days
clear all;

load('runtimes_2017_spam.mat');
overlap = {};
runtimes = ans;

for i = 1:numel(runtimes)
    for j = 1:numel(runtimes)
        dur = 0; % sums up the runtimes of different runs for a total runtime
        for k = 1:numel(runtimes(i).start)
            a1 = runtimes(i).start{k};
                a1 = datetime(a1(1),a1(2),a1(3),a1(4),a1(5),a1(6));
            a2 = runtimes(i).stop{k};
                a2 = datetime(a2(1),a2(2),a2(3),a2(4),a2(5),a2(6));   
            for l = 1:numel(runtimes(j).start)
                b1 = runtimes(j).start{l};
                    b1 = datetime(b1(1),b1(2),b1(3),b1(4),b1(5),b1(6));
                b2 = runtimes(j).stop{l};
                    b2 = datetime(b2(1),b2(2),b2(3),b2(4),b2(5),b2(6));                    
                if ((a1 < b1) && (a2 > b1) && (a2 < b2)) % overlap
                    start = b1;
                    stop = a2;
                    dur = dur + days(abs(duration(start-stop,'format','d')));
                elseif ((a1 < b1) && (a2 < b1)) % no overlap
                    dur = dur + 0;
                elseif ((b1 < a1) && (b2 > a1) && (b2 < a2)) % overlap
                    start = a1;
                    stop = b2;            
                    dur = dur + days(abs(duration(start-stop,'format','d')));
                elseif ((b1 < a1) && (b2 < a1)) % no overlap
                    dur  = dur + 0;
                elseif ((a1 < b1) && (a2 > b2)) % overlap
                    start = b1;
                    stop = b2;
                    dur = dur + days(abs(duration(start-stop,'format','d')));
                elseif ((b1 < a1) && (b2 > a2)) % overlap
                    start = a1;
                    stop = a2;
                    dur = dur + days(abs(duration(start-stop,'format','d')));
                end
            end
        end
        overlap{i,j} = dur;
    end
end
% table(overlap,'RowNames',[{runtimes.sitename}],'VariableNames',[{runtimes.sitename}]);


