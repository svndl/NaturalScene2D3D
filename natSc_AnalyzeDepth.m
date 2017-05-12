function [rangeD, varD, meanD,medianD] = AnalyzeDepth

    img_dir = uigetdir(filesep, 'Select the directory with images');
%     savedir = uigetdir(filesep, 'Select the directory to save the results');
    ListOfScenes = dir2(img_dir);
    ListOfScenes=ListOfScenes(~ismember({ListOfScenes.name},{'.','..','.DS_Store'}));
    nScenes  = numel(ListOfScenes);
    
%     q = zeros(nScenes, 5);
    meanD = zeros(nScenes, 1);
    rangeD = zeros(nScenes, 1);
    varD = zeros(nScenes, 1);
    medianD = zeros(nScenes, 1);
    dMin = 0;
    for s = 1:nScenes   
        [~ ,number] = strtok(ListOfScenes(s).name, '_');
        depthName = ['lRange' number(2:end) '.mat'];
        depth = load(fullfile(img_dir, ListOfScenes(s).name, depthName));        
        validPoints = depth.range.*(~isnan(depth.range));

%         dMax = max(validPoints(:));
%         validPoints(validPoints < 0) = dMax;
%         normDepth = (validPoints - dMin)./(dMax - dMin);
        
        rangeD(s) = range(validPoints(:));
        varD(s) = var(validPoints(:));
        meanD(s) = mean(validPoints(:));
        medianD(s) = median(validPoints(:));
%         q(s, :) = quantile(normDepth(:) ,[.025 .25 .50 .75 .975]); 
%         
%         f = figure;
%         subplot(2, 1, 1), hist(normDepth(:), 5);
%         title(ListOfScenes(s).name, 'Interpreter', 'None');
%         subplot(2, 1, 2), imshow(normDepth), colorbar;        
%         saveas(f, [savedir filesep ListOfScenes(s).name], 'png');
%         close gcf;
    end
%     f = figure;
%     subplot(5, 1, 1), bar(q(1:20, :)), title('ut000 - ut020'), legend({ '2.5%', '25%', '50%', '75%', '97.5%'});
%     subplot(5, 1, 2), bar(q(21:40, :)); title('ut021- ut040'), ylim([0, 1]);
%     subplot(5, 1, 3), bar(q(41:60, :)); title('ut041 - ut060'), ylim([0, 1]);
%     subplot(5, 1, 4), bar(q(61:80, :)); title('ut061 - ut080'), ylim([0, 1]);
%     subplot(5, 1, 5), bar(q(81:end, :)); title('ut081 - ut098'), ylim([0, 1]);
%     saveas(f, [savedir filesep 'DepthStatsByScene'], 'png');
%     saveas(f, [savedir filesep 'DepthStatsByScene'], 'fig');    
%     close gcf;
end 

% function out = norm2D(M, min, max)
%     minM = min(M(:));
%     maxM = max(M(:));
%     out = (M - minM)./(maxM - minM);
% end
