% Demonstrate robustlsqcurvefit() in some applications
%
% Author:  J.-A. Adrian (JA) <jensalrik.adrian AT gmail.com>
% Date  :  05-May-2017 22:46:35
%

clear;
close all;

%% Easy Linear Model With Noise and Outliers
x = (0:10)';
rng default; % For reproducibility
y = -2*x + 10 + randn(size(x));

% introduce outlier
y(11) = 0;

modelFun = @(params, x) params(1)*x + params(2);
x0       = [-1, 1];

options = optimset(@lsqcurvefit);
options.Display = 'off';

estParamsReference = polyfit(x, y, 1);
estParams          = robustlsqcurvefit(modelFun, x0, x, y, [], [], [], options);
estRobustFit       = robustfit(x, y);

figure;
hold on;
scatter(x, y, 'filled');
plot(x, modelFun([-2, 10], x), 'k--', 'linewidth', 2);
plot(x, modelFun(estParamsReference, x), 'linewidth', 2);
plot(x, modelFun(estParams, x), 'linewidth', 2);
hold off;
grid on;

legend(...
    {'Noisy Data', 'True Regression', 'Ordinary non-lin LSQ', 'Robust non-lin LSQ'}, ...
    'fontsize', 12 ...
    );

%% Exponential Model With Noise and Outliers
trueParams = [0.5, 1.25];

x = linspace(0, 6, 100);
modelFun = @(param, x) param(1)*exp(param(2) * x);

noise = 20*sin(x).^2 .* randn(size(x));

y = modelFun(trueParams, x) + noise;

% introduce outliers
y(1)  = -400;
y(end) = 2000;

x0 = [0.3, 2];

options = optimset(@lsqcurvefit);
options.Display = 'off';

estParamsReference = lsqcurvefit(modelFun, x0, x, y, [], [], options);
estParams          = robustlsqcurvefit(modelFun, x0, x, y, [], [], [], options);

figure;
hold on;
scatter(x, y, 'filled');
plot(x, modelFun(trueParams, x), 'k--', 'linewidth', 2);
plot(x, modelFun(estParamsReference, x), 'linewidth', 2);
plot(x, modelFun(estParams, x), 'linewidth', 2);
hold off;
grid on;

legend(...
    {'Noisy Data', 'True Regression', 'Ordinary non-lin LSQ', 'Robust non-lin LSQ'}, ...
    'fontsize', 12 ...
    );

%% Square-Root Function Fit incl. Lower and Upper Parameter Bounds
trueParams = [50, -0.7];

x = linspace(0, 20, 100);
modelFun = @(param, x) param(1)*sqrt(max(0, x + param(2)));

noise = sin(x).^2 .* randn(size(x));

y = modelFun(trueParams, x) + noise;

% introduce outliers
y(11)  = -300;
y(end) = 2000;

lb = [1, -inf];
ub = [inf, 10];

x0 = [1, -1];

options = optimset(@lsqcurvefit);
options.Display = 'off';

estParamsReference = lsqcurvefit(modelFun, x0, x, y, lb, ub, options);
estParams          = robustlsqcurvefit(modelFun, x0, x, y, lb, ub, [], options);

figure;
hold on;
scatter(x, y, 'filled');
plot(x, modelFun(trueParams, x), 'k--', 'linewidth', 2);
plot(x, modelFun(estParamsReference, x), 'linewidth', 2');
plot(x, modelFun(estParams, x), 'linewidth', 2);
hold off;
grid on;

legend(...
    {'Noisy Data', 'True Regression', 'Ordinary non-lin LSQ', 'Robust non-lin LSQ'}, ...
    'fontsize', 12 ...
    );


% End of file: robustlsqcurvefit_demo.m
