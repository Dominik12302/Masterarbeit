function [MathAngle] = NorthRelatedAngleToMathAngle(NorthRelatedAngle)
    
    % North angle to math angle conversion
    %
    % - Syntax -
    %
    % [MathAngle]       = NorthRelatedAngleToMathAngle(NorthRelatedAngle)
    %
    % - Inputs -
    %
    % NorthRelatedAngle - Input of the north angle in radian
    %
    % - Outputs -
    %
    % MathAngle         - Output of the math angle in radian
    %

    if ~isnumeric(NorthRelatedAngle)
        error('Input must be numeric.')
    end
    
    %         = 360° - angle + 90°
    MathAngle = 2 * pi - NorthRelatedAngle + pi / 2; 
        
end


