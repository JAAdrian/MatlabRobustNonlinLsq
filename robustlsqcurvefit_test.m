function [tests] = robustlsqcurvefit_test()
%ROBUSTLSQCURVEFIT_TEST <purpose in one line!>
%
% Usage: [tests] = robustlsqcurvefit_test()
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

noise = sin(x).^2 .* randn(size(x));

y = modelFun(param, x) + noise;
y(10) = 200;
y(50) = 400;

testCase.TestData.trueParams = param;
testCase.TestData.x = x;
testCase.TestData.y = y;
testCase.TestData.noise = noise;
testCase.TestData.modelFun = modelFun;
testCase.TestData.x0 = [1, 1];
end



function testSimpleCall(testCase)
x = testCase.TestData.x;
y = testCase.TestData.y;
fun = testCase.TestData.modelFun;

x0 = testCase.TestData.x0

robustlsqcurvefit(fun, x0, x, y);
end

function testFullCall(testCase)
x = testCase.TestData.x;
y = testCase.TestData.y;
fun = testCase.TestData.modelFun;

x0 = testCase.TestData.x0;

lb = [0.1, 1];
ub = [  1, 2];

weightMethod = 'bisquare';

options = optimset('lsqnonlin');
options.Display = 'off';

outputs = cell(7, 1);
[outputs] = robustlsqcurvefit(fun, x0, x, y, lb, ub, weightMethod, options);
end

function testInputValidation(testCase)
x = testCase.TestData.x;
y = testCase.TestData.y;
fun = testCase.TestData.modelFun;

x0 = testCase.TestData.x0;

actual = @() robustlsqcurvefit(fun, x0, x, y, [], [], 'foo');

testCase.verifyError(actual, 'MATLAB:unrecognizedStringChoice');
end




% End of file: robustlsqcurvefit_test.m
