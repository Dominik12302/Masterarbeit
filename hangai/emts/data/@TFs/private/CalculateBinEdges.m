function [BinEdges] = CalculateBinEdges(BinCenters, WithInfiniteEdges)
    
    % Calculate bin edges from bin centers
    %
    % - Syntax -
    %
    % [BinEdges] = CalculateBinEdges(BinCenters, WithInfiniteEdges)
    %
    % - Inputs -
    %
    % BinCenters        - Vector that contains the bin centers
    % WithInfitineEdges	- Boolean that specifies if the outer bins have infinite edges
    %
    % - Outputs -
    %
    % BinEdges          - Vector that contains the calculated bin edges
    %
    % - Test -
    %
    % [BinEdges] = Statistics.CalculateBinEdges([1:2:10], false);
    % [BinEdges] = Statistics.CalculateBinEdges([1:2:10], true);

    
    %% Verify input data
    
    if ~isvector(BinCenters)
        error('BinCenters must a vector.')
    end
    
    %% Calculation
    
    BinCenters 	= BinCenters(:)';
    BinGradient = diff(BinCenters);

    if numel(BinCenters) == 1
        BinEdges = [-inf inf];
    elseif WithInfiniteEdges
        BinEdges = [-inf, BinCenters(1 : end - 1) + BinGradient / 2, inf];
    else
        BinEdges = [BinCenters(1) - BinGradient(1) / 2, BinCenters(1 : end - 1) + BinGradient / 2, BinCenters(end) + BinGradient(end) / 2];
    end
    
end

