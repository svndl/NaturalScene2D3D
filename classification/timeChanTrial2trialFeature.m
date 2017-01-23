function x2d = timeChanTrial2trialFeature(x3d)

% x2d = timeChanTrial2trialFeature(x3d)
% --------------------------------------
% Blair - Jan 20, 2017
% This function takes in the 3d time x channel x trial matrix and reshapes
% it into a 2d trial x feature matrix. 'Features' in the output are the
% concatenated electrodes of data for that trial.
%
% Requires helper function cube2trRows

% Change dimensions to be channel x time x trial
xTemp = permute(x3d, [2 1 3]);
x2d = cube2trRows(xTemp);