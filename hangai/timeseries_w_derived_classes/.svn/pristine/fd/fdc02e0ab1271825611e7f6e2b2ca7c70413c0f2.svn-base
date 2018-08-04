function [normalDate status] = jl2normaldate(jl_dates,dateFormat)
% Function Description:
% This function accepts Julian Date vector (jl_dates, numerical type), and
% writes the output in a character vector (normalDate). The output
% character date format can be defined in the second input variable 
% (dateFormat), or the default 'dd-mmm-yyyy HH:MM:SS' string date format 
% will be used. 
% Julian Date input format: yyyyddd, e.g, 01 Jan 2009 = 2009001 or 
% 31 Dec 2009 = 2009365. Normal date output format can be 'dd-mmm-yyyy' 
% (e.g., 31-Dec-2009).
%
%   The function is suitable to convert Julian Date with the above format 
% to normal date. It is useful for processing of remote sensing datasets
% available in HDF-EOS format, such as MODIS LST or AMSR datasets, where
% Julian Date is part of each HDF_EOS file-name. To extract date of
% observation in these dataset, Julian Date part can be extracted from the
% file name (e.g., in MODIS LST L3 datasets JL-Date is given in 10th till
% 16th characters in the file name). Using this function, these dates can
% be converted to normal date.
% 
% --Inputs: 
%   jl_dates: one or a vector of numerical Julian dates (7 digits: 0000000)
%   dateFormat: format of the output string date (optional)
% --Outputs:
%   normalDate: a character vector of output date(s)
%   status: a string character giving information about possible warnings
%   which will be generated if the input jl_dates vector does not follow
%   required conditions.
%--------------------------------------------------------------------------
% First Version: 01 Nov 2011 (V01)
% Updated: Jun 06 2012
% Email: sohrabinia.m@gmail.com
%--------------------------------------------------------------------------

if nargin <1
    disp('Error! at least one argument must be provided');
    return;
elseif nargin <2
    dateFormat='dd-mmm-yyyy HH:MM:SS';    
end

tst1=jl_dates(1)/1000000;
tst2=jl_dates(1)/10000000;
if tst1<1 || tst1>9 || floor(tst2)>0
    fprintf(['Warning! input Julian dates should be numeric formatted '...
        'yyyyddd,\n where yyyy is year and ddd is days out of 365 (or '...
        '366 for leap years)\n']);
    status='returned with warnings';
else
    status='Returned with no warning';
end


years  = floor(jl_dates/1000);
days   = jl_dates-years*1000;
months = ['Jan';'Feb';'Mar';'Apr';'May';'Jun';'Jul';'Aug';'Sep';'Oct';...
    'Nov';'Dec'];
% work out dates:
normalDate = cell(length(days),1);
yr1=0;
j=1;
for i=1:length(years)
    diff=years(i)-yr1;
    if diff>0
        yrEnd(j)=i-1; %first element will be the end of non-exsitant year
        yr1=yr1+diff;
        yrs(j)=yr1;
        j=j+1;
    end
end
yrEnd(j)=i;     %last element will be the end of last year in data
for jj=1:length(yrs)
    ly = leapyear(yrs(jj)); %check if the year is a leap year (yes:1, no:0)
    if ly == 0
        dMonths = [31;28;31;30;31;30;31;31;30;31;30;31]; %days of months 
                   % in normal years
    else
        dMonths = [31;29;31;30;31;30;31;31;30;31;30;31]; %days of months 
                   % in leap-years
    end
    for j = (yrEnd(jj)+1):yrEnd(jj+1) %start from beg of the yr go to end 
                   % of that yr
        i = 1;
        while days(j) > dMonths(i)
            days(j) = days(j)-dMonths(i);
            i = i+1;
        end
        mnth           = months(i,1:end);    %this is the month of the 
                          % original Julian day
        dy             = num2str(days(j));   %actual day after subtracting 
                          % cumulative days of earlier months
        normalDate{j}= strcat(dy,'-',mnth,'-',num2str(yrs(jj))); %write 
                         % string dates in cell-array
    end
end
normalDate = datestr(datenum(normalDate),dateFormat);
end %end of function

