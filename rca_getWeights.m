function W = rca_getWeights(database, how, dirResData)

    reuse = 1;
    eegCND = rca_getData4RCA(database, how, reuse);
    
    %% get the RC weights for all
    nReg = 7;
    nComp = 3;
    
    rcaFileAll = fullfile(dirResData, strcat('rcaOn', how.splitBy{:}, '.mat'));
    if(~exist(rcaFileAll, 'file'))
        [rcaDataAll, W, A, ~, ~, ~, ~] = rcaRun(eegCND', nReg, nComp);
        save(rcaFileAll, 'rcaDataAll', 'W', 'A');
    else
        load(rcaFileAll);
    end
end