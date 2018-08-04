%% copy copy copy

load('tfswithbases.mat')
load('gps_ede.mat')

for i=1:numel(gps_data)
   for j=1:numel(gps_t)
       if (strcmp(char(gps_data(i).sitename),char(gps_t(j).sitename)))
           gps_data(i).lat = gps_t(j).lat;
           gps_data(i).long = gps_t(j).lon;
       end
   end
end




































