classdef IterControl < hgsetget;

   properties
      %   properties used by a wide range of iterative schemes
      %   below are defaults, used if no arguments are provided to constructor
      niter = 0;
      iterMax = 10;
      tolerance = .005;
      epsilon = 1000;
      %   additional properties used for regression-M estimator 
      %         (r0 is also used for Robust Covariance PC estimated, but value is
      %         typically increased to 3)
      r0 = 1.5;
      rdscnd = 0;
      u0 = 2.8;
      %   and some properties used sometimes to control one or another of
      %    the iterative algorithms
      returnCovariance = true;
      saveCleaned = false;
      robustDiagonalize = false;
   end

   methods 
   % class constructor
   function obj = IterControl(varargin)
      %  constructor for class IterControl
      if nargin > 0
         n = length(varargin);
         if mod(n,2)
            error(1,'%s\n','Optional arguments to IterControl must occur in pairs')
         end
         for k = 1:2:n
            option = lower(varargin{k});
            switch option
               case 'itermax'
                  obj.iterMax = varargin{k+1};
               case 'tolerance'
                  obj.tolerance = varargin{k+1};
               otherwise
                  error(1,'%s\n','Optional argument to IterControl not defined')
            end
         end
         obj.niter = 0;
         obj.epsilon = 1000;
      end
      %   else just use defaults
   end

   function [notConverged] = cvgcTest(ITER,b,b0)

      maxChng = max(abs(1-b./b0));
      notConverged = ( maxChng > ITER.tolerance ) & ...
                 (ITER.niter < ITER.iterMax);
   end

   end   % methods

end   % class

