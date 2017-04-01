function natSc_path = natSc_setPath(database,how)

%This function configures path for NaturalScene2D3D project

[curr_path, ~, ~] = fileparts(mfilename('fullpath'));
natSc_path.rootFolder = curr_path;
%src data
natSc_path.srcEEG = fullfile(curr_path, 'srcEEG');
%rca-ready EEG folder
natSc_path.rcaEEG = fullfile(curr_path, 'rcaEEG');



if isequal(how.useSplits,2)||isequal(how.useSplits,4)||isequal(how.useSplits,[2 4])
    
    dirResFol = fullfile(curr_path, 'results', 'data', database,'StimuliChunk');
    dirFigF = fullfile(curr_path, 'results', 'Figures', database,'StimuliChunk');
else
    dirResFol = fullfile(curr_path, 'results', 'data', database,'BlankChunk');
    dirFigF = fullfile(curr_path, 'results', 'Figures', database,'BlankChunk');
end

%Specifies where the results are saved
if how.split ==1
    results_Data_Folder = fullfile(dirResFol,[num2str(how.useSplits),'TrainedSeparatedly']);
    results_Figures_Folder = fullfile(dirFigF, [num2str(how.useSplits),'TrainedSeparatedly']);
    
else
    results_Data_Folder = fullfile(dirResFol,[num2str(how.useSplits),'TrainedTogether']);
    results_Figures_Folder = fullfile(dirFigF, [num2str(how.useSplits),'TrainedTogether']);
    
end




if how.nScenes == 1
    natSc_path.results_Figures = fullfile(results_Figures_Folder, 'bySubject');
    natSc_path.results_Data = fullfile(results_Data_Folder, 'bySubject');
else
    natSc_path.results_Figures = fullfile(results_Figures_Folder, 'byScene');
    natSc_path.results_Data = fullfile(results_Data_Folder, 'byScene');
end


natSc_path.ratings = fullfile(curr_path, 'ratings');
end