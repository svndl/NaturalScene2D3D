function [muData, semData,out] = natSc_ProjectmyData(data, weights,baselineSample)
    dataOut = rcaProject(data, weights);
    catData = cat(3, dataOut{:});
    muData = nanmean(catData, 3);
    semData = nanstd(catData, [], 3)/(sqrt(size(catData, 3)));   
    
    %baselining uisng the first n=baselineSample time samples
    baseline = nanmean(muData(1:baselineSample,:),1);
    %muData = muData - repmat(muData(1, :), [size(muData, 1) 1]);
    muData = muData - repmat(baseline, [size(muData, 1) 1]);
    out = squeeze(dataOut{1}(:,1,:));
    bl = nanmean(out(1:baselineSample,:),1);
    out = out - repmat(bl,315,1);
end
