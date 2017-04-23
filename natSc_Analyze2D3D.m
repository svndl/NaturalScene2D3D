function natSc_Analyze2D3D(database,nScenes,epoch,split)

% Function written for NaturalScene2D3D project
% For RCA analysis of 2D and 3D natural images across individuals or scenes
% The function does the following
% 1. rearrange the raw trials into correct format to feed in rca_run
% 2. do rca_run, either based on subjects, or scenes.
% 3. Project the rca weights back into individual subject/scene space
% 4. The following output will be saved as a result of this function
%       1. figures: rcaProject_onSubjOS.fig (individual subject/scene plot)
%          plotData_1.csv or plotData_30.csv is for same visualization in R
%       2. rcaOnOS_bySubjects.mat: contains A and W (both are 128X3 double)
%       3. dataRCA_OS_bySubjects:contains dataOut,This is specifically for
% this project, a cell array subjectXcondition, within each cell,
% timeSample(315)XchannelsXTrials
%       4. rcaEEG: rcaDataOut: contains subjectXcondition cell array,
%       this is the general data structure directly extracted from raw trials. within each cell,
%       timeSample(1260)XchannelXtrials
%
%  Dependencies: https://github.com/svndl/rcaBase
%


% Inputs
%database: string, the name of the database folder
%nScenes: optional, By default, nScenes = 1, function analyzes individual subjects
%if nScenes > 1, it should be set as the number of scenes to be analyzed, and the function analyzes individual scenes
%%If split == 1, RCA is trained on separate conditions (e.g 2D data alone or
%3D data alone).
%epoch: defines which epoch to analyze, can be 1, 2 , 3 ,4, or [1 3], [2
%4], where 1 3 are epoches for scrambled image, 2 4 are epochs for 2D/3D
%images


if nargin<4 || isempty(split), split = 0; end
if nargin<3 || isempty(nScenes), nScenes = 1; end
if nargin<2 , error('must specify which epoch to analyze'); end
if nargin<1 , error('must specify which database to analyze'); end




% describing how to divide raw trials
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


%% organizing folder

how.useCnd = how.allCnd;
how.nSplits = 4;
how.useSplits = epoch;
how.baseline = 0;
how.split = split;
reuse = 1;

natSc_path = natSc_setPath(database,how);
dirResData = natSc_path.results_Data;
dirResFigures = natSc_path.results_Figures;




cl = {'r', 'g', 'b', 'k'};
row = input('Number of rows for the figure of individual subject/scene: ');
col = input('Number of columns for the figure of individual subject/scene: ');


%% get RC weights
eegCND = natSc_getData4RCA(database, how, reuse);

nReg = 6; %Regularize the matrix to the first 6 component, where the elbow is in the eigen value spectrum. See page 5 of "Cortical Components of Reaction-Time during Perceptual Decisions in Humans"
nComp = 3; %Analyze the first 3 components

if nScenes ==1
    
    rcaFileAll = fullfile(dirResData, strcat('rcaOn', how.splitBy{:}, '_bySubjects.mat'));
    
else
    rcaFileAll = fullfile(dirResData, strcat('rcaOn', how.splitBy{:}, '_byScenes.mat'));
end

%Main function to get the RCA weights, rcaOnOS_bySubjects.mat or
%rcaOnOS_byScenes.mat will be used in other analysis

