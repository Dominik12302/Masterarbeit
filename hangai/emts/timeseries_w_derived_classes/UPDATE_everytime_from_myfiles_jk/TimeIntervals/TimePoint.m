classdef TimePoint
    % A point along the time axis, or an array thereof. For example:
    %
    % yr = 2015; month = 11; d = 15; h = 7; min = 41; sec = 0; ms = 12;
    %        
    % time = [year month day h min sec];     
    % timems = [time, ms]
    %
    % or
    %
    % time = datenum([year month day h min sec])
    %
    % then construct the object using, e.g.:
    % t  = TimePoint(time);
    % t  = TimePoint(timems);
    % t  = TimePoint(time, ms);    
    % t  = TimePoint(t);
    % t  = TimePoint(yr,month,d,h,min,sec);
    % t  = TimePoint(yr,month,d,h,min,sec, ms);
    %         
    % shift by eg. 1 hour:
    % t3 = t.shift([0 0 0 1 0 0]);
    % to start to t2
    % t3 = t.shift(t2-t);
    %
    % comparison operators (i.e., =>, >, <, >=, ==) work, but not on
    % arrays of TimePoints!
    % 
    % arithmetic + and - works.
    %
    % t.issorted    returns if all members of an array are sorted in
    %               ascending order
    % [tsorted, idx] = t.sort    returns sorted array and idx, where tsorted = t(idx)
    %
    % t.time    time in the format [year month day hour minute sec], all
    %           intergers, milliseconds truncated
    % t.timems  milliseconds, not necessarily an integer
    % t.N       corresponds to numel(t)
    % t.vec     matrix of form [t(1).time;             t(2).time;             ...]
    % t.vecms   matrix of form [t(1).time t(1).timems; t(2).time t(2).timems; ...]
    % 
    % note: times < 1498 years are shown as durations, but it has no
    %               bearings on calculations
    % JK 11/2015
    %
    % WARNING: If you want to put a duration of 1 month, [0 0 1 0 0 0]
    % won't work, because the month can never be zero in matlab, such that
    % both 1 and 0 zero are assumed january.
    
    properties (Dependent = false,  SetAccess = private)
        mtime    % matlab time
    end
    methods 
        function T = TimePoint(varargin)
            switch nargin
                case 0
                    time = [0 0 0 0 0 0];
                    timems = 0;
                case 1
                    if isa(varargin{1},'TimePoint')                        
                        time =   varargin{1}.time;
                        timems = varargin{1}.timems;
                    elseif numel(varargin{1}) == 1;
                        time = datevec(varargin{1});
                        timems = 0;
                    elseif numel(varargin{1}) == 6;
                        time   = varargin{1};
                        timems = 0;
                    elseif numel(varargin{1}) == 7;
                        time   = varargin{1}(1:6);
                        timems = varargin{1}(7);
                    else
                        error('bad input');
                    end
                case 2
                    if numel(varargin{1}) == 6;
                        time   = varargin{1};
                        timems = varargin{2};
                    elseif numel(varargin{1}) == 1;
                        time = datevec(varargin{1});
                        timems = varargin{2};                        
                    else
                        error('bad input');
                    end
                case 6
                    time   = [varargin{1} varargin{2} varargin{3} varargin{4} varargin{5} varargin{6}];
                    timems = 0;
                case 7
                    time   = [varargin{1} varargin{2} varargin{3} varargin{4} varargin{5} varargin{6}];
                    timems = varargin{7};  
                otherwise
                    error('bad input');
            end
            time(6) = time(6) + timems/1000;
            T.mtime = datenum(time);        
            if any(isnan(T.mtime)); T.mtime = NaN; end
        end
        function t = time(T) 
            if isnan(T); t = NaN(1,6); return; end
            t = datevec(T.mtime);            
            t(6) = t(6) - mod(t(6),1);
            t = datevec(datenum(t));
        end
        function ms = timems(T)
            t = datevec(T.mtime);            
            ms = 1000*mod(t(6),1);            
        end
        function T2 = shift(T,varargin)
            if T.N > 1;
                for ind = 1 : T.N
                    T2(ind) = T(ind).shift(varargin{:});
                end
                return
            end
            
            if ~isa(varargin{1},'TimePoint')
                D = TimePoint(varargin{1});
            else
                D = varargin{1};
            end                                  
            T2 = TimePoint(T.mtime + D.mtime);              
        end  
        function tf = eq(T,T2)
            if numel(T) == 1;
                tf = false(size(T2));
            elseif numel(T2) == 1;
                tf = false(size(T));
            else
                error('bad sizes in comparison');
            end
            tf([T(:).mtime] == [T2(:).mtime]) = true;
        end
        function tf = ne(T,T2)
            tf = ~T.eq(T2);
        end
        function tf = lt(T,T2)
            if numel(T) == 1;
                tf = false(size(T2));
            elseif numel(T2) == 1;
                tf = false(size(T));
            else
                error('bad sizes in comparison');
            end
            tf([T(:).mtime] < [T2(:).mtime]) = true;
        end
        function tf = le(T,T2)
            tf = T.lt(T2) | T == T2;
        end
        function tf = gt(T,T2)
            if numel(T) == 1;
                tf = false(size(T2));
            elseif numel(T2) == 1;
                tf = false(size(T));
            else
                error('bad sizes in comparison');
            end
            tf([T(:).mtime] > [T2(:).mtime]) = true;                        
        end
        function tf = ge(T,T2)
            tf = T.gt(T2) | T == T2;
        end
        function v = vec(T)
            v = [];
            for ind = 1 : T.N
                v =[v;  T.time]; 
            end
        end
        function v = vecms(T)
            v = [];
            for ind = 1 : T.N                
                v = [v; T.time T.timems];
            end
        end
        function T3 = plus(T,T2)
            T3 = T.shift(T2);
        end
        function T3 = minus(T,T2)
            T3 = T.shift(-T2);
        end
        function T3 = uminus(T)
            T3 = TimePoint(-T.mtime);
        end    
        function tf = issorted(T)
            tf = true;
            for ind = 2 : T.N
                if T(ind-1) > T(ind)
                    tf = false; return
                end                                 
            end
        end
        function [T2, idx] = sort(T)
            % simple insertion sort
            T2 = T;
            idx = 1 : T.N;
            if ~T2.issorted
                for ind = 2 : T2.N
                    ii = ind;
                    while ii > 1 && T2(ii-1) > T2(ii)
                        tmp = T2(ii-1);
                        T2(ii-1) = T2(ii);
                        T2(ii) = tmp;
                        
                        tmp = idx(ii-1);
                        idx(ii-1) = idx(ii);
                        idx(ii) = tmp;
                        
                        ii = ii - 1;
                    end
                end
            end
        end
        function n = N(T)
            n = numel(T);
        end
        function str = char(T)
            str = [];
            for ind = 1 : T.N
                if T(ind).mtime > 547134
                    str = [str; datestr(T(ind).time,31),' ',num2str(T(ind).timems),'ms'];
                else
                    t = T(ind).time;
                    if T(ind).mtime < 30; t(2) = 0; end
                    str = [str; char(calendarDuration(t(1),t(2),t(3),t(4),t(5),t(6))),' ',num2str(T(ind).timems),'ms'];                    
                end
            end
        end
        function disp(T)
            for ind = 1 : numel(T)
                disp(T(ind).char)
            end            
        end
        function d = datenum(T)
            if T.N > 1; d = zeros(size(T)); for ind = 1 : T.N; d(ind) = T(ind).datenum; end; return; end
            d = T.mtime;
        end
        function  s = sum(T)
            s = T(1);
            for ind = 1 : T.N
                s = s + T(ind);
            end
        end
        function tf = isnan(T)
            tf = isnan(T.mtime);
        end
    end
end