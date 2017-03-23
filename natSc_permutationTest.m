cd('~/Dropbox/Research/4_IndividualDifferences/rcaNatScenes/results/data/Live3D_new/StimuliChunk/2TrainedSeparatedly')

if ~exist('permutationTestResults.mat','file')
    for nComp = 1
        
        data = csvread(strcat('inputForPermutationTest',num2str(nComp),'.csv'));
        %21X315, subject by time, should be tranposed into timeXsubject
        [realT(:,nComp),realP(:,nComp),corrT(:,nComp),critVal(:,nComp),clustDistrib(:,nComp)]= ttest_permute(data',10000); 
    end
    save('permutationTestResults.mat')
else
    load('permutationTestResults.mat')
end

%define colormap for plotting uncorrected p-values 
tHotColMap = jmaColors('pval'); 
tHotColMap(end,:) = [1 1 1]; 
fontSize = 12; 
lWidth =2; 
nCnd=2;

gcaOpts = {'tickdir','out','box','off','fontsize',fontSize,'fontname','arial','linewidth',lWidth,'ticklength',[.025,.025]};
%load('~/Dropbox/Research/4_IndividualDifferences/rcaNatScenes/results/data/Live3D_new/Live3D_newdata4RCA_OS_bySubjects.mat');
load('~/Dropbox/Research/4_IndividualDifferences/rcaNatScenes/results/data/Live3D_new/Live3D_newdata4RCA_OS_byScenes.mat');

eegCND=dataOut;
%load('~/Dropbox/Research/4_IndividualDifferences/rcaNatScenes/results/data/Live3D_new/StimuliChunk/2TrainedSeparatedly/rcaOnOS_bySubjects.mat')
load('~/Dropbox/Research/4_IndividualDifferences/rcaNatScenes/results/data/Live3D_new/StimuliChunk/2TrainedSeparatedly/rcaOnOS_byScenes.mat')

baselineSample = 21;  how.splitBy = {'O', 'S'};
cl = {'b', 'r', 'g', 'k'};
timeCourse = linspace(0, 750, size(eegCND{1, 1}, 1));

 for cn = 1:2 
     [muData_C{cn}, semData_C{cn}] =natSc_ProjectmyData(eegCND(:, cn), W{cn},baselineSample); 
 end
figure;
%this code assumes that you are trying to plot 3 different subplots each with different data
for z=1:3
    hh(z)=subplot(3,1,z);
    ylim([-6e-6 1e-5])
    xlim([0 850])
    hold on
     
        for cn = 1:2
            subplot(hh(z));
            hs = shadedErrorBar(timeCourse, muData_C{cn}(:, z), semData_C{cn}(:, z), cl{cn}); hold on
            h{cn} = hs.patch;
        
        end
            title([subj_list(si) ' time course'], 'Interpreter', 'none');
            
      
        legend([h{1:2}], {'2D','3D'}'); hold on;

        yLims = ylim;
        xLims = xlim;
      sigPos = min(yLims)+diff(yLims).*[0 .06];
    % sigPos is the lower and upper bound of the part of the plot were  
    % plot your waveforms, put code for plotting your waveforms here
    % plot corrected t-values
    % find centroid of each "region" of corrected significance,
    % then put a * there
    regionIdx = bwlabel(corrT(:,z));
    for m=1:max(regionIdx)
        tmp = regionprops(regionIdx == m,'centroid');
        idx = round(tmp.Centroid(2));
        hTxt = text(timeCourse(idx),sigPos(2)+(2e-7),'*','fontsize',18,'fontname','Arial','horizontalalignment','center','verticalalignment','top');
    end
    
    % plot uncorrected t-values
    
    % you are coloring in the uncorrected t-values
    curP = repmat( realP(:,z)',20,1 );
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
set(gcf,'PaperPosition',[.25 0.25 6 11])
print('figure3','-r300','-dpdf')