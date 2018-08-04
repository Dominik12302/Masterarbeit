function ints=isint(var)
% ints=isint(var)
%
% functions returns an array with same dimensions  and form as input object, yielding
% ones where was an integer number ( modulo 1 equals 0 ) and zeros for
% numbers with decimals. (JK)   
%
% NOTE: is equivalent to ~logical(mod(var,1)), but also works on complex
% numbers, checks real and imaginary part separately. is not true for strings.

if imag(var)~=0; ints=abs(isint(real(var)).*isint(imag(var))); return; end

if isnumeric(var)==0; ints=zeros(size(var)); return; end
dim=check_dim(var); % get order
var=mod(var,1); % set integer elements to zero
% create strings to combine recursivly into multiple for-loops, which will evaluate all
% elements in all dimensions
str1=''; % loop start
str2='('; % element
str3=''; % loop end
if dim~=0; % if input is non scalar
    for ind=1:dim % for every dimension
        % open one loop
        if dim==1 % one dimensional array can be column or row                       
            str1=[str1,' for ind',num2str(ind),'=1:',num2str(length(var)),';'];
        else
            str1=[str1,' for ind',num2str(ind),'=1:',num2str(size(var,ind)),';'];
        end
        str2=[str2,'ind',num2str(ind)]; % add index
        if ind==dim; str2=[str2,')']; else str2=[str2,',']; end % add comma or close with ')'
        str3=[str3,'end;']; % close one loop
    end
    % evaluate command by connecting strings
    eval([str1,'if var',str2,'==0; ints',str2,'=1; else; ints',str2,'=0; end;',str3]);
    if dim==1 % restore original form of 1-dim array
        if size(var,2)==1
            ints=ints';
        end
    end
else % if input is scalar, make it easy
    if var==0; ints=1; else ints=0; end
end
ints=logical(ints);


