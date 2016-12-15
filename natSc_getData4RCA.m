function dataOut = natSc_getData4RCA(where, how, reuse)
% Function will attempt to split data or load existing split.

% Take live3D_new data as an example, condition 1 is O-S, and condition 2 is
% S-O. After reading in the raw trials, the data were automatically arranged
% according to conditions. However, now we want to split it according to O and S.
% Each trial has 1260 time points, they were divided into 4 segments, 315
% time points each, either in scrambled - O - Scrambled -S, or Scrabmbled
% -S - Scrabmbled - O. This function goes into each trial, and splits each
% trial into 4 segments, and uses the 2nd and 4th segment to reconstruct
% the data structure needed for rca_run. 
%
% Arguments: 
% where -- what set of data to use
% how -- structure that describes split that will be performed 
% how.allCnd -- cell array of (labeled) conditions in alphabetical order, ex {'Cnd11','Cnd12, ... 'Cnd1m';...; 'Cndm1', ..., 'Cndmn'}
% how.useCnd -- cell array of conditions to use
% how.useSplits -- vector with splits
% how.nSplits -- number of splits
% how.splitBy -- cell array of labeled splits {}
% how.nScenes -- if 1, organize data to subject X condition array cell, if >1 organize data to scenes X condition array cell

    % what subset of subjects to use
    database = where;
    
    %how describes how to split source data 
    split = how.splitBy;
    
    % set up rca path
    rca_Path = rca_setPath;
    
    % check if the requested data exists
    if how.nScenes == 1
        dataOutFilename = strcat(database, 'data4RCA_', split{:},'_bySubjects', '.mat');
    else
        dataOutFilename = strcat(database, 'data4RCA_', split{:}, '_byScenes','.mat');
    end
    dataOutLocation = fullfile(rca_Path.results_Data, database, dataOutFilename);
    
    % if this is a new way of split or data needs to be recalculated
    if (~exist(dataOutLocation, 'file') || ~(reuse))
        
        
        eegSrc = ReadRawEEG(database,how);
        dataOut = natSc_SplitEEGData(eegSrc, how.useCnd, how.allCnd, how.splitBy, how.nSplits, how.useSplits, how.baseline);
        save(dataOutLocation, 'dataOut','-v7.3');
        
    else
        % file exists, load it 
        load(dataOutLocation);
    end
end