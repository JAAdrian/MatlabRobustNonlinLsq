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

estParamsOrdinary  = polyfit(x, y, 1);
estParamsRobust    = robustlsqcurvefit(modelFun, x0, x, y, [], [], [], options);
estLinearRobustFit = robustfit(x, y);

figure;
hold on;
scatter(x, y, 'filled');
plot(x, modelFun([-2, 10], x), 'k--', 'linewidth', 2);
plot(x, modelFun(estParamsOrdinary, x), 'linewidth', 2);
plot(x, modelFun(estParamsRobust, x), 'linewidth', 2);
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

estParamsOrdinary = lsqcurvefit(modelFun, x0, x, y, [], [], options);
estParamsRobust   = robustlsqcurvefit(modelFun, x0, x, y, [], [], [], options);

figure;
hold on;
scatter(x, y, 'filled');
plot(x, modelFun(trueParams, x), 'k--', 'linewidth', 2);
plot(x, modelFun(estParamsOrdinary, x), 'linewidth', 2);
plot(x, modelFun(estParamsRobust, x), 'linewidth', 2);
hold off;
grid on;

legend(...
    {'Noisy Data', 'True Regression', 'Ordinary non-lin LSQ', 'Robust non-lin LSQ'}, ...
    'fontsize', 12 ...
    );

%% Square-Root Function Fit incl. Lower and Upper Parameter Bounds
% the model's true parameters
trueParams = [50, -0.7];

% create some noisy data using a square root function with 2 parameters and nasty noise
x = linspace(0, 20, 100);
modelFun = @(param, x) param(1)*sqrt(max(0, x + param(2)));

noise = 10*sin(x).^2 .* randn(size(x));

y = modelFun(trueParams, x) + noise;

% introduce outliers
y(11)  = -300;
y(end) = 2000;

% make sure the parameters are within the following range
lb = [1, -inf];
ub = [inf, 10];

% initial guess
x0 = [1, -1];

% don't show infos from lsqcurvefit()
options = optimset(@lsqcurvefit);
options.Display = 'off';

% estimate parameters using ordinary and robust LSQ
estParamsOrdinary = lsqcurvefit(modelFun, x0, x, y, lb, ub, options);
estParamsRobust   = robustlsqcurvefit(modelFun, x0, x, y, lb, ub, [], options);

figure;
hold on;
scatter(x, y, 'filled');
plot(x, modelFun(trueParams, x), 'k--', 'linewidth', 2);
plot(x, modelFun(estParamsOrdinary, x), 'linewidth', 2');
plot(x, modelFun(estParamsRobust, x), 'linewidth', 2);
hold off;
grid on;

title('Square-Root Fit');
xlabel('x data');
ylabel('y data');

legend(...
    {'Noisy Data', 'True Regression', 'Ordinary non-lin LSQ', 'Robust non-lin LSQ'}, ...
    'fontsize', 12 ...
    );



% End of file: robustlsqcurvefit_demo.m
