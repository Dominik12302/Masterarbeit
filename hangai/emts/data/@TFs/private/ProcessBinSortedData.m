function [ProcessedData] = ProcessBinSortedData(Data, BinIndices, BinCount, AnonymousFunction)
    % see: http://stackoverflow.com/questions/4350735/is-there-an-accumarray-that-takes-matrix-as-val
    % Process the previously sorted data (e.g. calculate the mean of each bin)
    %
    % - Syntax -
    %
    % [ProcessedData] = ProcessBinSortedData(Data, BinIndices, BinCount, AnonymousFunction)
    %
    % - Inputs -
    %
    % Data              - Matrix that contains the data to process. Data is processed for each column independently.
    % BinIndices        - Vector that contains the bin indices for each dataset
    % BinCount          - Scalar that contains the maximum number of bins
    % AnonymousFunction	- Optional input. Function that is applied to all data of each bin. For default behavior pass [].
    %
    % - Outputs -
    %
    % ProcessedData     - Vector that contains the processed data
    %
    % - Test -
    %
    % Bins                          = [1:2:10];
    % Data                          = [1 1 2 10 6 5 7 35 55; 2 3 4 1 7 1 2 25 17]';
    % [BinIndices, NumberOfValues]  = Statistics.SortDataIntoBins(Data(:, 1), Bins, false, false);
    % ProcessedData                 = Statistics.ProcessBinSortedData(Data, BinIndices, numel(Bins), @(x) mean(x));
        
    %% Verify input data
       
    if ~isvector(BinIndices)
        error('BinIndices must a vector.')
    end  
    
    if numel(BinIndices) ~= size(Data, 1)
        error('BinIndices and Data must have the same number of rows.')
    end
    
    if ~isscalar(BinCount)
        error('BinCount must a scalar.')
    end  
    
    %% Calculation
    
    if isvector(Data)
        Data            = Data(:);
    end 
    
    BinIndices          = BinIndices(:);

    % Ensures that the resulting vector AveragedData returns a value for
    % each bin in cases where the maximum of BinIndices is lower than BinCount
    BinIndices(end + 1, 1) = BinCount;
    Data(end + 1, :)    = NaN;

    NonZeroElements     = BinIndices > 0;
    BinIndices          = BinIndices(NonZeroElements);
    Data                = Data(NonZeroElements, :);
       
    ColumnCount         = size(Data, 2);
    BinIndices          = [repmat(BinIndices, ColumnCount, 1) kron(1 : ColumnCount, ones(1, numel(BinIndices))).'];
    ProcessedData       = accumarray(BinIndices, Data(:), [], AnonymousFunction, NaN);
    
end
