function natSc_rcaOnSplitConditions(database,nScenes,epoch,split)

%This function produce the first 3 RC components for 2D vs 3D conditions,
%and plot the topography.
%If split == 1, RCA is trained on separate conditions (e.g 2D data alone or
%3D data alone).
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
how.useSplits = epoch;
how.baseline = 0;
how.split = split;
reuse = 1;

natSc_path = natSc_setPath(database,how);
dirResData = natSc_path.results_Data;
dirResFigures = natSc_path.results_Figures;

if (~exist(dirResFigures, 'dir'))
    mkdir(dirResFigures);
end

eegCND = natSc_getData4RCA(database, how, reuse);

%run on everything
nReg = 6;
nComp = 3;

if nScenes ==1
    rcaFileAll = fullfile(dirResData, strcat('rcaOn', how.splitBy{:},'_bySubjects.mat'));
else
    rcaFileAll = fullfile(dirResData, strcat('rcaOn', how.splitBy{:},'_byScenes.mat'));
end



if split ==0
    
    
    if(~exist(rcaFileAll, 'file'))
        [rcaDataAll,W,A,~,~,~,dGen,~] = rcaRun(eegCND', nReg, nComp);
        save(rcaFileAll, 'W', 'A','rcaDataAll','dGen');
    else
        h = msgbox('Make sure the RCA A and W polarity are correct!');
        load(rcaFileAll);
    end
    
    
else
    if(~exist(rcaFileAll, 'file'))
        nCND = size(eegCND,2);
        for nc = 1:nCND
            
            [rcaDataAll{nc}, W{nc}, A{nc}, ~, ~, ~, dGen{nc},~] = rcaRun(eegCND', nReg, nComp,nc,[],[],'orig');
        end
        save(rcaFileAll, 'W', 'A','rcaDataAll','dGen');
        
    else
        h = msgbox('Make sure the RCA A and W polarity are correct!');
        load(rcaFileAll);
    end
    
  
end


%project on conditions
cl = {'r', 'g', 'b', 'k'};


timeCourse = linspace(0, timeCourseLen, size(eegCND{1, 1}, 1));

close all;
nCnd = numel(how.splitBy);
h = cell(nCnd, 1);
%% run the projections, plot the topography
baselineSample = round(50/timeCourseLen*length(timeCourse)); %First 50 ms as the baseline



if split ==0
    
    
    for c = 1:nComp
        
        subplot(nComp, 2, 2*(c) - 1);
        color_idx = 1;
        
        dataframe2 = zeros(length(timeCourse),5);
        for cn = nCnd:-1:1
            [muData_C, semData_C] = natSc_ProjectmyData(eegCND(:, cn), W,baselineSample);
            
            %Rfor plotting in R
            
            if cn ==1
                dataframe2(:,1:3) = [timeCourse',muData_C(:,c),semData_C(:,c)];
                
            else
                dataframe2(:,4:5) = [muData_C(:,c),semData_C(:,c)];
            end
            
            
            %R
            
            hs = shadedErrorBar(timeCourse, muData_C(:, c), semData_C(:, c), cl{color_idx}); hold on
            h{cn} = hs.patch;
            color_idx = color_idx + 1;
        end
        csvwrite(fullfile(dirResFigures,strcat('plot2Dvs3DRCA_TrainedTogether_RC',num2str(c),'.csv')),dataframe2);
        legend([h{end:-1:1}], [how.splitBy{end:-1:1}]'); hold on;
        title(['RC' num2str(c) ' time course']);
        subplot(nComp, 2, 2*c);
        mrC.plotOnEgi(A(:,c)); hold on;
    end
    
    saveas(gcf, fullfile(dirResFigures, strcat('rcaProject_', how.splitBy{:})), 'fig');
    close(gcf);
    
    
else
    
    for c = 1:nComp
        
        hh = subplot(nComp, 3, 3*(c-1) + 1);
        color_idx = 1;
        
        dataframe2 = zeros(length(timeCourse),5);
        for cn = nCnd:-1:1
            [muData_C, semData_C] = natSc_ProjectmyData(eegCND(:, cn), W{cn},baselineSample);
            
            %Rfor plotting in R
            
            if cn ==1
                dataframe2(:,1:3) = [timeCourse',muData_C(:,c),semData_C(:,c)];
                
            else
                dataframe2(:,4:5) = [muData_C(:,c),semData_C(:,c)];
            end
            
            
            %R
            subplot(hh);
            hs = shadedErrorBar(timeCourse, muData_C(:, c), semData_C(:, c), cl{color_idx}); hold on
            h{cn} = hs.patch;
            color_idx = color_idx + 1;
            title(['RC' num2str(c),'Time Course']);
            
            subplot(nComp, 3, 3*c -2+cn );
            mrC.plotOnEgi(A{cn}(:,c)); hold on;
            colorbar;
            title(['RC' num2str(c),':',num2str(cn+1),'D']);
        end
        csvwrite(fullfile(dirResFigures,strcat('plot2Dvs3DRCA_RC',num2str(c),'.csv')),dataframe2);
        legend([h{end:-1:1}], [how.splitBy{end:-1:1}]'); hold on;
        
        
        
    end
    
    saveas(gcf, fullfile(dirResFigures, strcat('rcaProject_', how.splitBy{:})), 'fig');
    close(gcf);
       
    
end
end