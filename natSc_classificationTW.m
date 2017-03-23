function natSc_classificationTW(database,by,how,stereo,classifier,tr2avg,nTW)
 %Do classification by different time windosw
 %Now hard coded specifically for Live3D_new dataset, where number of time
 %sample is 79, and number of electrode is 125. If nTW = 10, then there are
 %10 time windows, from 1-15, 8-22 etc.. If nTW=15, there are 15 time
 %windows, from 1-10, 6-15, etc..Accuracies will be inputed in R where
 %plotting is taken care of. 


%%%%%%%find out which dataset to load%%%%%%%

rca_path = rca_setPath;
dirResData = fullfile(rca_path.results_Data, database);

if strcomp(database,'Live3D') %Live3D dataset doesn't have scene labels.
    by = 'bySubjects';
end


%result directory
if strcomp(how,'2Dvs3D')
    
    dirClassRes = fullfile(dirResData,'classification/2Dvs3D');
    
else
    if stereo==1
        dirClassRes = fullfile(dirResData,'classification',by,'2D');
    elseif stereo ==2
        dirClassRes = fullfile(dirResData,'classification',by,'3D');
    else
        dirClassRes = fullfile(dirResData,'classification',by,'diff');
    end
    
end


dataDir = fullfile(dirClassRes,'DataDS.mat');
load(dataDir);
%%%%%%%finishing loading%%%%%%%


if nTW == 15; %number of time windows
    for i = 1:nTW
        idx = (i-1)*5+1: (i-1)*5+10
        nTimeSample = (size(xReadyForClassifier_withLabel,2)-1)/125;
        if any(idx>nTimeSample) %deal with index out of bound
            idx(idx>nTimeSample)=[];
        end
        
        idxVec = [];
        for j = 1:125
            idxVec = [idxVec idx+(j-1)*nTimeSample];
        end
        xTW = xReadyForClassifier_withLabel(:,[idxVec end]);
        if tr2avg >0
            rng(i);
            Data2Calssify = avgTrial(xTW,tr2avg);
        else
            Data2Calssify = xTW;
        end
        cd(dirClassRes)
        yLabel = Data2Calssify(:,end);
        classes = unique(yLabel);
        switch classifier
            case 'LDA'
                [~, accuracy{i}, ~] = LDAclassifyEEG(Data2Calssify(:,1:end-1),yLabel,200);
                if accuracy{i} <1, accuracy{i} = accuracy{i}*100; end
                pVal{i} = pValues(accuracy{i},length(classes),size(Data2Calssify,1));
                
                
            case 'SVM'
                [~, accuracy{i}, ~, ~] = SVM_Karen(Data2Calssify(:,1:end-1),yLabel);
                if accuracy{i} <1, accuracy{i} = accuracy{i}*100; end
                pVal{i} = pValues(accuracy{i},length(classes),size(Data2Calssify,1));
                
                
            otherwise
                
        end
    end
    
    
    
else
    for i = 1:nTW
        idx = (i-1)*7+1: (i-1)*7+15
        nTimeSample = (size(xReadyForClassifier_withLabel,2)-1)/125;
        if any(idx>nTimeSample) %deal with index out of bound
            idx(idx>nTimeSample)=[];
        end
        
        idxVec = [];
        for j = 1:125
            idxVec = [idxVec idx+(j-1)*nTimeSample];
        end
        xTW = xReadyForClassifier_withLabel(:,[idxVec end]);
        if tr2avg >0
            rng(i);
            Data2Calssify = avgTrial(xTW,tr2avg);
        else
            Data2Calssify = xTW;
        end
        
        cd(dirClassRes)
        yLabel = Data2Calssify(:,end);
        classes = unique(yLabel);
        switch classifier
            case 'LDA'
                [~, accuracy{i}, ~] = LDAclassifyEEG(Data2Calssify(:,1:end-1),yLabel,200);
                if accuracy{i} <1, accuracy{i} = accuracy{i}*100; end
                pVal{i} = pValues(accuracy{i},length(classes),size(Data2Calssify,1));
                
                
            case 'SVM'
                [~, accuracy{i}, ~, ~] = SVM_Karen(Data2Calssify(:,1:end-1),yLabel);
                if accuracy{i} <1, accuracy{i} = accuracy{i}*100; end
                pVal{i} = pValues(accuracy{i},length(classes),size(Data2Calssify,1));
                
                
            otherwise
                
        end
    end
    
    
end

save('TemporalAccuracy', 'accuracy','pVal');
end












