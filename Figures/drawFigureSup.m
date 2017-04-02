function drawFigureSup

baselineSample = 21; 
cl = {'b', 'r'};
nComp = 1; %which component to plot; 

nrow = 6; ncol = 5;


topFolder = '~/Dropbox/Research/4_IndividualDifferences/NaturalScene2D3D/results/data/Middlebury/StimuliChunk/2TrainedSeparatedly/byScene';
data = csvread(fullfile(topFolder,'inputForPermutationTest1.csv'));
for s = 1:size(data,1)
    d(s) = sqrt(data(s,:)*data(s,:)'); %distance to 0   
end
[x,subOrder] = sort(d,'descend');%This index is the index to be used to
    %extract largest to smallest from the original data matrix.

load(fullfile(topFolder,'Middleburydata4RCA_OS_byScenes.mat'));
eegCND=dataOut;
timeCourse = linspace(0, 500, size(eegCND{1, 1}, 1));

load(fullfile(topFolder,'rcaOnOS_byScenes.mat'));
load('~/Dropbox/Research/4_IndividualDifferences/NaturalScene2D3D/results/figures/Middlebury/StimuliChunk/2TrainedSeparatedly/byScene/subidx.mat');



tHotColMap = jmaColors('pval');
tHotColMap(end,:) = [1 1 1];
fontSize = 12;
lWidth =2;
gcaOpts = {'tickdir','out','box','off','fontsize',fontSize,'fontname','arial','linewidth',lWidth,'ticklength',[.025,.025]};


for sub = 1:size(data,1)
    
    for cn = 1:2
        [muData_C{sub,cn}, semData_C{sub,cn},out{sub,cn}] =natSc_ProjectmyData(eegCND(sub, cn), W{cn},baselineSample);
    end
    
    if size(out{sub,1},2) == size(out{sub,2},2)
    diffmat = out{sub,1}-out{sub,2};
    else
    commonTrial =  min(size(out{sub,1},2),size(out{sub,2},2));
    diffmat = out{sub,1}(:,1:commonTrial) - out{sub,2}(:,1:commonTrial);
    end
    [realT(:,sub),realP(:,sub),corrT(:,sub),critVal(:,sub),clustDistrib(:,sub)]= ttest_permute(diffmat,1000);
    
end


figure;
plotidx = 1;
for si = subOrder

    subplot(nrow, ncol,plotidx);
    
    hh(plotidx)=subplot(nrow,ncol,plotidx);hold on;
    ylim([-3e-5 3e-5])
    xlim([0 600])
    
    
    for cn = 1:2
        subplot(hh(plotidx));
        hs = shadedErrorBar(timeCourse, muData_C{si,cn}(:, nComp), semData_C{si,cn}(:, nComp), cl{cn}); hold on
        h{cn} = hs.patch;
        
    end
    title(subj_list(si), 'Interpreter', 'none');
    
    
    
    yLims = ylim;
    xLims = xlim;
    sigPos = min(yLims)+diff(yLims).*[0 .2];
    % sigPos is the lower and upper bound of the part of the plot were
    % plot your waveforms, put code for plotting your waveforms here
    % plot corrected t-values
    % find centroid of each "region" of corrected significance,
    % then put a * there
    
    meanResult = load(fullfile(topFolder,'permutationTestResults.mat')); 
    meanCritV = meanResult.critVal(1);%First component
    %Compare each individual result with the critical value derived from
    %the permutation test of the whole data set

    regionIdx = bwlabel(realT(:,si));
    for m=1:max(regionIdx)
        regionm = regionprops(regionIdx == m,'Area');
        if regionm.Area > meanCritV
        tmp = regionprops(regionIdx == m,'centroid');
        idx = round(tmp.Centroid(2));
        hTxt = text(timeCourse(idx),sigPos(2)-1e-6,'*','fontsize',12,'fontname','Arial','horizontalalignment','center','verticalalignment','top');
        end
    end
    
    % plot uncorrected t-values
    
    % you are coloring in the uncorrected t-values
    curP = repmat( realP(:,si)',20,1 );
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
    set(gca,'XTick',0:300:800);
    
    plotidx = plotidx+1;
end


set(gcf,'PaperPosition',[0 0 9 11])
 print('figureSup','-r300','-dpdf')


end