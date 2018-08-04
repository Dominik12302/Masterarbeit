function [BinIndices, NumberOfValues] = SortDataIntoBins(Data, Bins, IsBinEdges, WithInfiniteEdges)

    % Sort data into bins
    %
    % - Syntax -
    %
    % [BinIndices, NumberOfValues] = SortDataIntoBins(Data, Bins, IsBinEdges, WithInfitineEdges)
    %
    % - Inputs -
    %
    % Data              - Vector that contains the data to sort
    % BinCenters        - Vector that contains the bin centers
    % WithInfitineEdges	- Boolean that specifies if the outer bins have infinite edges
    %
    % - Outputs -
    %
    % BinIndices        - Vector that contains the found bin index for each dataset
    % NumberOfValues    - Vector that contains the number of values of each bin
    %
    % - Test -
    %
    % [BinIndices, NumberOfValues] = Statistics.SortDataIntoBins([1 10 5 7 35 55]', [1:2:10], false, true);
    % [BinIndices, NumberOfValues] = Statistics.SortDataIntoBins([1 10 5 7 35 55]', [1:2:10], false, false);

    %% Verify input data    
    
    if ~isvector(Data)
        error('Data must a vector.')
    end
    
    if ~isvector(Bins)
        error('Bins must a vector.')
    end
        
    %% Calculation
    
    Bins            = Bins(:)';
    if IsBinEdges
        BinEdges    = Bins;
        BinCount    = numel(Bins) - 1;
    else
        BinCount    = numel(Bins);
        BinEdges    = CalculateBinEdges(Bins, WithInfiniteEdges);
    end
    
    [NumberOfValues, BinIndices] = histc(Data, BinEdges);
    
    NumberOfValues  = NumberOfValues(1 : end - 1);
    BinIndices(BinIndices > BinCount) = 0;
    
end

