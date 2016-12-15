function rca_Analyze2D3D(database,nScenes)

    % Function written for NatImIVD project
    % For RCA analysis of 3D natural images across individuals or scenes
    % Documentation of this project can be found at svndl lab wiki
    % The function does the following
    % 1. rearranging the raw trials into correct format to feed in rca_run
    % 2. do rca_run, either based on subjects, or scenes. 
    % 3. Project the rca weights back into individual subject/scene space
    % 4. The following output will be saved as a result of this function
    %       1. figures: rcaProject_GrandMeanOS.fig, rcaProject_onSubjOS.fig
    %          plotData_1.csv and plotDataGrandMean.csv is for same visualization in R 
    %       2. rcaOnOS_bySubjects.mat: contains A and W (both are 128X3 double)
    %       3. dataRCA_OS_bySubjects:contains dataOut,This is specifically for
               % this project, a cell array subjectXcondition, within each cell, 
               % timeSampleXchannelsXTrials 
    %       4. rcaEEG: rcaDataOut: contains subjectXcondition cell array,
    %       this is the general data structure directly extracted from raw trials. within each cell,
    %       timeSampleXchannelXtrials
    %       
    %  Dependencies: https://github.com/svndl/rcaBase
    %       

    
 % Inputs
 %database: string, the name of the database folder
 %nScenes: optional, By default, nScenes = 1, function analyzes individual subjects
 %if nScenes > 1, it should be set as the number of scenes to be analyzed, and the function analyzes individual scenes
    
    if nargin<2 || isempty(nScenes), nScenes = 1; end

    rca_path = rca_setPath;
    dirResData = fullfile(rca_path.results_Data, database);
    
    % describing splits
    switch database
        case 'Live3D'
            how.allCnd = {'D', 'E'; 'D', 'O'; 'D', 'S'; 'E', 'D';'E', 'O'; 'E', 'S'; 'O', 'D'; 'O', 'E'; 'O', 'S'; 'S', 'D'; 'S', 'E'; 'S', 'O'};
            how.splitBy = {'O', 'S'};
            how.nScenes = nScenes;
            timeCourseLen = 660;

        case 'Middlebury'
            how.allCnd = {'E', 'O'; 'E', 'S'; 'O', 'E'; 'O', 'S'; 'S', 'E'; 'S', 'O'};
            how.splitBy = {'O', 'S'};
            timeCourseLen = 500;
            how.nScenes = nScenes;
 
        case 'Live3D_new'
            how.allCnd = {'O', 'S'; 'S', 'O'};
            how.splitBy = {'O', 'S'};
            timeCourseLen = 750;  
            how.nScenes = nScenes;
  
        case 'Test'
            how.allCnd = {'O', 'S'; 'S', 'O'};
            how.splitBy = {'O', 'S'};
            timeCourseLen = 750;  
            how.nScenes = nScenes;
        
            
        otherwise
    end
    
    cl = {'r', 'g', 'b', 'k'};
    row = 6;
    col = 5; 
    
    %% load/calculate the RC data on a given dataset
    
    how.useCnd = how.allCnd;
    how.nSplits = 4;
    how.useSplits = [2, 4];
    how.baseline = 1; %I think we should do baslining at the end, after projecting to each individual space, before plotting
    reuse = 0;
    
    if nScenes == 1
        dirResFigures = fullfile(rca_path.results_Figures, database, strcat('rcaProject', how.splitBy{:},'_bySubjects'));
        
    else
        dirResFigures = fullfile(rca_path.results_Figures, database, strcat('rcaProject', how.splitBy{:},'_byScenes'));
    end
    
    if (~exist(dirResFigures, 'dir'))
        mkdir(dirResFigures);
    end
    if (~exist(dirResData, 'dir'))
        mkdir(dirResData);
    end
    
    %% get RC weights    
    eegCND = natSc_getData4RCA(database, how, reuse);
    
    nReg = 7;
    nComp = 3;
    
    if nScenes ==1
        
        rcaFileAll = fullfile(dirResData, strcat('rcaOn', how.splitBy{:}, '_bySubjects.mat'));
        
    else
        rcaFileAll = fullfile(dirResData, strcat('rcaOn', how.splitBy{:}, '_byScenes.mat'));
    end
    
    if(~exist(rcaFileAll, 'file'))
        [~, W, A, ~, ~, ~, ~] = rcaRun(eegCND', nReg, nComp);
        save(rcaFileAll, 'W', 'A');
    else
        load(rcaFileAll);
    end
        
    %% Run rca project for each subject / each scene
    
    timeCourse = linspace(0, timeCourseLen, size(eegCND{1, 1}, 1));   
    nCnd = numel(how.splitBy);
    
    %use only first component!
    rcComp = 1;
    
    % load subjects 
    dirEEG = list_folder(fullfile(rca_path.srcEEG, database));
    
    subj_list = {dirEEG.name};
    subj_list = subj_list([dirEEG.isdir]);
   
    %%%%%%%%%%%%%%%%save data as .csv For plotting In R%%%%%%%%%%%%%%%%
    if nScenes ==1
    
        nSubj = numel(subj_list);
        save('subidx','subj_list'); % for the plotting in R
    
    else
         nSubj = nScenes;
    end
    
 
    
    dataframe = zeros(nSubj*length(timeCourse),6); 
    %save mean and se to dataframe for the purpose of plotting in R. 
 
 
    close all;
    
    baselineSample = round(50/timeCourseLen*length(timeCourse)); %First 50 ms as the baseline
    for si = 1:nSubj    
        subplot(row, col, si);
        color_idx = 1;
        startIdx = (si-1)*length(timeCourse)+1;
        endIdx = si*length(timeCourse);
        for cn = 1:nCnd  
            
            [muData_C, semData_C] = natSc_ProjectmyData(eegCND(si, cn), W,baselineSample);
            %[muData_C, semData_C] = rcaProjectmyData(eegCND(si, cn), W);

            
            if cn ==1
                dataframe(startIdx:endIdx,1) = si;
                
                dataframe(startIdx:endIdx,2:4) = [timeCourse',muData_C(:,1),semData_C(:,1)];
                
            else
                dataframe(startIdx:endIdx,5:6) = [muData_C(:,1),semData_C(:,1)];
            end

            hs = shadedErrorBar(timeCourse, muData_C(:, rcComp), semData_C(:, rcComp), cl{color_idx}); hold on
            h{cn} = hs.patch;
            color_idx = color_idx + 1;
        end
        legend([h{end:-1:1}], [how.splitBy{end:-1:1}]'); hold on;
        
        if nScenes ==1
            title([subj_list(si) ' time course'], 'Interpreter', 'none');
        else
            title([si ' time course'], 'Interpreter', 'none');
        end
    end
    
    
    csvwrite(fullfile(dirResFigures,strcat('plotData_',num2str(nScenes),'.csv')),dataframe);
    saveas(gcf, fullfile(dirResFigures, strcat('rcaProject_onSubj', how.splitBy{:})), 'fig');
    
    close(gcf);
    
%   %% project to the grand mean (Across all subjects and across all scenes) 
%   % The eegCND matrix to be projected will be a 315X128X(240*#of subjects)
%   
%   if how.plotMeanProjection
%       
%      
%     
%     dataframe2 = zeros(length(timeCourse),5); 
%     %save mean and se to dataframe for the purpose of plotting in R. 
%     
%     close all;
%     
%     baselineSample = round(50/timeCourseLen*length(timeCourse)); %First 50 ms as the baseline
%      
%         figure;
%         color_idx = 1;
%         startIdx = 1;
%         endIdx = length(timeCourse);
%         for cn = 1:nCnd  
%             catData{cn} = cat(3,eegCND{:,cn});
%             
%             
%             [muData_C, semData_C] = rcaProjectmyData(catData(cn), W,baselineSample);
% 
%             
%             if cn ==1
%                 
%                 
%                 dataframe2(startIdx:endIdx,1:3) = [timeCourse',muData_C(:,1),semData_C(:,1)];
%                 
%             else
%                 dataframe2(startIdx:endIdx,4:5) = [muData_C(:,1),semData_C(:,1)];
%             end
% 
%             hs = shadedErrorBar(timeCourse, muData_C(:, rcComp), semData_C(:, rcComp), cl{color_idx}); hold on
%             h{cn} = hs.patch;
%             color_idx = color_idx + 1;
%         end
%         legend([h{end:-1:1}], [how.splitBy{end:-1:1}]'); hold on;
%    
%    
%     
%     
%     csvwrite(fullfile(dirResFigures,strcat('plotDataGranMean.csv')),dataframe2);
%     saveas(gcf, fullfile(dirResFigures, strcat('rcaProject_GranMean', how.splitBy{:})), 'fig');
%     
%     close(gcf);  
%       
%       
%   end
  
    
    
    
end