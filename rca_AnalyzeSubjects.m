function rca_AnalyzeSubjects

    %Project RCA on individual scenes
    %Calculate differences between scenes
    %Get OZ signal for each scene  
    
    database = 'Live3D';
    rca_path = rca_setPath;
    dirResData = fullfile(rca_path.results_Data, database);
    % describing splits
    switch database
        case 'Live3D'
            how.allCnd = {'D', 'E'; 'D', 'O'; 'D', 'S'; 'E', 'D';'E', 'O'; 'E', 'S'; 'O', 'D'; 'O', 'E'; 'O', 'S'; 'S', 'D'; 'S', 'E'; 'S', 'O'};
            how.splitBy = {'O', 'S'};
            timeCourseLen = 660;
        case 'Middlebury'
            how.allCnd = {'E', 'O'; 'E', 'S'; 'O', 'E'; 'O', 'S'; 'S', 'E'; 'S', 'O'};
            how.splitBy = {'O', 'S'};
            timeCourseLen = 500;          
        otherwise
    end
    
    cl = {'r', 'g', 'b', 'k'};
    row = 5;
    col = 5; 
    
    %% load/calculate the RC data on a given dataset
    
    how.useCnd = how.allCnd;
    how.nSplits = 4;
    how.useSplits = [2, 4];
    how.baseline = 1;
    reuse = 1;
    dirResFigures = fullfile(rca_path.results_Figures, database, strcat('rcaProject', how.splitBy{:}));
    
    if (~exist(dirResFigures, 'dir'))
        mkdir(dirResFigures);
    end
    
    %% get RC weights    
    eegCND = rca_getData4RCA(database, how, reuse);
    
    nReg = 7;
    nComp = 3;
    
    rcaFileAll = fullfile(dirResData, strcat('rcaOn', how.splitBy{:}, '.mat'));
    if(~exist(rcaFileAll, 'file'))
        [~, W, ~, ~, ~, ~, ~] = rcaRun(eegCND', nReg, nComp);
        save(rcaFileAll, 'rcaDataAll', 'W', 'A');
    else
        load(rcaFileAll);
    end
        
    %% Run rca project for each subject
    timeCourse = linspace(0, timeCourseLen, size(eegCND{1, 1}, 1));   
    nCnd = numel(how.splitBy);
    
    %use only first component!
    rcComp = 1;
    
    % load subjects 
    dirEEG = list_folder(fullfile(rca_path.srcEEG, database));
    
    subj_list = {dirEEG.name};
    subj_list = subj_list([dirEEG.isdir]);
    
    nSubj = numel(subj_list);
    
    close all;
    for si = 1:nSubj    
        subplot(row, col, si);
        color_idx = 1;        
        for cn = nCnd:-1:1  
            [muData_C, semData_C] = rcaProjectmyData(eegCND(si, cn), W);    
            hs = shadedErrorBar(timeCourse, muData_C(:, rcComp), semData_C(:, rcComp), cl{color_idx}); hold on
            h{cn} = hs.patch;
            color_idx = color_idx + 1;
        end
        legend([h{end:-1:1}], [how.splitBy{end:-1:1}]'); hold on;
        title([subj_list(si) ' time course'], 'Interpreter', 'none');    
    end
    saveas(gcf, fullfile(dirResFigures, strcat('rcaProject_onSubj', how.splitBy{:})), 'fig');
    close(gcf);       
end