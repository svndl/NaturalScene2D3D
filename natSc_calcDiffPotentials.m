function natSc_calcDiffPotentials(database,by)

rca_path = rca_setPath;
dataFile = fullfile(rca_path.rcaEEG, strcat(database,'_rcaReadyEEG_',by,'.mat'));
dirClassRes = fullfile(rca_path.results_Data, database,'classification',by,'diff');
if (~exist(dirClassRes, 'dir'))
    mkdir(dirClassRes);
end

end