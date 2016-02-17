function cellData=exportToRcaReady(dataPath,removeEyes,nanArtifacts,censorEvents)

%% include dot-update filter removal


    if nargin<4, censorEvents = []; end;
    if nargin<3, nanArtifacts = 1; end;
    if nargin<2, removeEyes = 1; end;
    
    %curDir=pwd; % save for later (return to original path after routine)

    %cd(dataPath);
    
    RTsegFiles = dir2(fullfile(dataPath, 'RTSeg_*.mat'));
    segCount = 0;
    for z = 1:numel(RTsegFiles)
        RTfile = fullfile(dataPath, RTsegFiles(z).name);
        load(RTfile); % load data
        if size(TimeLine, 1) > 0;
            segCount = segCount + 1;
            if isempty(censorEvents) % censor events if requested
                TimeLine = TimeLine(setdiff(1:size(TimeLine, 1), censorEvents));
            else
            end
%             nCond(segCount) = length(unique([TimeLine.cndNmb]));
%             condInds{segCount} = unique([TimeLine.cndNmb]);
            
            for t = 1:size(TimeLine, 1)
                rawFileName = ['Raw_c' num2str(TimeLine(t).cndNmb, '%03.0f') '_t' num2str(TimeLine(t).trlNmb, '%03.0f')]; 
                load(fullfile(dataPath, rawFileName));
                rawtrial = double(RawTrial).*repmat(Ampl.', size(RawTrial, 1), 1) + repmat(Shift.' ,size(RawTrial, 1), 1);
                if nanArtifacts
                    [rowE, colE] = find(IsEpochOK == 0);
                    for idx = 1:length(rowE)
                        rowIdx = ((rowE(idx) - 1)*round(FreqHz) + 1):((rowE(idx) - 1)*round(FreqHz) + round(FreqHz));
                        rawtrial(rowIdx,colE(idx)) = NaN;
                    end
                end
                try
                    numNaNs(TimeLine(t).cndNmb,TimeLine(t).trlNmb) = length(find(IsEpochOK == 0));
                    rawdata{TimeLine(t). cndNmb}(:, :, TimeLine(t).trlNmb) = rawtrial;
                catch err
                    display(['oops, something went wrong at t = ' num2str(t) ' cnd= ' num2str(TimeLine(t).cndNmb) ' trial= ' num2str(TimeLine(t).trlNmb)]);
                end
            end
        else
        end
    end
%     if length(unique(nCond)) > 1
%         warning('Different runs have different number of conditions!')
%     else
%         nCond = length(unique([condInds{:}]));
%     end
    
    nCond = size(rawdata, 2);
    cellData = cell(nCond, 1);
    
    for c = 1:nCond
        if removeEyes
            nTrialsThisCond = size(rawdata{c}, 3);
            for tr = 1:nTrialsThisCond
                dataIn = rawdata{c}(:, :, tr);
                X = dataIn(:, 1:end - 2); % data channels
                V = dataIn(:, end - 1:end);  % HEOG/VEOG
                if ~isempty(find(isnan(V), 1))
                    disp('ERROR: Eye channels contain NaNs')
                    return;
                end
                dataOut = (eye(size(X, 1)) - V*pinv(V))*X; %A=pinv(V)*X; % transfer function from eyes to data electrodes
                % If a channel has NaN in any epoch, this step will
                % assign NaNs to every epoch in that block for that channel.
                cellData{c}(:, :, tr) = dataOut;
            end
        else
            cellData{c} = rawdata{c}(:, 1:end - 2, :);  % just take out EOG reference electrodes from electrode
        end
    end

%     % try to remove prelude and postlude
%     if sum(diff([CndTiming(1).preludeDurSec,CndTiming(1).postludeDurSec,CndTiming(1).stepDurSec]))~=0
%         error(0,'Prelude, Postlude and Bin duration are different!')
%     else
%         binLength = round(CndTiming(1).stepDurSec*FreqHz);
%     end
%     dataIdx = (binLength+1):(size(dataOut,1)-binLength); % assumes that prelude are the same across trials and conditons
%     dataTrim = dataOut(dataIdx,:,:,:);
    
    
    
%     nBins = size(dataTrim,1)/binLength;
%     interData = reshape(dataTrim,binLength,nBins,size(dataTrim,2),size(dataTrim,3),size(dataTrim,4));
%     permData = permute(interData,[1,3,5,2,4]);
%     readyData = permData(:,:,:,:);
%     cellReady = cell(1,size(readyData,3));
%     for r = 1:size(readyData,3)
%         cellReady{r} = squeeze(readyData(:,:,r,:));
%     end
%     clear readyData;
%     readyData = cellReady;
    %cd(curDir);
end

