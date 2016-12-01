function rcaOnSplitConditions
    database = 'Live3D';
    rca_path = rca_setPath;
    dirResData = fullfile(rca_path.results_Data, database);
    
    % describing splits
    
    switch database
        case 'Live3D'
            how.allCnd = {'D', 'E'; 'D', 'O'; 'D', 'S'; 'E', 'D';'E', 'O'; 'E', 'S'; 'O', 'D'; 'O', 'E'; 'O', 'S'; 'S', 'D'; 'S', 'E'; 'S', 'O'};
            %how.splitBy = {'D', 'E', 'O', 'S'};
            how.splitBy = {'E', 'S'};
            seg_duration = 660;
        case 'Middlebury'
            how.allCnd = {'E', 'O'; 'E', 'S'; 'O', 'E'; 'O', 'S'; 'S', 'E'; 'S', 'O'};
            how.splitBy = {'O', 'S'};
            seg_duration = 500;
        otherwise
    end
            
    
    how.useCnd = how.allCnd;
    
    how.nSplits = 4;
    how.useSplits = [2, 4];
    how.baseline = 1;
    reuse = 0;    
    dirResFigures = fullfile(rca_path.results_Figures, database, strcat('rcaProject', how.splitBy{:}));
    
    if (~exist(dirResFigures, 'dir'))
        mkdir(dirResFigures);
    end
   
    eegCND = rca_getData4RCA(database, how, reuse);
    
    %run on everything 
    nReg = 7;
    nComp = 3;
    
    rcaFileAll = fullfile(dirResData, strcat('rcaOn', how.splitBy{:}, '.mat'));
    if(~exist(rcaFileAll, 'file'))
        [rcaDataAll, W, A, ~, ~, ~, ~] = rcaRun(eegCND', nReg, nComp);
        save(rcaFileAll, 'rcaDataAll', 'W', 'A');
    else
        load(rcaFileAll);
    end
    
    
    %project on conditions
    cl = {'r', 'g', 'b', 'k'};
    catDataAll = cat(3, rcaDataAll{:});
    muDataAll = nanmean(catDataAll, 3);
    
    timeCourse = linspace(0, seg_duration, size(muDataAll, 1));

    close all;
    nCnd = numel(how.splitBy);
    h = cell(nCnd, 1);
    %% run the projections, plot the topography
    for c = 1:nComp
        
        subplot(nComp, 2, 2*c - 1);                
        color_idx = 1;        
        for cn = nCnd:-1:1  
            [muData_C, semData_C] = rcaProjectmyData(eegCND(:, cn), W);    
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
