%% import STAT 

if ~exist('STAT_imported', 'var') || ~STAT_imported
    %% STAT package has not been imported.
    STAT_dir = fileparts(mfilename('fullpath'));
    addpath(STAT_dir); 
    addpath(fullfile(STAT_dir, 'packages', 'yamlmatlab'));
    addpath(fullfile(STAT_dir, 'packages', 'utils'));
    addpath(fullfile(STAT_dir, 'scripts'));
    addpath(fullfile(STAT_dir, 'utilities'));
    addpath(fullfile(STAT_dir, 'visualization'));
    STAT_imported = true;
    fprintf('STAT package has been loaded\n'); 
end

%% save path
%savepath();

