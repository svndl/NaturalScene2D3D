function [predictions, accuracy, confusionMatrix] = LDAclassifyEEG(X, Y, varargin)

    %%%%%%%%%%%%%%%%
    % ERROR CHECKING
    
    % if Y passed in as row vector, convert to column vector
    if size(Y,2) > size(Y,1)
        Y = Y';
    end
    
    % make sure X,Y dimensions match 
    if length(Y) ~= size(X,1)
       error('X, Y format error.  Please check that X in is trial by dimension format, and that Y is a column vector');
       quit;
    end
    
    %
    %%%%%%%%%%%%%%%%

    % this is for the optional paramenter numPCs
    p = inputParser;
    
    p.addRequired('X');
    p.addRequired('Y');
    
    checkNumPC = @(x) any(x>1);
    p.addOptional('numPCs', NaN,checkNumPC);
    
    p.KeepUnmatched = true;
    parse(p, X, Y, varargin{:});
    
    inputs = p.Results;

    
    %%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%% DO PCA
    %%%%%%%%%%%%%%%%%%%%%%%%%
    if ~isnan(inputs.numPCs)
        disp('getting PCs');
        [U,S,V] = svd(X);
        xPC = X * V;
        X = xPC(:,1:inputs.numPCs);
        disp(['got ' num2str(inputs.numPCs) ' PCs']);
        size(X)
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%
    %%%% DO LDA
    %%%%%%%%%%%%%%%%%%%%%%%%%
    c = cvpartition(Y,'KFold',10);

    err = zeros(c.NumTestSets, 1);
    disp(sum(bitor(c.training(1), c.test(1))))

    predictAccuracyArr = zeros(10,1);
    predictedLabelsAll = NaN(size(Y));
    correctLabelsAll = []; 
    testFoldIndx = NaN(size(Y));
    
    % loop to do cross validation
    for i = 1:c.NumTestSets
        % create training set
        trainInd = c.training(i);
        trainX = trainInd .* X;
        trainX = trainX(any(trainX, 2),:);
        trainY = trainInd .* Y;
        trainY = trainY(any(trainY, 2),:);

        % fit model
        mdl = fitcdiscr(trainX, trainY);
        
        % create test set
        testInd = c.test(i);
        testX = testInd .* X;
        testX = testX(any(testX, 2),:);
        testY = testInd .* Y;
        testY = testY(any(testY, 2),:);

        % test and create predictions
        predictedLabels = predict(mdl,testX);
        predictedLabels = predictedLabels(:,end);
        predictedLabelsAll(c.test(i)==1) = predictedLabels;
        correctPredictionsCount = sum(not(bitxor(predictedLabels, testY)));
        predictAccuracyArr(i) = correctPredictionsCount/length(testY);

    end
    
    accuracy = mean(predictAccuracyArr);
    predictions = predictedLabelsAll;
    confusionMatrix = confusionmat(Y, predictions);
    imagesc(confusionMatrix);
    
    % save confusion matrix in file
    csvwrite('confusionMatrix.csv', confusionMatrix)