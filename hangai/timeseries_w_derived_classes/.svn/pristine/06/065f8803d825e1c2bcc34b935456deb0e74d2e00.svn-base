function f = code_double_as_neg_int_inverse(d,intbytes)

    % f = code_double_as_neg_int_inverse(d)
    % f = code_double_as_neg_int_inverse(d,intbytes)
    %
    % inverse function of code_double_as_neg_int
    %
    % JK
    
    if nargin < 2; intbytes = 32; end
    
    % make sure that intbytes is only 8 16 32 or 64
    if ~ismember(intbytes,[8,16,32,64])
        error('Only integers of 8, 16, 32 or 64 bytes are permissible');
    end
    n_digits = floor(log10(2^(intbytes-1)-1));
    
    if d >= 0 % a postive integer is simply converted
        f = double(d);     
    else % a negative integer requires decoding
        dstr = num2str(-d,'%d');
        fstr = repmat('0',[1 n_digits+1]);
        fstr(end-numel(dstr)+1:end) = dstr;
        
        if strcmp(fstr(1),'0')
            f = str2double(['0.', fstr(2:end)]);
        else
            nX = str2double(fstr(2));
            Xstr = fstr(3:3+nX-1);
            Ystr = fstr(3+nX:end);
            if isempty(Ystr); Ystr = '0'; end
            f = str2double([Xstr,'.',Ystr]);
        end
    end
