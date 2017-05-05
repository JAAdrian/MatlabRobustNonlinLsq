function [varargout] = robustnonlinlsqcurvefit(fun, x0, xdata, ydata, lb, ub, options)
%ROBUSTNONLINLSQCURVEFIT <purpose in one line!>
% -------------------------------------------------------------------------
% <Detailed description of the function>
%
% Usage: [y] = robustnonlinlsqcurvefit(input)
%
%   Input:   ---------
%
%  Output:   ---------
%
%
% Author:  J.-A. Adrian (JA) <jensalrik.adrian AT gmail.com>
% Date  :  05-May-2017 11:27
%

% History:  v0.1  initial version, 05-May-2017 (JA)
%


if nargin < 7 || isempty(options)
    options = optimset('lsqnonlin');
end
if nargin < 6
    ub = [];
end
if nargin < 5
    lb = [];
end
if nargin < 4
    help(mfilename)
end


varargout = cell(nargout, 1);

hasConverged     = false;
previousEstimate = inf(size(x0));
weights          = ones(size(xdata));
while ~hasConverged
    %%% weighted LSQ
    weightedFun = ...
        @(params) (fun(params, xdata) - ydata) .* weights;
    
    [varargout{:}] = ...
        lsqnonlin(weightedFun, x0, lb, ub, options);
    
    thisEstimate = varargout{1};
    hasConverged = norm(thisEstimate - previousEstimate) > options.TolFun;
    
    %%% update weights
    residuals = ydata - weightedFun(thisEstimate);
    residuals = residuals(:);
    
    %TODO: correct leverages
    theseLeverages = leverage(residuals);
    tuningConstant = 4.685;
    robustVar      = mad(residuals, 1);
    
    r = residuals ./ (tuningConstant * robustVar * sqrt(1 - theseLeverages));
    
    weights = (abs(r) < 1) .* (1 - r.^2).^2;
end



% End of file: robustnonlinlsqcurvefit.m
