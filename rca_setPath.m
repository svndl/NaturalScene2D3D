function rca_path = rca_setPath
    [curr_path, ~, ~] = fileparts(mfilename('fullpath'));
    rca_path.rootFolder = curr_path;
    %src data
    rca_path.srcEEG = fullfile(curr_path, 'srcEEG');
    %rca-ready EEG folder
    rca_path.rcaEEG = fullfile(curr_path, 'rcaEEG');
    
    rca_path.results_Figures = fullfile(curr_path, 'results', 'Figures');
    rca_path.results_Data = fullfile(curr_path, 'results', 'data');
    rca_path.ratings = fullfile(curr_path, 'ratings');
end