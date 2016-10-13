# rcaNatScenes

RCA toolbox for analyzing source EEG Data from two 3D/2D experiments. 
Most of the analysis is done on split EEG data, splits and conditions to use are defined in the *switch* block.
Results (figures) are saved in *dirResData = fullfile(rca_path.results_Data, database)*.

Latest RCA code can be found here : https://github.com/dmochow/rca

*
    % 'Live3D' or 'Middlebury'
    database = 'Live3D';

    switch database
        case 'Live3D'
            how.allCnd = {'D', 'E'; 'D', 'O'; 'D', 'S'; 'E', 'D';'E', 'O'; 'E', 'S'; 'O', 'D'; 'O', 'E'; 'O', 'S'; 'S', 'D'; 'S', 'E'; 'S', 'O'};
            how.splitBy = {'O', 'S'};
        case 'Middlebury'
            how.allCnd = {'E', 'O'; 'E', 'S'; 'O', 'E'; 'O', 'S'; 'S', 'E'; 'S', 'O'};
            how.splitBy = {'O', 'S'};
        otherwise
    end
*

# Function list

* *plotSubjOZ.m* plots the average OZ channel (#75) for each subjet and condition.
* *rca_AnalyzeScenes.m* runs RC analysis on split data and projects scenes EEG.
* *rca_AnalyzeSubjects.m* runs RC analysis on split data and projects subjects EEG.
* *maxDifference.m* calculates PCA Max. difference between two conditions.
* * rcaRunAll.m*  runs RC analysis on whole dataset.

