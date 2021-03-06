function dtiOTSDataPrep 

% function dtiOTSDataPrep 
%
% Script to prepare Davie's OTS data for analysis... based off of Dave's
% dtiOTSDataPrep, but written to be run on a PC, not teal, and to analyze
% group average dt6s. 
%
% Author: DY
% Date: 08/20/2006

baseDir = 'Y:\data\reading_longitude\dti_y2'; %path to subjects' dti data on harddrive
cd(baseDir);
d = dir('*0*'); % lists all directories 
f = {d.name};
fiberDir = '\fibers\OTSproject';
fgNames = {'LOTS_tal_sph8_FG.mat', 'ROTS_tal_sph8_FG.mat'};

for(ii=1:length(f))
    subDir = fullfile(baseDir, f{ii});
    dt6Name = [f{ii} '_dt6_noMask.mat']);
    dt6Path = fullfile (subDir, dt6Name);
   
    fprintf ('Converting DT6 %s to binary format...\n', dt6Name);
    dtiConvertDT6ToBinaries (dt6Path);
    
    for (fGroupIndex=1:length(fgNames))
        fgName = fgNames{fGroupIndex};
        fgPath = fullfile(subDir, fiberDir, fgName);
        distanceName = fullfile(subDir,'bin','selections',fgName);
        distanceName = [distanceName '.dis'];
        
        fprintf ('Loading fiber group %s\n', fgPath);
        fg = open (fgPath);
        fprintf ('Computing distance matrix...\n');
        dtiComputePathwayDistanceMatrixFromFG (fg.fg, distanceName);
    end;

end;

fprintf ('Done!\n');
