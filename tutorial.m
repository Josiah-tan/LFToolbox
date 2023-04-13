
cd ~/LFToolbox0.5_Samples/    

LFUtilProcessWhiteImages

LFUtilDecodeLytroFolder


%%

LFUtilDecodeLytroFolder('Cameras/A000424242/PlenCalSmallExample/');

%%

CalOptions.ExpectedCheckerSize = [8,6];
CalOptions.ExpectedCheckerSpacing_m = 1e-3*[35.1, 35.0];
CalOptions.ForceRedoInit = true;
CalOptions.ForceRedoCornerFinding = true;
LFUtilCalLensletCam('Cameras/A000424242/PlenCalSmallExample', CalOptions);


%% validating


LFUtilProcessCalibrations


