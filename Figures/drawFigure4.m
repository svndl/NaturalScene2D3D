function drawFigure4
nSubj = 24;
epochLengh=315;
baselineSample=21;
fontSize = 12;
lWidth =2;
gcaOpts = {'tickdir','out','box','off','fontsize',fontSize,'fontname','arial','linewidth',lWidth,'ticklength',[.025,.025]};
timeCourseLen = 750;
timeCourse = linspace(0, timeCourseLen, 315);
nComp = 3;
topFolder = '~/Dropbox/Research/4_IndividualDifferences/NaturalScene2D3D/results/data/Live3D_new/';
resultFolder = fullfile(topFolder,'StimuliChunk/2TrainedSeparatedly/bySubject');
cd(resultFolder);
%For Blank
%load the rca w for drawing blank chunk
load(fullfile(topFolder,'BlankChunk/1TrainedTogether/bySubject/rcaOnOS_bySubjects.mat'));
load(fullfile(topFolder,'BlankChunk/1TrainedTogether/bySubject/Live3D_newdata4RCA_OS_bySubjects.mat'));
for i=1:nSubj
    
    eegCND{i,1} = cat(3,dataOut{i,1},dataOut{i,2});
    
end

projOut = rcaProject(eegCND, W); 
if ~exist(fullfile(resultFolder,'2DvsBlankpermutationTestResults.mat'),'file')
    for nComp = 1:3
        
        blank{nComp} = cellfun(@(x) x(:,nComp,:),projOut, 'UniformOutput',false);
        blank{nComp} = cellfun(@squeeze, blank{nComp}, 'UniformOutput',false);
        blank_mean{nComp} = cellfun(@(x) nanmean(x,2),blank{nComp},'UniformOutput',false);
        datablank = reshape(cell2mat(blank_mean{nComp}),[315,nSubj]);      
        bl = nanmean(datablank(1:baselineSample,:),1);
        datablank_bs = datablank - repmat(bl,epochLengh,1);
        data2D = csvread(fullfile(resultFolder,strcat('2DRC',num2str(nComp),'.csv'))); 
        %This csv file is from R script: Figure4CSVfile.rmd,
        %nsubjXnTimeSample for 2D RC mean
        diffmat = data2D'-datablank_bs;
        [realT(:,nComp),realP(:,nComp),corrT(:,nComp),critVal(:,nComp),clustDistrib(:,nComp)]= ttest_permute(diffmat,10000);
    end
    save('2DvsBlankpermutationTestResults.mat','realT','realP','corrT','critVal','clustDistrib');
else
    load('2DvsBlankpermutationTestResults.mat')
end


%define colormap for plotting uncorrected p-values
tHotColMap = jmaColors('pval');
tHotColMap(end,:) = [1 1 1];
fontSize = 12;
lWidth =2;
gcaOpts = {'tickdir','out','box','off','fontsize',fontSize,'fontname','arial','linewidth',lWidth,'ticklength',[.025,.025]};

cl = {'r', 'b', 'g', 'k'};

close all;


%% run the projections, plot the topography
baselineSample = round(50/timeCourseLen*length(timeCourse)); %First 50 ms as the baseline

[muData_C, semData_C] = natSc_ProjectmyData(eegCND, W,baselineSample);
figure;

for c = 1:nComp
    
    hh(c)=subplot(3,1,c);
    ylim([-1.5e-5 2e-5])
    xlim([0 850])
    color_idx = 1;
    hs = shadedErrorBar(timeCourse, muData_C(:, c), semData_C(:, c), cl{color_idx}); hold on
    set(gca, gcaOpts{:});
    title(strcat('RC',num2str(c),  ' time course'), 'Interpreter', 'none');
end
%clear all;
%For 2D
%load the rca w for drawing blank chunk
load(fullfile(topFolder,'/StimuliChunk/2TrainedSeparatedly/bySubject/rcaOnOS_bySubjects.mat'));
load(fullfile(topFolder,'StimuliChunk/2TrainedSeparatedly/bySubject/Live3D_newdata4RCA_OS_bySubjects.mat'));
eegCND = dataOut(:,1);%2D condition
[muData_C, semData_C] = natSc_ProjectmyData(eegCND, W{1},baselineSample);

for c = 1:nComp
    
    subplot(3, 1, c);
    color_idx = 2;
    
    hs = shadedErrorBar(timeCourse, muData_C(:, c), semData_C(:, c), cl{color_idx}); hold on
    ylim([-1.5e-5 2e-5])
    xlim([0 850])
    set(gca, gcaOpts{:});
    
    
    
    yLims = ylim;
    xLims = xlim;
    sigPos = min(yLims)+diff(yLims).*[0 .06];
    % sigPos is the lower and upper bound of the part of the plot were
    % plot your waveforms, put code for plotting your waveforms here
    % plot corrected t-values
    % find centroid of each "region" of corrected significance,
    % then put a * there
    regionIdx = bwlabel(corrT(:,c));
    for m=1:max(regionIdx)
        tmp = regionprops(regionIdx == m,'centroid');
        idx = round(tmp.Centroid(2));
        hTxt = text(timeCourse(idx),sigPos(2)+(4e-7),'*','fontsize',18,'fontname','Arial','horizontalalignment','center','verticalalignment','top');
    end
    
    % plot uncorrected t-values
    
    % you are coloring in the uncorrected t-values
    curP = repmat( realP(:,c)',20,1 );
    hImg = image([min(timeCourse),max(timeCourse)],[sigPos(1),sigPos(2)], curP, 'CDataMapping', 'scaled','Parent',gca);
    colormap(gca,tHotColMap );
    cMapMax = .05+2*.05/(size(tHotColMap,1));
    set( gca, 'CLim', [ 0 cMapMax ] ); % set range for color scale
    set(gca, gcaOpts{:});
    uistack(hImg,'bottom')
    %     % replot the lines for x and y axes
    xlim(xLims)
    ylim(yLims)
    plot(ones(10,1)*xLims(1),linspace(yLims(1),yLims(2),10),'-k','linewidth',lWidth);
    plot(linspace(xLims(1),xLims(2),10),ones(10,1)*yLims(1),'-k','linewidth',lWidth);
   
end
set(gcf,'PaperPosition',[2 2 4.7 7.3])
print('figure4','-r300','-dpdf')

end