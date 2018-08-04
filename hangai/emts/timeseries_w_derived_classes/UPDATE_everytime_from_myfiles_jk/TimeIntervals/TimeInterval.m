classdef TimeInterval
    % An interval, consisting of two TimePoints, or an array thereof. E.g.:
    %    
    % t = TimeInterval(t1,t2);    
    % t = TimeInterval([t1; t2]);
    %
    % where t1/t2 can be matlab format (see datenum), TimePoint objects,
    % datevec format or [datevec, millesecs].
    %
    % t = TimeInterval([datevec1,datevec2],[msec1 msec2]);    
    %
    % t = TimeInterval(datevec1,ms1,datevec2,ms2);    
    % t = TimeInterval(datevec1,datevec2,ms1,ms2);    
    %
    % t = TimeInterval(t);
    % 
    % t.vec    returns [t1.t1.vec,   t1.t2.vec; t2.t1.vec,   t2.t2.vec;   ...]
    % t.vecms  returns [t1.t1.vecms, t1.t2.vec; t2.t1.vecms, t2.t2.vecms; ...]
    %    
    % t.exclude_at_start(TimePointObject tp) 
    %          sets t.t1 to tp, returns [] if t.t2 < tp
    % t.exclude_at_end(TimePointObject tp) 
    %          sets t.t2 to tp, returns [] if t.t1 > tp
    % 
    % t.exclude_at_start(TimeIntervalObject ti) 
    %          sets t.t1 to ti.t2, returns [] if t.t2 < ti.t2
    % t.exclude_at_end(TimeIntervalObject ti) 
    %          sets t.t2 to ti.t1, returns [] if t.t1 > ti.t1
    % 
    % t.exclude_interval(ti)
    % t.exclude_interval(tp1,tp2)
    %     excludes an interval, cutting t in pieces.
    %     ti: TimeIntervalObject or a single input for the TimeInterval constructor
    %     tp1/tp2: TimePointObject or a single input for the TimePoint constructor
    %
    % t.keep_interval(ti)
    % t.keep_interval(tp1,tp2)
    %     keeps only an interval, cutting t in pieces.
    %     ti: TimeIntervalObject or a single input for the TimeInterval constructor
    %     tp1/tp2: TimePointObject or a single input for the TimePoint constructor
    %
    % t.remove_overap: reduce time interval to non-overlapping time
    %     intervals
    %
    % t.timepointarray: returns and array of TimePointObjects comprising
    %       the intervals
    %
    % true/false = t.is_within(tp);
    %
    % t.plot
    % t.plot(ypos)
    % t.plot(ypos, color)
    %
    % JK 11/2015
    
    properties
        t1
        t2
    end
    methods
        function T = TimeInterval(varargin)
            switch nargin
                case 0
                    t1 = TimePoint;
                    t2 = TimePoint;
                case 1
                    if isa(varargin{1},'TimePoint') && numel(varargin{1}) == 2
                        t1 = varargin{1}(1);
                        t2 = varargin{1}(2);
                    elseif isa(varargin{1},'TimeInterval')
                        t1 = varargin{1}.t1;
                        t2 = varargin{1}.t2;
                    elseif numel(varargin{1}) == 2
                        t1 = TimePoint(varargin{1}(1));
                        t2 = TimePoint(varargin{1}(2));                        
                    elseif numel(varargin{1})~=12 && numel(varargin{1})~=14
                        error('bad input');
                    elseif numel(varargin{1})==12
                        t1 = TimePoint(varargin{1}(1:6));
                        t2 = TimePoint(varargin{1}(7:12));
                    elseif numel(varargin{1})==14
                        t1 = TimePoint(varargin{1}(1:7));
                        t2 = TimePoint(varargin{1}(8:14));                        
                    end                    
                case 2
                    if isa(varargin{1},'TimePoint');
                        t1 = varargin{1};                    
                    elseif numel(varargin{1}) == 1 || numel(varargin{1}) == 6 || numel(varargin{1}) == 7
                        t1 = TimePoint(varargin{1});
                    elseif numel(varargin{1}) == 12 && numel(varargin{2}) == 2
                        t1 = TimePoint(varargin{1}(1:6),varargin{2}(1));
                    else
                        error('bad input');
                    end            
                    if isa(varargin{2},'TimePoint');
                        t2 = varargin{2};
                    elseif numel(varargin{2}) == 1 || numel(varargin{2}) == 6 || numel(varargin{2}) == 7
                        t2 = TimePoint(varargin{2});
                    elseif numel(varargin{1}) == 12 && numel(varargin{2}) == 2
                        t2 = TimePoint(varargin{1}(7:12),varargin{2}(2));
                    else
                        error('bad input');
                    end            
                case 4
                    if numel(varargin{1}) == 6 && numel(varargin{2}) == 2
                        t1 = TimePoint(varargin{1},varargin{2});
                    else
                        error('bad input');
                    end 
                    if numel(varargin{3}) == 6 && numel(varargin{4}) == 2
                        t2 = TimePoint(varargin{3},varargin{4});
                    else
                        error('bad input');
                    end 
                        
            end
            if t2 < t1;
                 t2tmp = t2;
                 t2 = t1;
                 t1 = t2tmp;
            end
            T.t1 = t1;
            T.t2 = t2;
        end
        function v = vec(T)
            v = [];
            for ind = 1 : numel(T)
                v = [v; T(ind).t1.vec T(ind).t2.vec];
            end
        end
        function v = vecms(T)
            v = [];
            for ind = 1 : numel(T)
                v = [v; T(ind).t1.vecms T(ind).t2.vecms];
            end            
        end
        function T2 = remove_overlap(T)
            % order of start and end points
            tp = T.timepointarray;
            [~, in] = tp.sort;
            
            % count how many times any point touches/is within any interval
            % and keep only those points that are counted exactly once             
            ids = [];
            for ind = 1 : 2 : numel(in)-1
                l = find(in == ind) : find(in == ind+1);
                ids = [ids in(l)];
            end
            inc = find(histc(ids,1:numel(in))==1);
            ine = [];
            for ind = 1 : numel(in);
                fd = find(inc == in(ind));
                if ~isempty(fd)
                    ine = [ine in(ind)];
                end
            end
            
            % construct the non-overlapping intervals          
            for ind = 1 : numel(ine)/2
                T2(ind) = TimeInterval(tp(ine(2*ind-1)),tp(ine(2*ind)));
            end
            T2 = T2(:);
                        
        end
        function T2 = remove_empty(T)
            rem = [];
            for ind = 1 : T.N
                if all(T(ind).duration.vecms==0)
                    rem = [rem, ind];
                end
            end
            T2 = T;
            T2(rem) = [];
            if isempty(T2)
                T2 = TimeInterval(zeros(1,12));
            end
        end
        function T2 = cleanup(T)
            T2 = T.remove_overlap.remove_empty;
        end
        function T3 = exclude_at_start(T,t)
            if T.N > 1
                T3 = [];
                for ind = 1 : T.N
                    T3 = [T3; T(ind).exclude_at_start(t)];
                end
                return
            end
            
            if isa(t,'TimeInterval')
                t = t.t2;
            elseif ~isa(t,'TimePoint')
                t = TimePoint(t);
            end            
            if t > T.t2
                T3 = TimeInterval(T.t2,T.t2);
            elseif t < T.t1
                T3 = T;
            else
                T3 = TimeInterval(t, T.t2);
            end       
            T3 = T3.cleanup;
        end
        function T3 = exclude_at_end(T,t)
            if T.N > 1
                T3 = [];
                for ind = 1 : T.N
                    T3 = [T3; T(ind).exclude_at_end(t)];
                end
                return
            end
            
            if isa(t,'TimeInterval')
                t = t.t1;
            elseif ~isa(t,'TimePoint')                            
                t = TimePoint(t);
            end            
            if t < T.t1
                T3 = TimeInterval(T.t1,T.t1);
            elseif t > T.t2
                T3 = T;
            else
                T3 = TimeInterval(T.t1,t);
            end
            T3 = T3.cleanup;
        end
        function tp = timepointarray(T)
            for ind = 1 : T.N
                tp(2*ind-1) = T(ind).t1;
                tp(2*ind)   = T(ind).t2;
            end
        end
        function n = N(T)
            n = numel(T);
        end
        function d = duration(T)
            if T.N > 1;
                for ind = 1 : T.N
                    d(ind) = T(ind).duration;
                end
                return
            end
            d = TimePoint(T.t2 - T.t1);
        end
        function str = char(T)
            str = [];
            for ind = 1 : T.N
                str = [str; T(ind).t1.char,'   ->   ',T(ind).t2.char, '    (',T(ind).duration.char,')'];
            end
        end
        function disp(T)
            for ind = 1 : T.N
                disp(T(ind).char);
            end
        end
        function T3 = exclude_interval(T,varargin)
            switch numel(varargin)
                case 1
                    if ~isa(varargin{1},'TimeInterval');
                        t = TimeInterval(varargin{1});
                    else
                        t = varargin{1};
                    end                    
                case 2
                    if ~isa(varargin{1},'TimePoint');
                        t1 = TimePoint(varargin{1});
                    else
                        t1 = varargin{1};
                    end
                    if ~isa(varargin{2},'TimePoint');
                        t2 = TimePoint(varargin{2});
                    else
                        t2 = varargin{2};                        
                    end
                    t = TimeInterval(t1,t2);                    
            end
            if t.N > 1
                T3 = T;
                for ind = 1 : t.N
                    T3 = T3.exclude_interval(t(ind));
                end
                return
            end
            T3 = [T.exclude_at_end(t.t1); T.exclude_at_start(t.t2)];
            T3 = T3.cleanup;
        end
        function T3 = keep_interval(T,varargin)                  
            switch numel(varargin)
                case 1
                    if ~isa(varargin{1},'TimeInterval');
                        t = TimeInterval(varargin{1});
                    else
                        t = varargin{1};
                    end                    
                case 2
                    if ~isa(varargin{1},'TimePoint');
                        t1 = TimePoint(varargin{1});
                    else
                        t1 = varargin{1};
                    end
                    if ~isa(varargin{2},'TimePoint');
                        t2 = TimePoint(varargin{2});
                    else
                        t2 = varargin{2};                        
                    end
                    t = TimeInterval(t1,t2);                    
            end
            if t.N > 1;
                T3 = [];
                for ind = 1 : t.N
                    T3 = [T3; T.keep_interval(t(ind))];
                end
                return
            end
            
            T3 = T.exclude_at_end(t.t2).exclude_at_start(t.t1).cleanup;            
        end
        function d = datenum(T)
            if T.N > 1; d = zeros(T.N,2); for ind = 1 : numel(T); d(ind,:) = T(ind).datenum; end; end
            d = [T.t1.datenum T.t2.datenum];
        end
        function varargout = plot(T, ypos, col, w)
            if nargin < 4; w = 0.45; end
            if nargin < 3; col = []; end
            if nargin < 2; ypos = []; end
            if isempty(ypos); ypos = 1; end
            if isempty(col); col = [1 1 1]./2; end
            
            ih = ishold;
            if ~ih; hold on; end
            h = [];            
            w = ypos + [-1 1]*w;
            for ind = 1 : T.N
                t = T(ind).datenum;                                
                th = patch([t(1), t(2), t(2), t(1), t(1)], [w(1), w(1), w(2), w(2), w(1)],1, 'facecolor', col); 
                h = [h; th];
            end            
            if ~ih; hold off; end
            if nargout > 0; varargout{1} = h; end
        end
        function m = mean(T)            
            m = TimePoint(mean(T.timepointarray.datenum));
        end
        function m = min(T)
            m = TimePoint(min(T.timepointarray.datenum));
        end
        function m = max(T)
            m = TimePoint(max(T.timepointarray.datenum));
        end
        function m = minmax(T)
            m = TimeInterval([T.min; T.max]);
        end
        function tf = is_within(T,t)            
            tf = false(size(t));            
            tf(T.t1 <= t & t < T.t2) = true;
        end
        function m = largest(T)
            l = 1;
            for ind = 2 : T.N
                if T(l).duration < T(ind).duration
                    l = ind;
                end
            end
            m = T(l);
        end
        function T2 = pieces_of_max_length(T, t)
            ii = 1;
            for ind = 1 : numel(T)
                t1 = T(ind).t1;
                t2 = T(ind).t2;
                while t1 < t2
                    if t1+t < t2;
                        T2(ii) = TimeInterval(t1,t1+t);
                    else
                        T2(ii) = TimeInterval(t1,t2);
                    end
                    t1 = t1 + t;
                    ii = ii + 1;
                end
            end
        end
    end
end