function drawFigure7

%summary figure to plot Scrambled, 2D, and 3D waveforms on top of each
%other


fontSize = 12;
lWidth =2;
gcaOpts = {'tickdir','out','box','off','fontsize',fontSize,'fontname','arial','linewidth',lWidth,'ticklength',[.025,.025]};

timeCourseLen = 750;

timeCourse = linspace(0, timeCourseLen, 315);

nComp = 3;
cl = {'r','g','b'};


%For Blank
%load the rca w for drawing blank chunk
load('~/Dropbox/Research/4_IndividualDifferences/NaturalScene2D3D/results/data/Live3D_new/BlankChunk/1TrainedTogether/bySubject/rcaOnOS_bySubjects.mat');
load('~/Dropbox/Research/4_IndividualDifferences/NaturalScene2D3D/results/data/Live3D_new/BlankChunk/1TrainedTogether/bySubject/Live3D_newdata4RCA_OS_bySubjects.mat');
for i=1:size(dataOut,1)
    
    eegCND{i,1} = cat(3,dataOut{i,1},dataOut{i,2});
    
end

% projOut = rcaProject(eegCND, W);
% if ~exist('3DvsBlankpermutationTestResults.mat','file')
%     for nComp = 1:3
%         
%         blank{nComp} = cellfun(@(x) x(:,nComp,:),projOut, 'UniformOutput',false);
%         blank{nComp} = cellfun(@squeeze, blank{nComp}, 'UniformOutput',false);
%         blank_mean{nComp} = cellfun(@(x) nanmean(x,2),blank{nComp},'UniformOutput',false);
%         datablank = reshape(cell2mat(blank_mean{nComp}),[315,21]);      
%         bl = nanmean(datablank(1:21,:),1);
%         datablank_bs = datablank - repmat(bl,315,1);
%         data3D = csvread(fullfile('~/Dropbox/Research/4_IndividualDifferences/NaturalScene2D3D/results/data/Live3D_new/StimuliChunk/2TrainedSeparatedly',strcat('3DRC',num2str(nComp),'.csv')));
%         
%         
%         diffmat = data3D'-datablank_bs;
%         [realT(:,nComp),realP(:,nComp),corrT(:,nComp),critVal(:,nComp),clustDistrib(:,nComp)]= ttest_permute(diffmat,10000);
%     end
%     save('3DvsBlankpermutationTestResults.mat','realT','realP','corrT','critVal','clustDistrib');
% else
%     load('3DvsBlankpermutationTestResults.mat')
% end



%% run the projections, plot the topography
baselineSample = round(50/timeCourseLen*length(timeCourse)); %First 50 ms as the baseline

[muData_C, semData_C] = natSc_ProjectmyData(eegCND, W,baselineSample);
figure;

for c = 1:nComp
    
    hh(c)=subplot(3,1,c);
    ylim([-10e-6 15e-6])
    xlim([0 850])
    color_idx = 2;
    hs = shadedErrorBar(timeCourse, muData_C(:, c), semData_C(:, c), cl{color_idx}); hold on
    h{1} = hs.patch;
    set(gca, gcaOpts{:});
    title(strcat('RC',num2str(c),  ' time course'), 'Interpreter', 'none');
end

%For 2D and 3D
%load the rca w for drawing 2D and 3D
load('~/Dropbox/Research/4_IndividualDifferences/NaturalScene2D3D/results/data/Live3D_new/StimuliChunk/2TrainedSeparatedly/bySubject/rcaOnOS_bySubjects.mat');
load('~/Dropbox/Research/4_IndividualDifferences/NaturalScene2D3D/results/data/Live3D_new/StimuliChunk/2TrainedSeparatedly/bySubject/Live3D_newdata4RCA_OS_bySubjects.mat')
eegCND = dataOut(:,1);%2D

[muData_C, semData_C] = natSc_ProjectmyData(eegCND, W{1},baselineSample);

for c = 1:nComp
    
    subplot(3, 1, c);
    color_idx = 3;
    
    hs= shadedErrorBar(timeCourse, muData_C(:, c), semData_C(:, c), cl{color_idx}); hold on
    h{2} = hs.patch;
    ylim([-10e-6 15e-6])
    xlim([0 850])
    set(gca, gcaOpts{:});
    
    
    
    yLims = ylim;
    xLims = xlim;
end



eegCND = dataOut(:,2);%3D
[muData_C, semData_C] = natSc_ProjectmyData(eegCND, W{2},baselineSample);

for c = 1:nComp
    
    subplot(3, 1, c);
    color_idx = 1;
    
    hs = shadedErrorBar(timeCourse, muData_C(:, c), semData_C(:, c), cl{color_idx}); hold on
    h{3} = hs.patch;
    ylim([-10e-6 15e-6])
    xlim([0 850])
    set(gca, gcaOpts{:});
    
    
    
    yLims = ylim;
    xLims = xlim;

    %     % replot the lines for x and y axes
    xlim(xLims)
    ylim(yLims)
    plot(ones(10,1)*xLims(1),linspace(yLims(1),yLims(2),10),'-k','linewidth',lWidth);
    plot(linspace(xLims(1),xLims(2),10),ones(10,1)*yLims(1),'-k','linewidth',lWidth);
     
    
end
legend([h{1:3}],'Scrambled','2D','3D');
set(gcf,'PaperPosition',[2 2 4 7.3])
print('figure8','-r300','-dpdf')

end