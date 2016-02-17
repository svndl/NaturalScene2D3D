function dataOut = rcaSplitEEGData(dataIn, use_conditions, all_conditions, split_by, nsplits, use_splits, baseline)
    %% Code that generates the splitted cell matrix    
    nsubj = size(dataIn, 1);

    dataOut = cell(nsubj, numel(split_by));
    % if use conditions == all_conditions, don't use the ismember function 
    if (isempty(setxor(use_conditions, all_conditions)))
        idxCnd = (1:size(all_conditions, 1))';
    else
        [~, idxCnd] = ismember(use_conditions, all_conditions);
    end
    for s = 1:nsubj
        subjEEG = dataIn(s, :);
        cndEEG = subjEEG(idxCnd(:, 1));
        splitted = mkSplit(cndEEG, use_splits, nsplits, baseline);

        for splits = 1:numel(split_by);
           %take only the splits that requested
           matched_splits = splitted(ismember(use_conditions, split_by{splits}));
           dataOut{s, splits} = cat(3, matched_splits{:});
        end
    end
end
function splitted = mkSplit(cellVector, splitInfo, nsplits, baseline)

    splitted = cell(numel(cellVector), numel(splitInfo));
     for cv = 1:numel(cellVector)
        data = cellVector{cv};
        split_value = ceil(size(data, 1)/nsplits);
        for spt = 1:numel(splitInfo)
            
            split_cnd = data(1 + (splitInfo(spt) - 1)*split_value:splitInfo(spt)*split_value, :, :);
            if (baseline)
                split_cnd = split_cnd - repmat(split_cnd(1, :, :), [size(split_cnd, 1) 1 1]);            
            end
            splitted{cv, spt} = split_cnd;
        end
    end
end