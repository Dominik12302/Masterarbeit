function [date,msec] = time2cal(time,week)
%CN 2016
if nargin < 1 | nargin >3
  warning('Incorrect number of arguments');
  return;
end
[yr,mn,day] = jd2cal(gps2jd(week,time,0));
hour        = mod(day,1)*24;
day         = floor(day);
min         = mod(hour,1)*60;
hour        = floor(hour);
sec         = mod(min,1)*60;
min         = floor(min);
msec        = mod(sec,1)*1000;
sec         = floor(sec);
date        = [yr mn day hour min sec];
end