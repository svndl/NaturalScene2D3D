function natSc_plotSubjOZ

    database = 'Live3D_new';
    rca_path = rca_setPath;

    
    dirResData = fullfile(rca_path.results_Data, database);

    switch database
        case 'Live3D'
            how.allCnd = {'D', 'E'; 'D', 'O'; 'D', 'S'; 'E', 'D';'E', 'O'; 'E', 'S'; 'O', 'D'; 'O', 'E'; 'O', 'S'; 'S', 'D'; 'S', 'E'; 'S', 'O'};
            %how.splitBy = {'D', 'E', 'O', 'S'};
            how.splitBy = {'O', 'S'};
        case 'Middlebury'
            how.allCnd = {'E', 'O'; 'E', 'S'; 'O', 'E'; 'O', 'S'; 'S', 'E'; 'S', 'O'};
            how.splitBy = {'O', 'S'};
        case 'Live3D_new'
            how.allCnd = {'O', 'S'; 'S', 'O'};
            how.splitBy = {'O', 'S'};
        otherwise
    end
            
    dirResFigures = fullfile(rca_path.results_Figures, database, strcat('rcaProject', how.splitBy{:}));

    if (~exist(dirResFigures, 'dir'))
        mkdir(dirResFigures);
    end
    
    how.useCnd = how.allCnd;
    
    how.nSplits = 4;
    how.useSplits = [2, 4];
    how.baseline = 1;
    how.nScenes = 1;
    reuse = 1;    
    
    eegCND = rca_getData4RCA(database, how, reuse);
    close all;
    nSubj = size(eegCND, 1);
    
    cndNotStereo = eegCND(:, 1);
    cndStereo = eegCND(:, 2);
    
    nS_all = cat(3, cndNotStereo{:});
    S_all = cat(3, cndStereo{:});
    OZ_O_all = nanmean(squeeze(nS_all(:, 75, :)), 2);
    OZ_S_all = nanmean(squeeze(S_all(:, 75, :)), 2);
    
    plot(OZ_O_all, 'r', 'Linewidth', 2); hold on;
    plot(OZ_S_all, 'b', 'Linewidth', 2); hold on;
    legend({strcat(how.splitBy{1}, '-Oz'), strcat(how.splitBy{2}, '-Oz')});
    title(strcat('OZ ', database));
    filename = fullfile(dirResFigures, strcat('OZ-', how.splitBy{1}, '&', how.splitBy{2}));
    saveas(gcf, filename, 'fig');
    close gcf;
    
    row = 5;
    col = 4;
    list_subj = list_folder(fullfile(rca_path.srcEEG, database));   

    for ns = 1:nSubj
       nStereo = cndNotStereo{ns};
       Stereo = cndStereo{ns};
       
       oz_nS = nanmean(squeeze(nStereo(:, 75, :)), 2);
       oz_S = nanmean(squeeze(Stereo(:, 75, :)), 2);
              
       subplot(row, col, ns);
       plot(oz_nS, 'r', 'Linewidth', 2); hold on;
       plot(oz_S, 'b', 'Linewidth', 2); hold on;
       legend({strcat(how.splitBy{1}, '-Oz'), strcat(how.splitBy{2}, '-Oz')});
       title(strcat('Subj ', list_subj(ns).name));
    end
    filename = fullfile(dirResFigures, strcat('Subjects OZ-', how.splitBy{1}, '&', how.splitBy{2}));
    saveas(gcf, filename, 'fig');
    
    close gcf;
end
