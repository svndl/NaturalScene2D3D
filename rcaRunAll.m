function rcaRunAll
    database = 'Live3D';
          
    rca_path = rca_setPath;
    dirResFigures = fullfile(rca_path.results_Figures, database);
    dirResData = fullfile(rca_path.results_Data, database);
    
    eegRCA = fullfile(rca_path.rcaEEG, database);
    rcaDataOut = rcaReadRawEEG(database);

    %% RCA load W or run the analysis 
    
    nReg = 7;
    nComp = 3;
    
    fileRCA = fullfile(dirResData, 'resultRCA.mat');
        
    if(~exist(fileRCA, 'file'))
        [rcaDataALL, W, A, ~, ~, ~, ~] = rcaRun(rcaDataOut', nReg, nComp);
        save(fileRCA, 'rcaDataALL', 'W', 'A');
                 %save subj rca data and export figure to pdf
    else
        load(fileRCA);
    end
    % do the plots
    
    catDataAll = cat(3, rcaDataALL{:});
    muDataAll = nanmean(catDataAll, 3);
    muDataAll = muDataAll - repmat(muDataAll(1, :), [size(muDataAll, 1) 1]);
    semDataAll = nanstd(catDataAll, [], 3)/(sqrt(size(catDataAll, 3)));
    timeCourse = linspace(0, 2660, size(muDataAll, 1));
    
     close all;
    
    %% run the projections            
    for c = 1:nComp
        subplot(nComp, 2, 2*c - 1);
        shadedErrorBar(timeCourse, muDataAll(:, c), semDataAll(:, c));hold on;
        title(['RC' num2str(c) ' time course']);
        subplot(nComp, 2, 2*c);
        plotOnEgi(A(:,c)); hold on;
     end 
     saveas(gcf, fullfile(dirResFigures, 'rcaComponentsAll'), 'fig');
     close(gcf);    
end