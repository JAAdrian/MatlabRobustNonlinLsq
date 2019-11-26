function [varargout] = robustlsqcurvefit(fun, x0, xdata, ydata, lb, ub, weightMethod, options)
%ROBUSTLSQCURVEFIT solves robust non-linear least squares problems.
% -------------------------------------------------------------------------
% This function implements iteratively reweighted least squares (IRLS)
% using a non-linear least squares approach. Thus, it combines the strength
% of robust fitting, like known from MATLAB's robustfit() function, and the
% possibility to fit data to models which are non-linear in their
% parameters, like known from MATLAB's lsqcurvefit() function (which uses
% lsqnonlin() internally but provides a simpler interface for data
% fitting). This combination is, yet, not provided by functions in any of
% MATLAB's toolboxes.
% 
% The function computes weights iteratively to solve weighted non-linear
% least squares. The latter part is done by calling lsqnonlin().
% 
% This function has dependencies to the following toolboxes:
%   - Statistics and Machine Learning Toolbox
%   - Optimization Toolbox
% 
%
% Usage: [varargout] = robustlsqcurvefit(fun, x0, xdata, ydata)
%        [varargout] = robustlsqcurvefit(fun, x0, xdata, ydata, lb, ub)
%        [varargout] = robustlsqcurvefit(fun, x0, xdata, ydata, lb, ub, weightMethod)
%        [varargout] = robustlsqcurvefit(fun, x0, xdata, ydata, lb, ub, weightMethod, options)
%
%   Input:   ---------
%           fun - function handle to the model function, i.e. handle to the
%                 function which is likely to produce the data observed in
%                 y. This follows the definition from lsqcurvefit() [NOT
%                 the one from lsqnon()]. Consult documentation of
%                 lsqcurvefit() for details.
%           x0 - initial guess of the true parameters. Consult
%                documentation of lsqcurvefit() for details.
%           xdata - x values corresponding to the observed data in
%                   'ydata'. Consult documentation of lsqcurvefit() for
%                   details.
%           ydata - observed data to which the function 'fun' will be
%                   fitted by optimizing its parameters. Consult
%                   documentation of lsqcurvefit() for details. 
%           lb - lower bound on the design variables, X, so that the
%                solution is in the range lb <= X <= ub. Consult
%                documentation of lsqcurvefit() for details.
%                [default: lb = []]
%           ub - upper bound on the design variables, X, so that the
%                solution is in the range lb <= X <= ub. Consult
%                documentation of lsqcurvefit() for details.
%                [default: ub = []]
%           weightMethod - string defining the data weight design function.
%                          The designs are adapted to MATLAB's robustfit()
%                          and can be one of the following:
%                               - 'andrews'
%                               - 'bisquare'
%                               - 'cauchy'
%                               - 'fair'
%                               - 'huber'
%                               - 'logistic'
%                               - 'ols'
%                               - 'talwar'
%                               - 'welsch'
%                           for further information consult the
%                           documentation of robustfit().
%                           [default: weightMethod = 'bisquare']
%           options - option struct which can be created by calling
%                     optimset(@lsqcurvefit) which is directly passed to
%                     the function lsqcurvefit(). Use this to steer
%                     optimization behaviour of lsqcurvefit(). Consult
%                     documentation of lsqcurvefit() for details.
%                     [default: options = optimset(@lsqcurvefit)]
%           
%
%  Output:   ---------
%           varargout - the exact outputs of the function lsqcurvefit().
%                           - x
%                           - resnorm
%                           - residual
%                           - exitflag
%                           - output
%                           - lambda
%                           - jacobian
%                       Consult documentation of lsqcurvefit() for details.
%
%
% Author:  J.-A. Adrian (JA) <jensalrik.adrian AT gmail.com>
% Date  :  05-May-2017 11:27
%

% History:  v0.1.0  initial version, 05-May-2017 (JA)
%           v0.2.0  fix bugs, update documentation, 07-May-2017 (JA)
%           v0.2.1  update documentation, 07-May-2017 (JA)
%           v0.2.2  update version info, 07-May-2017 (JA)
%           v0.2.3  fix missing sqrt-ing of the weights, 02-Apr-2019 (JA)
%           v0.2.4  include MathWorks FileExchange banner in README, 26-Nov-2019 (JA)
%


if nargin < 8 || isempty(options)
    options = optimset(@lsqcurvefit);
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

[weightMethod] = ...
    validateInputArguments(fun, x0, xdata, ydata, lb, ub, weightMethod, options);

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
    % define the cost function which will be squared and summed by lsqnonlin(). Due to the latter
    % point, the weights have to be square-rooted here.
    weightedFun = ...
        @(params) (fun(params, xdata) - ydata) .* sqrt(weights);
    
    varargout{:} = lsqnonlin(weightedFun, x0, lb, ub, options);
    
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


function [weightMethod] = validateInputArguments(...
    fun, ...
    x0, ...
    xdata, ...
    ydata, ...
    lb, ...
    ub, ...
    weightMethod, ...
    options ...
    )

validateattributes(...
    fun, ...
    {'function_handle'}, ...
    {'scalar', 'nonempty'}, ...
    mfilename, ...
    'fun', ...
    1 ...
    );
assert(...
    nargin(fun) == 2, ...
    ['No. of input arguments of ''fun'' do not match the desired no. of 2 ', ...
    '(parameters and x-values)'] ...
    );

validateattributes(...
    x0, ...
    {'numeric'}, ...
    {'vector', 'nonempty', 'finite'}, ...
    mfilename, ...
    'x0', ...
    2 ...
    );

validateattributes(...
    xdata, ...
    {'numeric'}, ...
    {'vector', 'nonempty', 'finite'}, ...
    mfilename, ...
    'xdata', ...
    3 ...
    );

validateattributes(...
    ydata, ...
    {'numeric'}, ...
    {'vector', 'nonempty', 'finite'}, ...
    mfilename, ...
    'ydata', ...
    4 ...
    );

validateattributes(...
    lb, ...
    {'numeric'}, ...
    {}, ...
    mfilename, ...
    'lb', ...
    5 ...
    );

validateattributes(...
    ub, ...
    {'numeric'}, ...
    {}, ...
    mfilename, ...
    'ub', ...
    6 ...
    );

validateattributes(...
    weightMethod, ...
    {'char'}, ...
    {'nonempty'}, ...
    mfilename, ...
    'weightMethod', ...
    7 ...
    );

validateattributes(...
    options, ...
    {'numeric', 'struct'}, ...
    {}, ...
    mfilename, ...
    'options', ...
    8 ...
    );

weightMethod = validatestring(...
    weightMethod, ...
    {'bisquare', 'andrews', 'cauchy', 'fair', 'huber', 'logistic', 'ols', 'talwar', 'welsch'} ...
    );
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

