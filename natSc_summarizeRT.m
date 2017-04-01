function [meanAccuracy,meanRT] = natSc_summarizeRT(database)

%This function calculates mean accuracy and RT


natSc_path = natSc_setPath(database);
eegSrc = fullfile(natSc_path.srcEEG, database);

proj_dir = eegSrc;


list_subj = list_folder(proj_dir);


nsubj = numel(list_subj);

for s = 1:nsubj
    
    
    TrialCount = 0;
    RTcount = 0;
    correctCount = 0;
    if (list_subj(s).isdir)
        subjDir = fullfile(proj_dir,  list_subj(s).name);
        
        display(['Loading   ' list_subj(s).name]);
        RTsegFiles = dir2(fullfile(subjDir, 'RTSeg_*.mat'));
        
        for z = 1:numel(RTsegFiles)
            RTfile = fullfile(subjDir, RTsegFiles(z).name);
            load(RTfile); % load data
            nTrial = size(TimeLine, 1);
            if nTrial > 0;
                TrialCount = TrialCount + nTrial;
                RT = sum([TimeLine.respTimeSec]);
                RTcount = RTcount+RT;
                clear response;
                cond = [TimeLine.cndNmb]';
                response(cellfun(@(x) strcmp(x,'La'),{TimeLine.respString}'),:) = {2};
                response(cellfun(@(x) strcmp(x,'1'),{TimeLine.respString}'),:) = {2};
                response(cellfun(@(x) strcmp(x,'Ra'),{TimeLine.respString}'),:) = {1};
                response(cellfun(@(x) strcmp(x,'2'),{TimeLine.respString}'),:) = {1};
                response(cellfun(@(x) strcmp(x,'Mis'),{TimeLine.respString}'),:) = {0};
                nCorrect = sum([response{:}]' == cond);
                correctCount = correctCount+nCorrect;
            end
            
            
            
        end
        meanAccuracy(s) = correctCount/TrialCount;
        meanRT(s) = RTcount/TrialCount;
    end
end
end

