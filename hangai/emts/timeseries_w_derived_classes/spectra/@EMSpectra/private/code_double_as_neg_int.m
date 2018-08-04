function d = code_double_as_neg_int(f,tol,intbytes)
    
    % d = code_double_as_neg_int(f)
    % d = code_double_as_neg_int(f, tol)
    % d = code_double_as_neg_int(f, tol, intbytes)
    %
    % function codes a positive floating point / double number
    % to be stored in integer format in the following way:
    %
    % f has a decimal format of X.Y
    % 1. determine if f is an integer (Y small compared to X, see below):
    % 2. if yes, continue with standard integer conversion
    % 3. if no, test whether X == 0
    % 4. if yes, set first digit of d to 0, and store Y in the remaining
    %    ones (or as many digits of Y as are left):
    %    d is then of the format -0Y
    % 5. if no, set first digit of d to 1, and store the number of digits N
    %    for X in the second digit
    %    then store X in the following and Y in the remainder
    %    d is then of the format -1XY
    %     
    % tol (default 1e-10): tolerange that specifies when a number is considered and
    % integer, based on whether Y / X > 0 or not    
    % 
    % intbytes (default 32): 8 for int8, 16 for int16 etc.
    % function works with int8, int16, int32, int64
    % however, for int8, few bytes are available to make it meaningful
    %   
    % from a few rough tests (test yourself to be sure... also for large
    % nx (say >2), this seems to become wrong)
    % for int32, numbers f < 1 are safe until 1e-9
    %                    f > 1 are safe until nx+1e-(8-nx), 
    %                       nx = floor(log10(f))+1, i.e. digits in front of
    %                       decimal point
    %                       (if the tolerance is chosen)
    % for int16, numbers f < 1 are safe until 1e-4
    %                    f > 1 are safe until nx+1e-(3-nx), 
    % for int64, numbers f < 1 are safe until 1e-18
    %                    f > 1 are safe until nx+1e-(13-nx), 
    % otherwise, digits may be truncated. for other integers, best test.
    %                       
    % JK
    
    
    if nargin < 2; tol = []; end
    if isempty(tol); tol = 1e-10; end
    if nargin < 3; intbytes = 32; end
    
    % make sure that intbytes is only 8 16 32 or 64
    switch intbytes
        case 8
            intfun = @(x)int8(x);
        case 16
            intfun = @(x)int16(x);            
        case 32
            intfun = @(x)int32(x);                        
        case 64
            intfun = @(x)int64(x);                                    
        otherwise
            error('Only integers of 8, 16, 32 or 64 bytes are permissible');
    end
    
    % determine the byterange
    byterange = [-2^(intbytes-1) 2^(intbytes-1)-1];
    
    % determine the max number of digits which are fully available
    n_digits = floor(log10(byterange(2)));
    
    % make sure that f is positive
    if f < 0; error('negative floating points not accepted'); end
        
    X = floor(f);
    Y = f - X;    
    % do we have a floating point number ?
    if Y/X > tol
        % is X equal 0?
        if X == 0;            
            d = - intfun(floor(10^n_digits*Y));
        else
            nX = floor(log10(X))+1;
            nY = n_digits - nX - 1;
            if nX >= 10; error('floating point number too large'); end
            d = - intfun(...
                10^(n_digits) + ... % a 1 in front
                nX*10^(n_digits-1)  + ... % number of digits, X
                X*10^(nY)     + ... % add X
                floor(10^nY*Y));      % add Y                
        end
    else % if not, just go on with an integer
        if f > byterange(2); error('float too large for reliable integer conversion'); end
        d = intfun(f);
    end
    
    
    

    