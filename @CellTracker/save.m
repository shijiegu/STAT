function save(obj,outputdir,filename)
if ~exist('outputdir', 'var') || isempty(outputdir)
    outputdir=fileparts(obj.yaml_path);
end

if ~exist('filename', 'var') || isempty(filename)
    filename=datestr(now,'yyyy_mmmm_dd_HH_MM_SS');
end

save(fullfile(outputdir,filename),'obj')
fprintf(['File with name ''' filename ''' saved to directory \n' '   ' outputdir '\n']);
