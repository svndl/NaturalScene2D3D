function maxDifference(nScenes)
database = 'Middlebury';
rca_path = rca_setPath;
dirResData = fullfile(rca_path.results_Data, database);
% describing splits
switch database
    case 'Live3D'
        how.allCnd = {'D', 'E'; 'D', 'O'; 'D', 'S'; 'E', 'D';'E', 'O'; 'E', 'S'; 'O', 'D'; 'O', 'E'; 'O', 'S'; 'S', 'D'; 'S', 'E'; 'S', 'O'};
        how.splitBy = {'O', 'S'};
        timeCourseLen = 660;
        row = 3;
        col = 4;
         how.nScenes = nScenes;
    case 'Middlebury'
        how.allCnd = {'E', 'O'; 'E', 'S'; 'O', 'E'; 'O', 'S'; 'S', 'E'; 'S', 'O'};
        how.splitBy = {'O', 'S'};
        how.nScenes = nScenes;
        timeCourseLen = 500;
        row = 5;
        col = 6;
    case 'Live3D_new'
        how.allCnd = {'O', 'S'; 'S', 'O'};
        how.splitBy = {'O', 'S'};
        timeCourseLen = 750;
        how.nScenes = nScenes;
        
        
    otherwise
end
cl = {'r', 'g', 'b', 'k'};
            
    %% load/calculate the RC data on a given dataset
    
    how.useCnd = how.allCnd;
    how.nSplits = 4;
    how.useSplits = [2, 4];
    how.baseline = 1;
    reuse = 1;
   
   if nScenes == 1
        dirResFigures = fullfile(rca_path.results_Figures, database, strcat('rcaProject', how.splitBy{:},'_bySubjects'));
        
    else
        dirResFigures = fullfile(rca_path.results_Figures, database, strcat('rcaProject', how.splitBy{:},'_byScenes'));
    end
    
    if (~exist(dirResFigures, 'dir'))
        mkdir(dirResFigures);
    end
    
    %% get RC weights    
    eegCND = rca_getData4RCA(database, how, reuse);

    maxDiff(eegCND(:, 1), eegCND(:, 2), how.splitBy, dirResData, timeCourseLen);
end   
    


function maxDiff(data1, data2, dataLabels, dirResData, timeCourseLen)
    
    nSubj = size(data1, 1);
    if (~iscell(data1))
        data1 = cell(data1);
    end
    
    if (~iscell(data2))
        data2 = cell(data2);
    end
        
    %get a nanmean
    
    catData1 = cat(3, data1{:});
    muData1 = nanmean(catData1, 3);
    semData1 = nanstd(catData1, [], 3)/sqrt(size(catData1, 3));   
    %semData1 = nanstd(catData1, [], 3)/sqrt(nSubj);   
    

    catData2 = cat(3, data2{:});
    muData2 = nanmean(catData2, 3);
    semData2 = nanstd(catData2, [], 3)/sqrt(size(catData2, 3));   
    %semData2 = nanstd(catData2, [], 3)/sqrt(nSubj);   
        
    [tmp1, tmp2, A, DD, WW] = calcMaxDiff(muData1, muData2);
    
    std_y1 = semData1*WW;
    std_y2 = semData2*WW;
    
    timeCourse = linspace(0, timeCourseLen, size(muData1, 1));
    
    %%%%%%% for plotting in R
%      dataframe2 = zeros(315,5); 
%      dataframe2(:,1:3) = [timeCourse',tmp1(:,1),std_y1(:,1)];
%      dataframe2(:,4:5) = [tmp2(:,1),std_y2(:,1)];
%      csvwrite(fullfile(dirResFigures,strcat('plot_maxDiff.csv')),dataframe2)           
%     
    %%%%%%%%%
    hf = figure;
    fullTitle = ['Difference between ' dataLabels{1} ' ' dataLabels{2}];
    title(fullTitle);
    nc = size(tmp1, 2);
    
   

    for c = 1:nc
        subplot(nc, 2, 2*c - 1);
        plot(timeCourse, tmp1(:, c), 'b', 'LineWidth', 2); hold on;
        h1 = shadedErrorBar(timeCourse,tmp1(:, c), std_y1(:, c), 'b');

        plot(timeCourse, tmp2(:, c), 'r', 'LineWidth', 2);        
        h2 = shadedErrorBar(timeCourse, tmp2(:, c), std_y2(:, c), 'r');
                
        legend([h1.patch h2.patch]', [dataLabels{:}]'); hold on;
        
        subplot(nc, 2, 2*c);
        plotOnEgi(A(:,c), [], 1);
    end
                                       
    saveas(hf, fullfile(dirResData, fullTitle), 'fig');
    figure;
    plot(DD, '*k');
end

function [y1, y2, A, DD, WW] = calcMaxDiff(d1, d2)
    
    diff = d1 - d2;
    c = cov(diff);
    
    c1 = cov(d1);
    c2 = cov(d2);
    cPool = (c1+c2)/2;

	% compute eigenvalues 
    [W, D] = eig(c);
    
    DD = diag(D);
       
    
    %% keep top three max-dif filters
    nc = 3;
    %WW = W;
    
    WW = W(:, end:-1:end - nc + 1);% W is already sorted. 
    A = cPool*WW*inv(WW'*cPool*WW);  % scalp projections of max-dif filters

    %% project onto data
    y1 = d1*WW;
    y2 = d2*WW;
end


