function natSc_plotSubjOZ(database,nScenes,split)

%This function plots the 2D vs 3D raw data from OZ (electrode 75), as well
%as individual profile of 2D vs 3D for each subject/scene


rca_path = rca_setPath;


switch database
    case 'Live3D'
        how.allCnd = {'D', 'E'; 'D', 'O'; 'D', 'S'; 'E', 'D';'E', 'O'; 'E', 'S'; 'O', 'D'; 'O', 'E'; 'O', 'S'; 'S', 'D'; 'S', 'E'; 'S', 'O'};
        %how.splitBy = {'D', 'E', 'O', 'S'};
        how.splitBy = {'O', 'S'};
        timeCourseLen = 660;
    case 'Middlebury'
        how.allCnd = {'E', 'O'; 'E', 'S'; 'O', 'E'; 'O', 'S'; 'S', 'E'; 'S', 'O'};
        how.splitBy = {'O', 'S'};
        timeCourseLen = 500;
    case 'Live3D_new'
        how.allCnd = {'O', 'S'; 'S', 'O'};
        how.splitBy = {'O', 'S'};
        timeCourseLen = 750;

    otherwise
end





how.useCnd = how.allCnd;
how.nSplits = 4;
how.useSplits = 1;
%how.useSplits = [2, 4];
how.baseline = 1;
how.nScenes = nScenes;
reuse = 1;


if how.useSplits == 2||how.useSplits == 4||all(how.useSplits == [2 4])
    
    dirResFol = fullfile(rca_path.results_Data, database,'StimuliChunk');
    dirFigF = fullfile(rca_path.results_Figures, database,'StimuliChunk');
else
    dirResFol = fullfile(rca_path.results_Data, database,'BlankChunk');
    dirFigF = fullfile(rca_path.results_Figures, database,'BlankChunk');
end
    


if split ==1
    dirResData = fullfile(dirResFol,[num2str(how.useSplits),'TrainedSeparatedly']);
    dirFigFol = fullfile(dirFigF, [num2str(how.useSplits),'TrainedSeparatedly']);
else
    dirResData = fullfile(dirResFol,[num2str(how.useSplits),'TrainedTogether']);
    dirFigFol = fullfile(dirFigF, [num2str(how.useSplits),'TrainedTogether']);
end




row = 5;
col = 6;



dirResFigures = fullfile(dirFigFol, 'Oz');

if (~exist(dirResFigures, 'dir'))
    mkdir(dirResFigures);
end



eegCND = natSc_getData4RCA(database, how, reuse);
close all;
nSubj = size(eegCND, 1);

cndNotStereo = eegCND(:, 1);
cndStereo = eegCND(:, 2);
timeCourse = linspace(0, timeCourseLen, size(eegCND{1, 1}, 1));
baselineSample = round(50/timeCourseLen*length(timeCourse)); %First 50 ms as the baseline
%baselining uisng the first n=baselineSample time samples



nS_all = cat(3, cndNotStereo{:});
S_all = cat(3, cndStereo{:});

%For plotting 2D vs 3D grand mean 
OZ_O_all_mean = nanmean(squeeze(nS_all(:, 75, :)), 2);
baseline = nanmean(OZ_O_all_mean(1:baselineSample,:),1);
OZ_O_all_mean_bs = OZ_O_all_mean - repmat(baseline, [size(OZ_O_all_mean, 1) 1]);
OZ_O_all_sem = nanstd(squeeze(nS_all(:, 75, :)),[], 2)/sqrt(size(squeeze(nS_all(:, 75, :)),2));
OZ_S_all_mean = nanmean(squeeze(S_all(:, 75, :)), 2);
baseline = nanmean(OZ_S_all_mean(1:baselineSample,:),1);
OZ_S_all_mean_bs = OZ_S_all_mean - repmat(baseline, [size(OZ_S_all_mean, 1) 1]);
OZ_S_all_sem = nanstd(squeeze(S_all(:, 75, :)),[], 2)/sqrt(size(squeeze(S_all(:, 75, :)),2));



