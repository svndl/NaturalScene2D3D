%% This script find the onset time of 2D 3D differences. 
% inputFor2D3DdifferenceOnsetDetection.csv is generated in r script (to be
% added to github)
%function: findOnsetTime, in svndle git mrC repository

cd ~/Dropbox/Research/4_IndividualDifferences/rcaNatScenes/results/figures/Live3D_new/rcaProjectOS_bySubjects/
input = csvread('inputFor2D3DdifferenceOnsetDetection.csv');
input = input(:,2:end);
input(24,:) = [repelem(-1,21),repelem(1,294)] %first 50 ms (which is first 21 time samples) as baseline. 
[onsetTime,onsetIx] = findOnsetTime(input(22,:),input(23,:),input(24,:),'2.5stdThresh','allSeries',input(1:21,:))






