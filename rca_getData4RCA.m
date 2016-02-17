function dataOut = rca_getData4RCA(where, how, reuse)
% Function will attempt to split data or load existing split.
% Arguments: 
% where -- what set of data to use
% how -- structure that describes split that will be performed 
% how.allCnd -- cell array of (labeled) conditions in alphabetical order, ex {'Cnd11','Cnd12, ... 'Cnd1m';...; 'Cndm1', ..., 'Cndmn'}
% how.useCnd -- cell array of conditions to use
% how.useSplits -- vector with splits
% how.nSplits -- number of splits
% how.splitBy -- cell array of labeled splits {}

    % what subset of subjects to use
    database = where;
    
    %how describes how to split source data 
    split = how.splitBy;
    
    % set up rca path
    rcaPath = rca_setPath;
    
    % check if the requested data exists
    dataOutFilename = strcat(database, 'data4RCA_', split{:}, '.mat');
    dataOutLocation = fullfile(rcaPath.results_Data, database, dataOutFilename);
    
    % if this is a new way of split or data needs to be recalculated
    if (~exist(dataOutLocation, 'file') || ~(reuse))
        eegSrc = rcaReadRawEEG(database);
        dataOut = rcaSplitEEGData(eegSrc, how.useCnd, how.allCnd, how.splitBy, how.nSplits, how.useSplits, how.baseline);
    else
        % file exists, load it 
        dataOut = load(dataOutLocation);
    end
end