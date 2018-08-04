function [ColorIndices] = ScaleIndicesToMaximumRange(RequestedColorCount, MaxColorCount)

    if RequestedColorCount == 1
        ColorIndices = 1;
        return
    end

    %y = m * x + b;
    m = (MaxColorCount - 1) / (RequestedColorCount - 1);
    x = 1 : RequestedColorCount;
    b = MaxColorCount - m * RequestedColorCount;
    
    ColorIndices = round(m * x + b);

end

