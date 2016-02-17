function rcaRankOrderList

    %rcaprojects the scenes on 3D and 2D, then ranks them max diff to min
    %diff and creates combined img/depth maps
    
    database = 'Middlebury';
    rca_path = rca_setPath;
    dirResData = fullfile(rca_path.results_Data, database);
    split_by = {'S', 'O'};
    load(fullfile(dirResData, strcat('rcaProject_', split_by{:}, 'MaxDiff.mat')), 'rcaMaxDiffC12');
    dirResFigures = fullfile(rca_path.results_Figures, database);
   
    
    %% now load scenes and depth maps
    rc1ScenesSO = rcaMaxDiffC12(:, 1);
    
    mpath = main_setPath_Model; 
    exp_type = 'vep';
   [img, ~] = main_getRatedScenes(exp_type);
    
    %% sort the rankings and make the list for scenes
%     
%     %%make a 5x6 matrix with images and depth maps according to the rca
%     %%rankings
%       
    [sorted_lst, idx] = sort(rc1ScenesSO(:, 1));
    sorted_names = img.names(idx);
    downsample = 400;
    
    close all;
    
    plot(1:30, sorted_lst, 'ro', 'MarkerSize', 10, 'MarkerEdgeColor','k','MarkerFaceColor',[.49 1 .63]);
    xlabel('Scenes, max difference to min difference');
    ylabel('Difference between Streo-Original RC1 component');
    
    nScenes = numel(sorted_names);
    img_snippet = cell(nScenes, 1);
    depth_snippet = cell(nScenes, 1);    
    
    
    range = (min(sorted_lst) - max(sorted_lst))/nScenes;
    for i = 1:nScenes
        strVal = [sorted_names{i} ' Difference = ' num2str(sorted_lst(i))];
        text(25, max(sorted_lst) + range*i, strVal, 'FontSize', 10, 'Interpreter', 'none');
        
        %resize and crop
        resized_im = imresize(img.orig{idx(i)}, [downsample, NaN]);
        resized_depth = imresize(img.depthmap{idx(i)}, [downsample, NaN]);
        img_snippet{i} = (resized_im(:, 1:downsample, :)).^(1/2.2);
        depth_snippet{i} = normValue2D((resized_depth(:, 1:downsample)).^(1/2.2));
    
    end
    filename = fullfile(dirResFigures, 'Scenes ranked by RC1 Stereo-Orig difference');
    saveas(gcf, filename, 'fig'); 
    close gcf;
    
    ncols = 5;
    nrows = 6;
    img_r = cell(nrows, 1);
    depth_r = cell(nrows, 1);
    for r = 1:nrows
        start_idx = ncols*(r - 1) + 1;
        end_idx =  ncols*r;
        img_r{r} = cat(2, img_snippet{start_idx:end_idx});
        depth_r{r} = cat(2, depth_snippet{start_idx:end_idx});
    end
    
    img_ranked = cat(1, img_r{1:end});
    depth_ranked = cat(1, depth_r{1:end});
    
    imwrite(img_ranked, fullfile(dirResFigures, 'mb_RC1_ordered_imgs'), 'png'); 
    imwrite(depth_ranked, fullfile(dirResFigures, 'mb_RC1_ordered_dmaps'), 'png'); 
    
    
%     %% do the subject ranking
%     try
%         load(fullfile(dirResData, 'rcaProject_SO_MaxDiff_Subj.mat'));
%         load(fullfile(dirResData, 'rcaProject_SE_MaxDiff_Subj.mat'));
%         load(fullfile(dirResData, 'rcaProject_EO_MaxDiff_Subj.mat'));
%     catch
%     end
%     close all;
%     
%     nSubj = size(rcaMaxDiffC32, 1);
%     list_subj = list_folder(fullfile(rca_path.srcEEG, database));
%     [sorted_lst, idx] = sort(rcaMaxDiffC32(:, 2)); % SO list
% 
%     plot(1:nSubj, sorted_lst, 'bo', 'MarkerSize', 10, 'MarkerEdgeColor','k','MarkerFaceColor',[.15 .15 .75]);
%     xlabel('Subject, max difference to min difference');
%     ylabel('Difference between Streo-Original RC1 component within subjects');
%     
%     range = (min(sorted_lst) - max(sorted_lst))/nSubj;
% 
%     for i = 1:nSubj
%         strVal = [list_subj(idx(i)).name ' diff  = ' num2str(sorted_lst(i))];
%         text(25, max(sorted_lst) + range*i, strVal, 'FontSize', 12, 'Interpreter', 'none');    
%     end
%     filename = fullfile(dirResFigures, 'Subjects ranked by RC2 Stereo-Orig difference');
%     saveas(gcf, filename, 'fig'); 
%     close gcf;   
end

function out = normValue2D(in)
    minV = min(in(:));
    maxV = max(in(:));
    out = (in - minV)/(maxV - minV);
end
    