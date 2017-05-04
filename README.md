# MatlabRobustNonlinLsq

MATLAB's function `robustfit()` enables to fit a polynomial to data whose residuals are not normally distributed, which is the implicit assumption of Least-Squares (LSQ) methods. Non-normal residuals result, for example, from outliers in empirical data or noise which is not normally distributed. The function utilizes the *Iteratively Reweighted Least Squares* (IRLS) approach with good parameter settings and data-adaptive weights.

The downside is that `robustfit()` does not support *Non-Linear least squares* problems which often arise if the mathematical model is non-linear in its parameters. The function `lsqcurvefit()` and `lsqnonlin()` provide means to solve non-linear LSQ but don't support weighted LSQ for robust estimation in the presence of outliers.

This MATLAB function is intended to give the best of both worlds, i.e. combine methods of `robustfit()` and `lsqnonlin()` to accomplish robust non-linear least squares calculations

## Dependencies

## Usage

## License

The code is licensed under BSD 3-Clause license.
