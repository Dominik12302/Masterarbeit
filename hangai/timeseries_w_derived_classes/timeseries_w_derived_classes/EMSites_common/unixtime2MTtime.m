function [mt,mms] = unixtime2MTtime(ut,ums)

% [mt,mms] = unixtime2MTtime(ut,ums)
%
% convert unix time used by Spam4 to EMTS time format [yr m d h m s];
% second argument is optional: spam4 microseconds -> EMTS milliseconds
%
% (seconds since 1970, ignoring switch seconds,
% see https://en.wikipedia.org/wiki/Unix_time)

str = datestr(ut./86400 + datenum(1970,1,1),30);

mt(1) = str2double(str(1:4));
mt(2) = str2double(str(5:6));
mt(3) = str2double(str(7:8));

mt(4) = str2double(str(10:11));
mt(5) = str2double(str(12:13));
mt(6) = str2double(str(14:15));

if nargout > 1;
    mms = [];
    if nargin > 1;
        mms = ums./1000;
    end
end