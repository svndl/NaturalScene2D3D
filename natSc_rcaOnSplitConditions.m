function nacSc_rcaOnSplitConditions(nScenes)
    database = 'Live3D_new';
    rca_path = rca_setPath;
    dirResData = fullfile(rca_path.results_Data, database);
    
    % describing splits
    
    switch database
        case 'Live3D'
            how.allCnd = {'D', 'E'; 'D', 'O'; 'D', 'S'; 'E', 'D';'E', 'O'; 'E', 'S'; 'O', 'D'; 'O', 'E'; 'O', 'S'; 'S', 'D'; 'S', 'E'; 'S', 'O'};
            %how.splitBy = {'D', 'E', 'O', 'S'};
            how.splitBy = {'O', 'S'};
            timeCourseLen = 660;
            how.nScenes = nScenes;
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
        otherwise
    end
            
    
    how.useCnd = how.allCnd;
    
    how.nSplits = 4;
    how.useSplits = [2, 4];
    how.baseline = 1;
    reuse = 1;    
    if nScenes == 1
        dirResFigures = fullfile(rca_path.results_Figures, database, strcat('rcaProject', how.splitBy{:},'_bySubjects'));
        
    else
        dirResFigures = fullfile(rca_path.results_Figures, database, strcat('rcaProject', how.splitBy{:},'_byScenes'));
    end
    
    if (~exist(dirResFigures, 'dir'))
        mkdir(dirResFigures);
    end
   
    eegCND = natSc_getData4RCA(database, how, reuse);
    
    %run on everything 
    nReg = 7;
    nComp = 3;
    
    rcaFileAll = fullfile(dirResData, strcat('rcaOn', how.splitBy{:},'_bySubjects.mat'));
    if(~exist(rcaFileAll, 'file'))
        [rcaDataAll, W, A, ~, ~, ~, ~] = rcaRun(eegCND', nReg, nComp);
        save(rcaFileAll, 'rcaDataAll', 'W', 'A');
    else
        load(rcaFileAll);
    end
    
    
    %project on conditions
    cl = {'r', 'g', 'b', 'k'};
    %catDataAll = cat(3, rcaDataAll{:});
    %muDataAll = nanmean(catDataAll, 3);
    
    %timeCourse = linspace(0, timeCourse, size(muDataAll, 1));
    timeCourse = linspace(0, timeCourseLen, size(eegCND{1, 1}, 1));  

    close all;
    nCnd = numel(how.splitBy);
    h = cell(nCnd, 1);
    %% run the projections, plot the topography
    baselineSample = round(50/timeCourseLen*length(timeCourse)); %First 50 ms as the baseline
      
    for c = 1:nComp
        
        subplot(nComp, 2, 2*c - 1);                
        color_idx = 1;        
        for cn = nCnd:-1:1  
            [muData_C, semData_C] = natSc_ProjectmyData(eegCND(:, cn), W,baselineSample);   
            %[muData_C, semData_C] = matSc_ProjectmyData(eegCND(:, cn), W);
            hs = shadedErrorBar(timeCourse, muData_C(:, c), semData_C(:, c), cl{color_idx}); hold on
            h{cn} = hs.patch;
            color_idx = color_idx + 1;
        end
        legend([h{end:-1:1}], [how.splitBy{end:-1:1}]'); hold on;
        title(['RC' num2str(c) ' time course']);
        subplot(nComp, 2, 2*c);
        plotOnEgi(A(:,c)); hold on;
    end
    
    saveas(gcf, fullfile(dirResFigures, strcat('rcaProject_', how.splitBy{:})), 'fig');
    close(gcf);     
end