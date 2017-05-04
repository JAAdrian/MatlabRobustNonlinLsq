function [y] = robustNonlinLsq(modelFun, x, y, lb, ub, opt)
%ROBUSTNONLINLSQ <purpose in one line!>
% -------------------------------------------------------------------------
% <Detailed description of the function>
%
% Usage: [y] = robustNonlinLsq(input)
%
%   Input:   ---------
%
%  Output:   ---------
%
%
% Author:  J.-A. Adrian (JA) <jensalrik.adrian AT gmail.com>
% Date  :  04-May-2017 22:54
%

% History:  v0.1  initial version, 04-May-2017 (JA)
%


if nargin < 6 || isempty(opt)
    opt = optimset('lsqnonlin');
end




% End of file: robustNonlinLsq.m
