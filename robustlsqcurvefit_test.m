function [tests] = robustlsqcurvefit_test()
%ROBUSTLSQCURVEFIT_TEST <purpose in one line!>
%
% Usage: [tests] = robustlsqcurvefit_test()
%
%
% Author:  J.-A. Adrian (JA) <jensalrik.adrian AT gmail.com>
% Date  :  05-May-2017 11:27
%

% History:  v0.1.0  initial version, 05-May-2017 (JA)
%           v0.2.0  implement new unit test functions, 07-May-2017 (JA)
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

options = optimset(@lsqcurvefit);
options.Display = 'off';

testCase.TestData.trueParams = param;
testCase.TestData.x = x;
testCase.TestData.y = y;
testCase.TestData.noise = noise;
testCase.TestData.modelFun = modelFun;
testCase.TestData.x0 = [1, 1];
testCase.TestData.options = options;
end



function testSimpleCall(testCase)
x = testCase.TestData.x;
y = testCase.TestData.y;
fun = testCase.TestData.modelFun;

x0 = testCase.TestData.x0;

options = testCase.TestData.options;

robustlsqcurvefit(fun, x0, x, y, [], [], [], options);
end

function testFullCall(testCase)
x = testCase.TestData.x;
y = testCase.TestData.y;
fun = testCase.TestData.modelFun;

x0 = testCase.TestData.x0;

options = testCase.TestData.options;

lb = [0.1, 1];
ub = [  1, 2];

weightMethod = 'bisquare';

outputs = cell(7, 1); %#ok<PREALL>
[outputs] = robustlsqcurvefit(fun, x0, x, y, lb, ub, weightMethod, options); %#ok<*NASGU>
end

function testInputValidation(testCase)
x = testCase.TestData.x;
y = testCase.TestData.y;
fun = testCase.TestData.modelFun;

x0 = testCase.TestData.x0;

options = testCase.TestData.options;

%% Wrong WeightMethod Input
actual = @() robustlsqcurvefit(fun, x0, x, y, [], [], 'foo', options);

testCase.verifyError(actual, 'MATLAB:unrecognizedStringChoice');

%% Wrong lb Input
actual = @() robustlsqcurvefit(fun, x0, x, y, 'foo', [], [], options);

testCase.verifyError(actual, 'MATLAB:robustlsqcurvefit:invalidType');

%% Correct Input
actual = @() robustlsqcurvefit(fun, x0, x, y, [], [], 'ols', options);

testCase.verifyWarningFree(actual);
end

function testPrecision(testCase)
x = testCase.TestData.x;
y = testCase.TestData.y;
fun = testCase.TestData.modelFun;

x0 = testCase.TestData.x0;

options = testCase.TestData.options;

est = robustlsqcurvefit(fun, x0, x, y, [], [], [], options); %#ok<*NASGU>

testCase.verifyLessThan(norm(est - testCase.TestData.trueParams).^2, 1e-4);
end






% End of file: robustlsqcurvefit_test.m
