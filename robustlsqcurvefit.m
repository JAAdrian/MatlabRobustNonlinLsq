function [varargout] = robustlsqcurvefit(fun, x0, xdata, ydata, lb, ub, weightMethod, options)
%ROBUSTLSQCURVEFIT <purpose in one line!>
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


if nargin < 8 || isempty(options)
    options = optimset('lsqnonlin');
end
if nargin < 7 || isempty(weightMethod)
    weightMethod = 'bisquare';
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

weightMethod = validatestring(...
    weightMethod, ...
    {'bisquare', 'andrews', 'cauchy', 'fair', 'huber', 'logistic', 'ols', 'talwar', 'welsch'} ...
    );

convergenceThreshold = 1e-6;

varargout = cell(max(nargout, 1), 1);

xdata = xdata(:);
ydata = ydata(:);

[weightFunction, tuningConstant] = weightFunAndConstant(weightMethod);

hasConverged     = false;
previousEstimate = inf(size(x0));
weights          = ones(size(xdata));
iterationCounter = 1;
while ~hasConverged && iterationCounter < options.MaxIter
    %%% weighted LSQ
    weightedFun = ...
        @(params) (fun(params, xdata) - ydata) .* weights;
    
    [varargout{:}] = ...
        lsqnonlin(weightedFun, x0, lb, ub, options);
    
    thisEstimate = varargout{1};
    hasConverged = norm(thisEstimate - previousEstimate)^2 < convergenceThreshold;
    
    %%% update weights
    residuals = ydata - fun(thisEstimate, xdata);
    residuals = residuals(:);
    
    residualLeverages = leverage(residuals);
    robustVar         = mad(residuals, 1);
    
    r = residuals ./ (tuningConstant * robustVar * sqrt(1 - residualLeverages));
    
    weights = weightFunction(r);
    previousEstimate = thisEstimate;
    iterationCounter = iterationCounter + 1;
end
end

function [weightFun, tuningConstant] = weightFunAndConstant(method)
switch lower(method)
    case 'bisquare'
        weightFun      = @(r) (abs(r) < 1) .* (1 - r.^2).^2;
        tuningConstant = 4.685;
        
    case 'andrews'
        weightFun      = @(r) (abs(r) < pi) .* sin(r) ./ r;
        tuningConstant = 1.339;
        
    case 'cauchy'
        weightFun      = @(r) 1 ./ (1 + r.^2);
        tuningConstant = 2.385;
        
    case 'fair'
        weightFun      = @(r) 1 ./ (1 + abs(r));
        tuningConstant = 1.4;
        
    case 'huber'
        weightFun      = @(r) 1 ./ max(1, abs(r));
        tuningConstant = 1.345;
        
    case 'logistic'
        weightFun      = @(r) tanh(r) ./ r;
        tuningConstant = 1.205;
        
    case 'ols'
        weightFun      = @(r) ones(size(r));
        tuningConstant = 1;
        
    case 'talwar'
        weightFun      = @(r) 1 * (abs(r) < 1);
        tuningConstant = 2.795;
        
    case 'welsch'
        weightFun      = @(r) exp(-(r.^2));
        tuningConstant = 2.985;
        
end
end



% End of file: robustlsqcurvefit.m