p1 = shadedErrorBar(timeCourse, OZ_O_all_mean_bs, OZ_O_all_sem, 'r'); hold on
p2=shadedErrorBar(timeCourse, OZ_S_all_mean_bs, OZ_S_all_sem, 'g');

legend([p1.mainLine,p2.mainLine],{strcat(how.splitBy{1}, '-Oz'), strcat(how.splitBy{2}, '-Oz')});
title(strcat('OZ ', database,'2Dvs3D'));
filename = fullfile(dirResFigures, strcat('OZ-', how.splitBy{1}, '&', how.splitBy{2}));
saveas(gcf, filename, 'fig');

%%%%save data for plotting in R%%%%%

dataframe2 = zeros(length(timeCourse),5);

dataframe2(:,1:3) = [timeCourse',OZ_O_all_mean_bs,OZ_O_all_sem];

dataframe2(:,4:5) = [OZ_S_all_mean_bs,OZ_S_all_sem];

csvwrite(fullfile(dirResFigures,strcat('OZplot2Dvs3D.csv')),dataframe2);
%%%%s%%%%%

close gcf;



if nScenes == 1
    list_subj = list_folder(fullfile(rca_path.srcEEG, database));
    save('subidx','list_subj'); % for the plotting in R
end
dataframe = zeros(nSubj*length(timeCourse),6);

for ns = 1:nSubj
    startIdx = (ns-1)*length(timeCourse)+1;
    endIdx = ns*length(timeCourse);
    
    
    
    nStereo = cndNotStereo{ns};
    Stereo = cndStereo{ns};
    
    oz_nS_mean = nanmean(squeeze(nStereo(:, 75, :)), 2);
    baseline = nanmean(oz_nS_mean(1:baselineSample,:),1);
    
    oz_nS_mean_bs = oz_nS_mean - repmat(baseline, [size(oz_nS_mean, 1) 1]);
    oz_nS_sem = nanstd(squeeze(nStereo(:, 75, :)),[], 2)/sqrt(size(squeeze(nStereo(:, 75, :)),2));
    
    
    
    oz_S_mean = nanmean(squeeze(Stereo(:, 75, :)), 2);
    baseline = nanmean(oz_S_mean(1:baselineSample,:),1);
    
    oz_S_mean_bs = oz_S_mean - repmat(baseline, [size(oz_S_mean, 1) 1]);
    oz_S_sem = nanstd(squeeze(Stereo(:, 75, :)),[], 2)/sqrt(size(squeeze(Stereo(:, 75, :)),2));
    
    
    
    %%%%%%
    
    dataframe(startIdx:endIdx,1) = ns;
    
    dataframe(startIdx:endIdx,2:4) = [timeCourse',oz_nS_mean_bs,oz_nS_sem];
    dataframe(startIdx:endIdx,5:6) = [oz_S_mean_bs,oz_S_sem];
    
    
    %%%%%%
    
    subplot(row, col, ns);
    p1 = shadedErrorBar(timeCourse, oz_nS_mean_bs, oz_nS_sem, 'r'); hold on
    p2=shadedErrorBar(timeCourse, oz_S_mean_bs, oz_S_sem, 'g');
    

    
    legend([p1.mainLine,p2.mainLine],{strcat(how.splitBy{1}, '-Oz'), strcat(how.splitBy{2}, '-Oz')});
    if nScenes == 1
        
        
        title(strcat('Subj ', list_subj(ns).name));
    else
        title(strcat('Scene ', num2str(list_subj(ns))));
    end
end
filename = fullfile(dirResFigures, strcat('SubjectsOZ-', how.splitBy{1}, '&', how.splitBy{2}));
saveas(gcf, filename, 'fig');
csvwrite(fullfile(dirResFigures,strcat('OZplotData_',num2str(nScenes),'.csv')),dataframe);
close gcf;


end
