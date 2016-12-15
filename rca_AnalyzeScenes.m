function rca_AnalyzeScenes
    %Project RCA on individual scenes
    %Calculate differences between scenes
    %Get OZ signal for each scene  
    
    database = 'Live3D_new';
    rca_path = rca_setPath;
    dirResData = fullfile(rca_path.results_Data, database);
    % describing splits
    switch database
        case 'Live3D'
            how.allCnd = {'D', 'E'; 'D', 'O'; 'D', 'S'; 'E', 'D';'E', 'O'; 'E', 'S'; 'O', 'D'; 'O', 'E'; 'O', 'S'; 'S', 'D'; 'S', 'E'; 'S', 'O'};
            how.splitBy = {'O', 'S'};
            nScenes = 12;
            timeCourseLen = 660;
            row = 3;
            col = 4; 
        case 'Middlebury'
            how.allCnd = {'E', 'O'; 'E', 'S'; 'O', 'E'; 'O', 'S'; 'S', 'E'; 'S', 'O'};
            how.splitBy = {'O', 'S'};
            nScenes = 30;
            timeCourseLen = 500;
            row = 5;
            col = 6;
        case 'Live3D_new'
            how.allCnd = {'O', 'S'; 'S', 'O'};
            how.splitBy = {'O', 'S'};    
            how.nScenes = 30;
            timeCourseLen = 750;
            row = 6;
            col = 5; 
        
        otherwise
    end
    cl = {'r', 'g', 'b', 'k'};
            
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
        [~, W, A, ~, ~, ~, ~] = rcaRun(eegCND', nReg, nComp);
        save(rcaFileAll, 'W', 'A');
    else
        load(rcaFileAll);
    end
        
    %% Run rca project for each subject
    timeCourse = linspace(0, timeCourseLen, size(eegCND{1, 1}, 1));   
    nCnd = numel(how.splitBy);
    
    %use only first component!
    rcComp = 1;
    
    % load subjects 

    
    nSubj = how.nScenes;
    
    close all;
    
    baselineSample = round(50/timeCourseLen*length(timeCourse)); %First 50 ms as the baseline
    for si = 1:nSubj    
        subplot(row, col, si);
        color_idx = 1;        
        for cn = nCnd:-1:1  
            [muData_C, semData_C] = rcaProjectmyData(eegCND(si, cn), W,baselineSample);    
            hs = shadedErrorBar(timeCourse, muData_C(:, rcComp), semData_C(:, rcComp), cl{color_idx}); hold on
            h{cn} = hs.patch;
            color_idx = color_idx + 1;
        end
        legend([h{end:-1:1}], [how.splitBy{end:-1:1}]'); hold on;
        title([si ' time course'], 'Interpreter', 'none');    
    end
    saveas(gcf, fullfile(dirResFigures, strcat('rcaProject_onSubj', how.splitBy{:})), 'fig');
    close(gcf);       
    
    
    
    
    
    
    
    
    
%     %% get RC weights    
%     eegCND = rca_getData4RCA(database, how, reuse);
%     
%     nReg = 7;
%     nComp = 3;
%     
%     rcaFileAll = fullfile(dirResData, strcat('rcaOn', how.splitBy{:}, '.mat'));
%     if(~exist(rcaFileAll, 'file'))
%         [~, W, A, ~, ~, ~, ~] = rcaRun(eegCND', nReg, nComp);
%         save(rcaFileAll, 'W', 'A');
%     else
%         load(rcaFileAll);
%     end
%     
%     %% Create scene split cell matrix
% %     nTypes = numel(how.splitBy);
% %     eegSplitByScenes = cell(nScenes, nTypes);
% %      
% %     nSubj = size(eegCND, 1);
% %     for cnd = 1:nTypes
% %         for subj = 1:nSubj
% %             eeg = eegCND{subj, cnd};
% %             for k = 1:size(eeg, 3)
% %                 nscene = rem(k - 1, nScenes) + 1;
% %                 vl = size(eegSplitByScenes{nscene, cnd}, 3);                
% %                 eegSplitByScenes{nscene, cnd}(:, :, vl + 1) = eeg(:, :, k);
% %             end
% %         end    
% %     end
% %     
%     %% Run rca project for each scene
%     timeCourse = linspace(0, timeCourseLen, size(eegCND{1, 1}, 1));   
%     nCnd = numel(how.splitBy);
%     
%     %use only first component!
%     rcComp = 1;
%     
%     % load scenes /create a dummy list
%     scene_list = fullfile(rca_path.srcEEG, database, 'scene_list.mat');
%     try
%         load(scene_list)      
%     catch
%         scene_list_num = 1:nScenes;
%         Scenes = num2str(scene_list_num);
%     end
% 
%     for si = 1:nScenes
%         
%         subplot(row, col, si);
%         color_idx = 1;        
%         for cn = nCnd:-1:1  
%             [muData_C, semData_C] = rcaProjectmyData(eegSplitByScenes(si, cn), W);    
%             hs = shadedErrorBar(timeCourse, muData_C(:, rcComp), semData_C(:, rcComp), cl{color_idx}); hold on
%             h{cn} = hs.patch;
%             color_idx = color_idx + 1;
%         end
%         legend([h{end:-1:1}], [how.splitBy{end:-1:1}]'); hold on;
%         title([Scenes(si) ' time course'], 'Interpreter', 'none');    
%     end
%     saveas(gcf, fullfile(dirResFigures, strcat('rcaProject_onScenes', how.splitBy{:})), 'fig');
%     close(gcf);         
end