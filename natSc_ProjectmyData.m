function [muData, semData] = natSc_ProjectmyData(data, weights,baselineSample)
    dataOut = rcaProject(data, weights);
    catData = cat(3, dataOut{:});
    muData = nanmean(catData, 3);
    semData = nanstd(catData, [], 3)/(sqrt(size(catData, 3)));   
    
    %baselining uisng the first n=baselineSample time samples
    baseline = nanmean(muData(1:baselineSample,:),1);
    %muData = muData - repmat(muData(1, :), [size(muData, 1) 1]);
    muData = muData - repmat(baseline, [size(muData, 1) 1]);
end
