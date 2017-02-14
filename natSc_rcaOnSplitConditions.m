function natSc_rcaOnSplitConditions(nScenes)

%This function produce the first 3 RC components for 2D vs 3D conditions,
%and plot the topography.
%The RCA weights (W) were obtained from rca_run. The weights were used to
%project back to each individual space for each trial. (For example, for
%each individual, for 2D condition, there will be 240 trials. As there are
%21 participants, the total trials for 2D should be 21X240 = 5040. As in
%our experiment, one subject has 300 trials instead of 240, so the total
%trials is 5100.) Now average the projected RCA score over all the trials,
%this will give us the RCA component score over all subjects over all
%scenes.
%Note: I compared this method with first averging across all the trials and
%then do the RCA projection. The two methods yield same results.

%input nScenes should be 1. It is needed here because some functions depend
%on nScenes. Otherwise it is not meaningful.


database = 'Middlebury';
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
        
    case 'Test'
        how.allCnd = {'E', 'O'; 'E', 'S'; 'O', 'E'; 'O', 'S'; 'S', 'E'; 'S', 'O'};
        how.splitBy = {'O', 'S'};
        timeCourseLen = 500;
        how.nScenes = nScenes;
    otherwise
end


how.useCnd = how.allCnd;

how.nSplits = 4;
how.useSplits = [2, 4];
how.baseline = 0;
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
[rcaDataAll, W, A, ~, ~, ~, ~] = rcaRun(eegCND', nReg, nComp,2);
save(rcaFileAll, 'rcaDataAll', 'W', 'A');
else
    load(rcaFileAll);
end


%project on conditions
cl = {'r', 'g', 'b', 'k'};
%catDataAll = cat(3, rcaDataAll{:});
%muDataAll = nanmean(catDataAll, 3);

timeCourse = linspace(0, timeCourseLen, size(eegCND{1, 1}, 1));

close all;
nCnd = numel(how.splitBy);
h = cell(nCnd, 1);
%% run the projections, plot the topography
baselineSample = round(50/timeCourseLen*length(timeCourse)); %First 50 ms as the baseline

%R
dataframe2 = zeros(length(timeCourse),5);
%   %save mean and se to dataframe for the purpose of plotting in R.


for c = 1:nComp
    
    subplot(nComp, 2, 2*c - 1);
    color_idx = 1;
    
    %R
    startIdx = 1;
    endIdx = length(timeCourse);
    %R
    
    for cn = nCnd:-1:1
        [muData_C, semData_C] = natSc_ProjectmyData(eegCND(:, cn), W,baselineSample);
        %[muData_C, semData_C] = natSc_ProjectmyData(eegCND(:, cn), W);
        
        %Rfor plotting in R
        if cn ==1
            dataframe2(startIdx:endIdx,1:3) = [timeCourse',muData_C(:,1),semData_C(:,1)];
            
        else
            dataframe2(startIdx:endIdx,4:5) = [muData_C(:,1),semData_C(:,1)];
        end
        %R
        
        hs = shadedErrorBar(timeCourse, muData_C(:, c), semData_C(:, c), cl{color_idx}); hold on
        h{cn} = hs.patch;
        color_idx = color_idx + 1;
    end
    legend([h{end:-1:1}], [how.splitBy{end:-1:1}]'); hold on;
    title(['RC' num2str(c) ' time course']);
    subplot(nComp, 2, 2*c);
    mrC.plotOnEgi(A(:,c)); hold on;
end

%R
csvwrite(fullfile(dirResFigures,strcat('plot2Dvs3DRCA.csv')),dataframe2);
%R

saveas(gcf, fullfile(dirResFigures, strcat('rcaProject_', how.splitBy{:})), 'fig');
close(gcf);
end