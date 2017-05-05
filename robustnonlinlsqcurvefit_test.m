function [tests] = robustnonlinlsqcurvefit_test()
%ROBUSTNONLINLSQCURVEFIT_TEST <purpose in one line!>
%
% Usage: [tests] = robustnonlinlsqcurvefit_test()
%
%
% Author:  J.-A. Adrian (JA) <jensalrik.adrian AT gmail.com>
% Date  :  05-May-2017 11:27
%

% History:  v0.1  initial version, 05-May-2017 (JA)
%


tests = functiontests(localfunctions());
end


function setupOnce(testCase)
param = [0.5, 1.25];

x = linspace(0, 6, 100);
modelFun = @(param, x) param(1)*exp(param(2) * x);

noise = 10*sin(x).^2 .* randn(size(x));

y = modelFun(param, x) + noise;

testCase.TestData.trueParams = param;
testCase.TestData.x = x;
testCase.TestData.y = y;
testCase.TestData.noise = noise;
testCase.TestData.modelFun = modelFun;
end



function testSimpleCall(testCase)
x = testCase.TestData.x;
y = testCase.TestData.y;
fun = testCase.TestData.modelFun;

x0 = [1, 1];

estParams = robustnonlinlsqcurvefit(fun, x0, x, y);
end

function testFullCall(testCase)
x = testCase.TestData.x;
y = testCase.TestData.y;
fun = testCase.TestData.modelFun;

x0 = [1, 1];

lb = [0.1, 1];
ub = [  1, 2];

options = optimset('lsqnonlin');
options.Display = 'off';

[x,resnorm,residual,exitflag,output,lambda,jacobian] = ...
    robustnonlinlsqcurvefit(fun, x0, x, y, lb, ub, options);
end




% End of file: robustnonlinlsqcurvefit_test.m
