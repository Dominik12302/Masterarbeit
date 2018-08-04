function varargout = ts_robustfit(X,Xr,y,wfun,tune,const)
%TS_ROBUSTFIT Robust linear regression
%
%   The robustfit function modified to include reference channels
%   MB 2012
%
%   B = ROBUSTFIT(X,Xr,Y) returns the vector B of regression coefficients,
%   obtained by performing robust regression to estimate the linear model
%   Y = Xb.  X is an n-by-p matrix of predictor variables, Xr is a n-by-p
%   matrix of reference variables and Y is an
%   n-by-1 vector of observations.  The algorithm uses iteratively
%   reweighted least squares with the bisquare weighting function.  By
%   default, ROBUSTFIT adds a column of ones to X, corresponding to a
%   constant term in the first element of B.  Do not enter a column of ones
%   directly into the X matrix.
%
%   B = ROBUSTFIT(X,Y,'WFUN',TUNE) uses the weighting function 'WFUN' and
%   tuning constant TUNE.  'WFUN' can be any of 'andrews', 'bisquare',
%   'cauchy', 'fair', 'huber', 'logistic', 'talwar', or 'welsch'.
%   Alternatively 'WFUN' can be a function that takes a residual vector as
%   input and produces a weight vector as output.  The residuals are scaled
%   by the tuning constant and by an estimate of the error standard
%   deviation before the weight function is called.  'WFUN' can be
%   specified using @ (as in @myfun).  TUNE is a tuning constant that is
%   divided into the residual vector before computing the weights, and it
%   is required if 'WFUN' is specified as a function.
%
%   B = ROBUSTFIT(X,Y,'WFUN',TUNE,'CONST') controls whether or not the
%   model will include a constant term.  'CONST' is 'on' (the default) to
%   include the constant term, or 'off' to omit it.
%
%   [B,STATS] = ROBUSTFIT(...) also returns a STATS structure
%   containing the following fields:
%       'ols_s'     sigma estimate (rmse) from least squares fit
%       'robust_s'  robust estimate of sigma
%       'mad_s'     MAD estimate of sigma; used for scaling
%                   residuals during the iterative fitting
%       's'         final estimate of sigma, the larger of robust_s
%                   and a weighted average of ols_s and robust_s
%       'se'        standard error of coefficient estimates
%       't'         ratio of b to stats.se
%       'p'         p-values for stats.t
%       'covb'      estimated covariance matrix for coefficient estimates
%       'coeffcorr' estimated correlation of coefficient estimates
%       'w'         vector of weights for robust fit
%       'h'         vector of leverage values for least squares fit
%       'dfe'       degrees of freedom for error
%       'R'         R factor in QR decomposition of X matrix
%
%   The ROBUSTFIT function estimates the variance-covariance matrix of the
%   coefficient estimates as V=inv(X'*X)*STATS.S^2.  The standard errors
%   and correlations are derived from V.
%
%   ROBUSTFIT treats NaNs in X or Y as missing values, and removes them.
%
%   Example:
%      x = (1:10)';
%      y = 10 - 2*x + randn(10,1); y(10) = 0;
%      bls = regress(y,[ones(10,1) x])
%      brob = robustfit(x,y)
%      scatter(x,y)
%      hold on
%      plot(x,brob(1)+brob(2)*x,'r-', x,bls(1)+bls(2)*x,'m:')
%
%   See also REGRESS, ROBUSTDEMO.

% References:
%   DuMouchel, W.H., and F.L. O'Brien (1989), "Integrating a robust
%     option into a multiple regression computing environment,"
%     Computer Science and Statistics:  Proceedings of the 21st
%     Symposium on the Interface, American Statistical Association.
%   Holland, P.W., and R.E. Welsch (1977), "Robust regression using
%     iteratively reweighted least-squares," Communications in
%     Statistics - Theory and Methods, v. A6, pp. 813-827.
%   Huber, P.J. (1981), Robust Statistics, New York: Wiley.
%   Street, J.O., R.J. Carroll, and D. Ruppert (1988), "A note on
%     computing robust regression estimates via iteratively
%     reweighted least squares," The American Statistician, v. 42,
%     pp. 152-154.

%   Copyright 1993-2006 The MathWorks, Inc.
%   $Revision: 1.4.2.5 $  $Date: 2006/11/11 22:55:45 $

if  nargin < 2
    error('stats:robustfit:TooFewInputs',...
        'ROBUSTFIT requires at least two input arguments.');
end

if (nargin<3 || isempty(wfun)), wfun = 'bisquare'; end
if nargin<4, tune = []; end
[eid,emsg,wfun,tune] = ts_robustwfun(wfun,tune);
if ~isempty(eid)
    error(sprintf('stats:robustfit:%s',eid), emsg);
end
if (nargin<5), const='on'; end
switch(const)
    case {'on' 1},  doconst = 1;
    case {'off' 0}, doconst = 0;
    otherwise,  error('stats:robustfit:BadConst',...
            'CONST must be ''on'' or ''off''.');
end

% Remove missing values and check dimensions
[anybad wasnan y X Xr] = ts_removenan(y,X,Xr);
% [anybadr wasnanr yr Xr] = statremovenan(y,Xr);
if (anybad==2)
    error('stats:robustfit:InputSizeMismatch',...
        'Lengths of X and Y must match.');
end

varargout=cell(1,max(1,nargout));
[varargout{:}] = ts_statrobustfit(X,Xr,y,wfun,tune,wasnan,doconst);
end
function [b,stats] = ts_statrobustfit(X,Xr,y,wfun,tune,wasnan,addconst)
%STATROBUSTFIT Calculation function for ROBUSTFIT

% Copyright 1993-2006 The MathWorks, Inc.
% $Revision: 1.4.2.11 $  $Date: 2006/11/11 22:57:39 $

% Must check for valid function in this scope
y0 = y;
c = class(wfun);
fnclass = class(@wfit);
if (~isequal(c,fnclass) && ~isequal(c,'inline') ...
        && (~isequal(c,'char') || isempty(which(wfun))))
    error('stats:robustfit:BadWeight','Weight function is not valid.');
end

[n,p] = size(X);
if (addconst)
    X = [ones(n,1) X];
    p = p+1;
end
if (n<=p)
    b = ones(p,1)*(nan+i*nan);
    stats.se = b;
    warning('stats:robustfit:NotEnoughData',...
        'Not enough points to perform robust estimation.');
        return
end

% Find the least squares solution.
[Q,R,perm] = qr(X,0);
tol = abs(R(1)) * max(n,p) * eps(class(R));
xrank = sum(abs(diag(R)) > tol);

if xrank==p % MB this should always be true for our cases
    if isempty(Xr)
        b(perm,:) = R \ (Q'*y);
    else
        b=(Xr'*X)\(Xr'*y); % MB remote reference solution
    end
else
    % Use only the non-degenerate parts of R and Q, but don't reduce
    % R because it is returned in stats and is expected to be of
    % full size.
    warning('stats:robustfit:RankDeficient',...
        'X is rank deficient, rank = %d',xrank);
    if isempty(Xr)
        b(perm,:) = [R(1:xrank,1:xrank) \ (Q(:,1:xrank)'*y); zeros(p-xrank,1)];
        perm = perm(1:xrank);
    else
        b=(Xr'*X)\(Xr'*y); % MB remote reference solution
    end
end

b0 = zeros(size(b));
blsq = b;
% Adjust residuals using leverage, as advised by DuMouchel & O'Brien
E = X(:,perm)/R(1:xrank,1:xrank);
h = min(.9999, sum(E.*conj(E),2));
adjfactor = 1 ./ sqrt(1-h);
%adjfactor = adjfactor*0+1;
dfe = n-xrank;
ols_s = norm(y-X*b) / sqrt(dfe); %% MB initial scale estimate

% If we get a perfect or near perfect fit, the whole idea of finding
% outliers by comparing them to the residual standard deviation becomes
% difficult.  We'll deal with that by never allowing our estimate of the
% standard deviation of the error term to get below a value that is a small
% fraction of the standard deviation of the raw response values.
tiny_s = 1e-6 * std(y);
if tiny_s==0
    tiny_s = 1;
end

% Perform iteratively reweighted least squares to get coefficient estimates
% D = sqrt(eps(class(X)));
D = 0.001;
iter = 0;
iterlim = 50;
wxrank = xrank;    % rank of weighted version of x
while((iter==0) || any(abs(b-b0) > D*max(abs(b),abs(b0))))
    iter = iter+1;
    if (iter>iterlim)
%         warning('stats:statrobustfit:IterationL   imit','Iteration limit reached.');
        break;
    end
    % Compute residuals from previous fit, then compute scale estimate
    r = y - X*b;
    radj = r .* adjfactor;
    s = madsigma(radj,wxrank);
%     s = sqrt(radj'*radj/(numel(radj)-4)/0.7784);
    % Compute new weights from these residuals, then re-fit
    w = feval(wfun, radj/(max(s,tiny_s)*tune));
    y = X*b + w.*radj;
    b0 = b;
    [b,wxrank] = wfit(y,X,Xr,1/max(s,tiny_s));
end
disp(['Phase 1: ' num2str(iter) ' iterations']);

%% second phase
iter = 0;
iterlim = 3;
a0 = 2.8;
while((iter==0) || any(abs(b-b0) > D*max(abs(b),abs(b0))))
    iter = iter+1;
    disp('second phase');
    if (iter>iterlim)
%         disp('severe weighting: Iteration limit reached.');
        break;
    end
    if iter < 2
        %         zeta= quantile(abs(radj)/s,0.7); % through away 10% of the worst data
        w(abs(radj)/s>tune-0.03) = 0;
%         w(abs(radj)/s>zeta) = 0;
        ind0 = find(w==0);
        y(ind0)  = nan; 
        X(ind0,:)= nan;
        if ~isempty(Xr)
            [y,X,Xr,h,adjfactor,radj y0]   = ts_insertnan(wasnan,y,X,Xr,h,adjfactor,radj,y0);
        [anybad wasnan y X Xr h adjfactor radj y0] = ts_removenan(y,X,Xr,h,adjfactor,radj,y0);
        else
        [y,X,h,adjfactor,radj y0]   = ts_insertnan(wasnan,y,X,h,adjfactor,radj,y0);
        [anybad wasnan y X h adjfactor radj y0] = ts_removenan(y,X,h,adjfactor,radj,y0);
        end
    end
    % Compute residuals from previous fit, then compute scale estimate
    r = y - X*b;
    radj = r .* adjfactor;
    % new scale estimate
    if iter == 1
        s = madsigma(radj,wxrank);
%         s = sqrt(radj'*radj/(numel(radj)-4)/0.7784);
    end
    % Compute new weights from these residuals, then re-fit
    w = feval(wfun, radj/(max(s,tiny_s)*(tune-0.1)));
    %             w = exp(-exp(a0*(abs(radj)/s-a0)));
    y = X*b + w.*radj;
    b0 = b;
    [b,wxrank] = wfit(y,X,Xr,1/max(s,tiny_s));
end
if (nargout>1)
    r = y - X*b;
    radj = r .* adjfactor;
    mad_s = madsigma(radj,xrank);

    % Compute a robust estimate of s
    if all(w<D | w>1-D)
        % All weights 0 or 1, this amounts to ols using a subset of the data
        included = (w>1-D);
        robust_s = norm(r(included)) / sqrt(sum(included) - xrank);
    else
        % Compute robust mse according to DuMouchel & O'Brien (1989)
        robust_s = statrobustsigma(wfun, radj, xrank, max(mad_s,tiny_s), tune, h);
    end

    % Shrink robust value toward ols value if the robust version is
    % smaller, but never decrease it if it's larger than the ols value
    sigma = max(robust_s, ...
        sqrt((ols_s^2 * xrank^2 + robust_s^2 * n) / (xrank^2 + n)));

    % Get coefficient standard errors and related quantities
    RI = R(1:xrank,1:xrank)\eye(xrank);
    tempC = (RI * RI') * sigma^2;
    tempse = sqrt(max(eps(class(tempC)),diag(tempC)));
    C = repmat(NaN,p,p);
    se = repmat(0,p,1);
    covb(perm,perm) = tempC;
    C(perm,perm) = tempC ./ (tempse * tempse');
    se(perm) = tempse;

    % Make outputs conform with inputs
    [r,w,h,adjfactor,ynew,y0] = statinsertnan(wasnan,r,w,h,adjfactor,y,y0);
        
    % Save everything
    stats.ols_s = ols_s;
    stats.robust_s = robust_s;
    stats.mad_s = mad_s;
    stats.s = sigma;
    stats.resid = r; % final residuals
    stats.rstud = r .* adjfactor / sigma;
    stats.se = se;
    stats.blsq = blsq;
    stats.covb = covb;
    stats.coeffcorr = C;
    stats.t = repmat(NaN,size(b));
    stats.t(se>0) = b(se>0) ./ se(se>0);
    stats.p = 2 * tcdf(-abs(stats.t), dfe);
    stats.w = w;
    %stats.R(perm,perm) = R;
    z = zeros(p);
    z(perm,perm) = R(1:xrank,1:xrank);
    stats.R = z;
    stats.dfe = dfe;
    stats.h = h;
    stats.yw = ynew; % final weighted input including removed outliers as NaN 
    stats.ynan = y0; % input with outliers as NaN
end
end
function [b,r] = wfit(y,x,xr,w)
%WFIT    weighted least squares fit

% Create weighted x and y
n = size(x,2);
sw = sqrt(w);
yw = y .* sw;
if size(w)==size(y)
    xw = x .* sw(:,ones(1,n));
elseif numel(w) == 1
    xw = x .* sw;
end
% Computed weighted least squares results
if ~isempty(xr)
    if size(w)==size(y)
        xrw = xr .* sw(:,ones(1,n));
    elseif numel(w) == 1
        xrw = xr .* sw;
    end
    b=[xrw'*xw]\(xrw'*yw);
    r = rank(xw);
else
    [b,r] = linsolve(xw,yw,struct('RECT',true));
end
end
function s = madsigma(r,p)
%MADSIGMA    Compute sigma estimate using MAD of residuals from 0
rs = sort(abs(r));
s = median(rs(max(1,p):end)) / 0.6745;
% s = median(rs(max(1,p):end)) / 0.44845;
%%
end

function [varargout]=ts_insertnan(wasnan,varargin)
%STATINSERTNAN Insert NaN, space, '' or undefined value into inputs.
%   X1 = STATINSERTNAN(WASNAN, Y1) inserts missing values in Y1 and returns
%   it as X1. WASNAN is a logical column vector and the output of
%   STATREMOVENAN. Its TRUE values indicate the rows in X1 that will
%   contain missing values. Y1 is a column vector or a matrix. The type of
%   Y1 can be:
%   Categorical       - X1 is categorical, undefined values represents
%                       missing values.
%   Double            - X1 is double. NaN values represents missing values.
%   Single            - X1 is single. NaN values represents missing values.
%   Character matrix  - X1 is a character matrix. Space represents missing
%                       values.
%   Cell              - X1 is a cell array. empty string '' represents
%                       missing values.
%
%  [X1,X2,...] = STATINSERTNAN(WASNAN,Y1,Y2,...) accepts any number of
%  input variables Y1,Y2,Y3,.... STATINSERTNAN inserts missing values in
%  Y1, Y2,...  and returns them as X1, X2,... respectively.
%
%  This utility is used by some Statistics Toolbox functions to handle
%  missing values.
%
%  See also STATREMOVENAN.


%   Copyright 1993-2008 The MathWorks, Inc.
%   $Revision: 1.4.2.3 $  $Date: 2008/10/31 07:41:07 $

if ~any(wasnan)
    varargout = varargin;
    return;
end

ok = ~wasnan;
len = length(wasnan);
for j=1:nargin-1
    y = varargin{j};
    if (size(y,1)==1) && sum(ok) > 1
        y =  y';
    end

    [n,p] = size(y);

    if ischar(y)
        x = repmat(' ', [len,p]);
    elseif isa(y, 'nominal')
        x = nominal(NaN([len,p]));
        x = addlevels(x,getlabels(y));
    elseif isa(y, 'ordinal')
        x = ordinal(NaN([len,p]));
        x = addlevels(x,getlabels(y));
    elseif iscell(y)
        x = repmat({''},[len,p]);
    elseif isfloat(y)
        x = nan([len,p],class(y));
    elseif islogical(y)
        error('stats:statinsertnan:InputTypeIncorrect',...
            ['Logical input is not allowed because it can''t '...
            'present missing values. Use CATEGORICAL variable instead.']);
    else
        error('stats:statinsertnan:InputTypeIncorrect',...
            ['Y must be categorical, double, single '...
            ' cell array; or a 2D character array.']);
    end

    x(ok,:) = y;

    varargout{j} = x;
end
end
function [badin,wasnan,varargout]=ts_removenan(varargin)
%STATREMOVENAN Remove NaN values from inputs

%   Copyright 1993-2005 The MathWorks, Inc.
%   $Revision: 1.3.2.2 $  $Date: 2005/05/31 16:45:15 $

badin = 0;
wasnan = 0;
n = -1;

% Find NaN, check length, and store outputs temporarily
varargout = cell(nargout,1);
for j=1:nargin
    y = varargin{j};
    if (size(y,1)==1) && (n~=1)
        y =  y.'; % changed y' to y.' MB 2012
    end

    ny = size(y,1);
    if (n==-1)
        n = ny;
    elseif (n~=ny && ny~=0)
        if (badin==0), badin = j; end
    end

    varargout{j} = y;

    if (badin==0 && ny>0)
        wasnan = wasnan | any(isnan(y),2);
    end
end

if (badin>0), return; end

% Fix outputs
if (any(wasnan))
    t = ~wasnan;
    for j=1:nargin
        y = varargout{j};
        if (length(y)>0), varargout{j} = y(t,:); end
    end
end
end
function [eid,emsg,wfun,tune] = ts_robustwfun(wfun,tune)
%STATROBUSTWFUN Get robust weighting function and tuning constant

% Copyright 2005-2007 The MathWorks, Inc.
% $Revision: 1.1.6.4 $    $Date: 2007/08/03 21:43:23 $

eid = '';
emsg = '';

% Convert name of weight function to a handle to a local function, and get
% the default value of the tuning parameter
t = [];
if ischar(wfun)
    switch(wfun)
        case 'andrews'
            wfun = @andrews;
            t = 1.339;
        case 'bisquare'
            wfun = @bisquare;
            t = 4.685;
        case 'cauchy'
            wfun = @cauchy;
            t= 2.385;
        case 'fair'
            wfun = @fair;
            t = 1.400;
        case 'huber'
            wfun = @huber;
            t = 1.345;
        case 'logistic'
            wfun = @logistic;
            t = 1.205;
        case 'ols'
            wfun = @ols;
            t = 1;
        case 'talwar'
            wfun = @talwar;
            t = 2.795;
        case 'welsch'
            wfun = @welsch;
            t = 2.985;
    end
end

% Use the default tuning parameter or check the supplied one
if isempty(tune)
    if isempty(t)
        eid = 'TooFewInputs';
        emsg = 'Missing tuning constant for weight function.';
        return
    end
    tune = t;
elseif (tune<=0)
    eid = 'BadTuningConstant';
    emsg = 'Tuning constant must be positive.';
end
end
function w = andrews(r)
r = max(sqrt(eps(class(r))), abs(r));
w = (abs(r)<pi) .* sin(r) ./ r;
end
function w = bisquare(r)
w = (abs(r)<1) .* (1 - r.^2).^2;
end
function w = cauchy(r)
w = 1 ./ (1 + r.^2);
end
function w = fair(r)
w = 1 ./ (1 + abs(r));
end
function w = huber(r)
w = 1 ./ max(1, abs(r));
end
function w = logistic(r)
r = max(sqrt(eps(class(r))), abs(r));
w = tanh(r) ./ r;
end
function w = ols(r)
w = ones(size(r));
end
function w = talwar(r)
w = 1 * (abs(r)<1);
end
function w = welsch(r)
w = exp(-(r.^2));
end