if split ==0
    
    
    if(~exist(rcaFileAll, 'file'))
        [rcaDataAll,W,A,~,~,~,dGen,~] = rcaRun(eegCND', nReg, nComp);
        save(rcaFileAll, 'W', 'A','rcaDataAll','dGen');
    else
        load(rcaFileAll);
    end
    
    
else
    if(~exist(rcaFileAll, 'file'))
        nCND = size(eegCND,2);
        for nc = 1:nCND
            
            [rcaDataAll{nc}, W{nc}, A{nc}, ~, ~, ~, dGen{nc},~] = rcaRun(eegCND', nReg, nComp,nc);
        end
        save(rcaFileAll, 'W', 'A','rcaDataAll','dGen');
        
    else
        load(rcaFileAll);
    end
    
    
end





%% Run rca project for each subject / each scene

timeCourse = linspace(0, timeCourseLen, size(eegCND{1, 1}, 1));
nCnd = numel(how.splitBy);

%Specify which component to visualize
rcComp = input('Component to visualize: ');

% load subjects

%%%%%%%%%%%%%%%%save data as .csv For plotting In R%%%%%%%%%%%%%%%%

nSubj = size(eegCND,1);
if (~exist(fullfile(natSc_path.results_Figures,'subidx.mat'), 'file'))
    dirEEG = list_folder(fullfile(natSc_path.srcEEG, database));
    subj_list = {dirEEG.name};
    subj_list = subj_list([dirEEG.isdir]);
    save(fullfile(natSc_path.results_Figures,'subidx.mat'),'subj_list'); % for the plotting in R
else
    load(fullfile(natSc_path.results_Figures,'subidx.mat'));
end
baselineSample = round(50/timeCourseLen*length(timeCourse)); %First 50 ms as the baseline







if epoch ==1
    for sub = 1:size(eegCND,1)
        
        eegCND_combined{sub,1} = cat(3,eegCND{sub,1},eegCND{sub,2});
        
    end
    dataframe = zeros(nSubj*length(timeCourse),4);%time, subject, 2D mean, 2D sem
    close all;
    
    for si = 1:nSubj
        subplot(row, col, si);
        color_idx = 1;
        startIdx = (si-1)*length(timeCourse)+1; %for recording subject number in the dataframe for .csv file
        endIdx = si*length(timeCourse);
        
        [muData_C, semData_C] = natSc_ProjectmyData(eegCND_combined(si, 1), W,baselineSample);
        
        
        %%%%%%%%%%%%%%%% For plotting In R%%%%%%%%%%%%%%%%
        
        
        dataframe(startIdx:endIdx,1) = si;
        
        dataframe(startIdx:endIdx,2:4) = [timeCourse',muData_C(:,rcComp),semData_C(:,rcComp)];
        
        
        %%%%%%%%%%%%%%%% For plotting In R%%%%%%%%%%%%%%%%
        
        hs = shadedErrorBar(timeCourse, muData_C(:, rcComp), semData_C(:, rcComp), cl{color_idx}); hold on
        
        if nScenes ==1
            title([subj_list(si) ' time course'], 'Interpreter', 'none');
        else
            title([num2str(si) ' time course'], 'Interpreter', 'none');
        end
        
        
    end
    hold on;
    
    
else
    dataframe = zeros(nSubj*length(timeCourse),6);
    %save mean and se to dataframe for the purpose of plotting in R.
    %Columns are: time, subject, 2D mean, 2D sem, 3D mean, 3D sem.
    
    
    close all;
    
    for si = 1:nSubj
        subplot(row, col, si);
        color_idx = 1;
        startIdx = (si-1)*length(timeCourse)+1; %for recording subject number in the dataframe for .csv file
        endIdx = si*length(timeCourse);
        for cn = 1:nCnd
            
            if split == 1
                [muData_C, semData_C] = natSc_ProjectmyData(eegCND(si, cn), W{cn},baselineSample);
            else
                [muData_C, semData_C] = natSc_ProjectmyData(eegCND(si, cn), W,baselineSample);
            end
            
            %%%%%%%%%%%%%%%% For plotting In R%%%%%%%%%%%%%%%%
            
            if cn ==1
                dataframe(startIdx:endIdx,1) = si;
                
                dataframe(startIdx:endIdx,2:4) = [timeCourse',muData_C(:,rcComp),semData_C(:,rcComp)];
                
            else
                dataframe(startIdx:endIdx,5:6) = [muData_C(:,rcComp),semData_C(:,rcComp)];
            end
            %%%%%%%%%%%%%%%% For plotting In R%%%%%%%%%%%%%%%%
            
            hs = shadedErrorBar(timeCourse, muData_C(:, rcComp), semData_C(:, rcComp), cl{color_idx}); hold on
            h{cn} = hs.patch;
            color_idx = color_idx + 1;
        end
        legend([h{end:-1:1}], [how.splitBy{end:-1:1}]'); hold on;
        
        if nScenes ==1
            title([subj_list(si) ' time course'], 'Interpreter', 'none');
        else
            title([num2str(si) ' time course'], 'Interpreter', 'none');
        end
    end
    
end
csvwrite(fullfile(dirResFigures,strcat('plotData_RC',num2str(rcComp),'.csv')),dataframe);
saveas(gcf, fullfile(dirResFigures, strcat('rcaProject_onSubj', how.splitBy{:})), 'fig');
h = msgbox('Warning: do not forget to flip RCA A and W to the correct polarity, and rerun this script, so that plotData_RCx.csv is correct');
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



