function [dim,whichdims]=check_dim(var)
% [dim,whichdims]=check_dim(var)
%
% dim:
% The function returns the dimensionality of an array, understood as the
% order of a tensor. A scalar will return a 0, a vector a 1 etc.
%
% In other words: singleton dimension will be ignored as they represent
% a rotation of the array, not dimensional increase.
% 
% whichdim returns then which dimensions these are.

whichdims=size(var)~=1;
dim=sum(whichdims);
whichdims=find(whichdims);

if isempty(var); dim=[]; whichdims=[]; end

