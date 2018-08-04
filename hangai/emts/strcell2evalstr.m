function str = strcell2evalstr(c)

c2 = cellfun(@(x)[' ''',x,''' '],c,'UniformOutput',false);
str = ['{',[c2{:}],'}'];