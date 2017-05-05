% <purpose of this file>
%
% Author:  J.-A. Adrian (JA) <jensalrik.adrian AT gmail.com>
% Date  :  05-May-2017 22:46:35
%

clear;
close all;

%% Easy Linear Model With Noise and Outliers
x = (1:10)';
rng default; % For reproducibility
y = 10 - 2*x + randn(size(x));
y(10) = 0;

modelFun = @(params, x) params(1)*x + params(2);
x0       = [1, 1];

estParamsReference = polyfit(x, y, 1);
estParams          = robustlsqcurvefit(modelFun, x0, x, y);

figure;
hold on;
scatter(x, y, 'filled');
plot(x, modelFun(estParamsReference, x));
plot(x, modelFun(estParams, x));

legend(...
    {'Noisy Data', 'Ordinary non-lin LSQ', 'Robust non-lin LSQ'}, ...
    'fontsize', 12 ...
    );

%% Exponential Model With Noise and Outliers
trueParams = [0.5, 1.25];

x = linspace(0, 6, 100);
modelFun = @(param, x) param(1)*exp(param(2) * x);

noise = 20*sin(x).^2 .* randn(size(x));

y = modelFun(trueParams, x) + noise;
y(10) = 400;
y(50) = 800;
y(90) = 2000;

x0 = [0.3, 2];

options = optimset('lsqnonlin');
options.Display = 'off';

method = 'huber';

estParamsReference = lsqcurvefit(modelFun, x0, x, y, [], [], options);
estParams          = robustlsqcurvefit(modelFun, x0, x, y, [], [], method, options);

figure(1);
hold on;
plot(x, y);
plot(x, modelFun(estParamsReference, x));
plot(x, modelFun(estParams, x));
hold off;

legend(...
    {'Noisy Data', 'Ordinary non-lin LSQ', 'Robust non-lin LSQ'}, ...
    'fontsize', 12 ...
    );



% End of file: robustlsqcurvefit_demo.m
