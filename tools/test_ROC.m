% ------------------------------------------------------------------------
% Generate the results of the ROC curve on JD datasets, forever21 datasets.
% The methods tested include the 'Fast-RCNN', 'Pose detector'.
%
% Written by Tingwu Wang, 20.7.2015, as a junior RA in CUHK, MMLAB
% ------------------------------------------------------------------------

% set this on when we use 50% as the training set, and the rest 50% as test
% set in the JD datasets
test_type_1000 = true;

% set the dataset you want to test
JD_datasets = false;
forever21_datasets = true;

% a dataset transition
upper = [5, 6, 12, 14, 25, 26, 27, 39, 42, 47, 49, 50, 52, 55, 56];
lower = [28, 31, 32, 41, 43, 46, 54];
whole = [15, 36];

if forever21_datasets == true
    ROC_forever21_datasets(upper, lower, whole);
end