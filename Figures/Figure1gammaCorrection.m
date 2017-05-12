function Figure1gammaCorrection
img_dir = uigetdir(filesep, 'Select the directory with images');
savedir = uigetdir(filesep, 'Select the directory to save the results');
ListOfScenes = dir2(img_dir);
ListOfScenes=ListOfScenes(~ismember({ListOfScenes.name},{'.','..','.DS_Store'}));
nScenes  = numel(ListOfScenes);

for s = 1:nScenes
    hgamma = vision.GammaCorrector(2.0,'Correction','gamma');
    x = imread(ListOfScenes(s).name);
    y = step(hgamma,x);
    imwrite(y,fullfile(savedir,ListOfScenes(s).name));
    
    
end
end

