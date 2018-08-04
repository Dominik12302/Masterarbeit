function str = strcell2_evalstr(c)

c2 = cellfun(@(x)[' ''',x,''' '],c,'UniformOutput',false);
str = ['{',[c2{:}],'}'];