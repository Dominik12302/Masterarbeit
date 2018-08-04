% plots table with runtimes between stations
clear all;

load('/var/run/media/d_harp01/Data/runtimes/runtimes.mat');
overlap = zeros(numel(runtimes),numel(runtimes));

for i = 1:numel(runtimes)
    for j = 1:numel(runtimes)
        a1 = runtimes(i).start{1};
            a1 = datetime(a1(1),a1(2),a1(3),a1(4),a1(5),a1(6));
        a2 = runtimes(i).stop{numel(runtimes(i).stop)};
            a2 = datetime(a2(1),a2(2),a2(3),a2(4),a2(5),a2(6));
        b1 = runtimes(j).start{1};
            b1 = datetime(b1(1),b1(2),b1(3),b1(4),b1(5),b1(6));
        b2 = runtimes(j).stop{numel(runtimes(j).stop)};
            b2 = datetime(b2(1),b2(2),b2(3),b2(4),b2(5),b2(6));
        if ((a1 < b1) && (a2 > b1)) % overlap
            start = b1;
            stop = a2;
            overlap(i,j) = abs(duration(start-stop,'format','d'));
        elseif ((a1 < b1) && (a2 < b1)) % no overlap
            start = 0;
            stop = 0;
            overlap(i,j) = abs(duration(start-stop,'format','d'));
        elseif ((b1 < a1) && (b2 > a1)) % overlap
            start = a1;
            stop = b2;
            overlap(i,j) = abs(duration(start-stop,'format','d'));
        elseif ((b1 < a1) && (b2 < a1)) % no overlap
            start = 0; 
            stop = 0;
            overlap(i,j) = abs(duration(start-stop,'format','d'));
        end
    end
end