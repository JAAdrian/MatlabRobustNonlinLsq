classdef Robustlsqcurvefit_test < matlab.unittest.TestCase
    
    properties
        Unit = @robustlsqcurvefit;
        
        TrueParams;
        X;
        Y;
        Noise;
        ModelFun;
        X0
        Options;
    end
    
    
    methods (TestClassSetup)
        function setupData(testCase)
            param = [0.5, 1.25];
            
            x = linspace(0, 6, 100);
            modelFun = @(param, x) param(1)*exp(param(2) * x);
            
            noise = sin(x).^2 .* randn(size(x));
            
            y = modelFun(param, x) + noise;
            y(10) = 200;
            y(50) = 400;
            
            options = optimset(@lsqcurvefit);
            options.Display = 'off';
            
            testCase.TrueParams = param;
            testCase.X = x;
            testCase.Y = y;
            testCase.Noise = noise;
            testCase.ModelFun = modelFun;
            testCase.X0 = [1, 1];
            testCase.Options = options;
        end
    end
    
    
    methods (Test)
        function testSimpleCall(testCase)
            x = testCase.X;
            y = testCase.Y;
            fun = testCase.ModelFun;
            x0 = testCase.X0;
            options = testCase.Options;
            
            outputs = testCase.Unit(fun, x0, x, y, [], [], [], options);
            testCase.verifyNumElements(outputs, 2);
            testCase.verifyLessThan(norm(outputs - testCase.TrueParams).^2, 1e-4);
        end
        
        
        function testFullCall(testCase)
            x = testCase.X;
            y = testCase.Y;
            fun = testCase.ModelFun;
            x0 = testCase.X0;
            options = testCase.Options;
            
            lb = [0.1, 1];
            ub = [  1, 2];
            
            weightMethod = 'bisquare';
            
            outputs = testCase.Unit(fun, x0, x, y, lb, ub, weightMethod, options);
            testCase.verifyNumElements(outputs, 2);
            testCase.verifyLessThan(norm(outputs - testCase.TrueParams).^2, 1e-4);
        end
        
        
        function testInputValidation(testCase)
            x = testCase.X;
            y = testCase.Y;
            fun = testCase.ModelFun;
            x0 = testCase.X0;
            options = testCase.Options;
            
            % Wrong WeightMethod Input
            actual = @() testCase.Unit(fun, x0, x, y, [], [], 'foo', options);
            testCase.verifyError(actual, 'MATLAB:unrecognizedStringChoice');
            
            % Wrong lb Input
            actual = @() testCase.Unit(fun, x0, x, y, 'foo', [], [], options);
            testCase.verifyError(actual, 'MATLAB:robustlsqcurvefit:invalidType');
            
            % Correct Input
            actual = @() testCase.Unit(fun, x0, x, y, [], [], 'ols', options);
            testCase.verifyWarningFree(actual);
        end
        
        
        function testPrecision(testCase)
            x = testCase.X;
            y = testCase.Y;
            fun = testCase.ModelFun;
            x0 = testCase.X0;
            options = testCase.Options;
            
            est = testCase.Unit(fun, x0, x, y, [], [], [], options);
            testCase.verifyLessThan(norm(est - testCase.TrueParams).^2, 1e-4);
        end
        
        
        function canUseLessParameters(testCase)
            x = testCase.X;
            y = testCase.Y;
            fun = testCase.ModelFun;
            x0 = testCase.X0; 
            
            outputs = testCase.Unit(fun, x0, x, y);
            testCase.verifyNumElements(outputs, 2);
        end
    end
end

