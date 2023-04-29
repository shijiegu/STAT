function export_results(obj,outputdir,filename,neuron_chain,neuron_chain_new,session_ind)
if ~exist('outputdir', 'var') || isempty(outputdir)
    outputdir=fileparts(obj.yaml_path);
end

if ~exist('filename', 'var') || isempty(filename)
    filename=datestr(now,'yyyy_mmmm_dd_HH_MM_SS');
end

save(fullfile(outputdir,filename),'obj','neuron_chain','neuron_chain_new')
fprintf(['All result with name ''' filename ''' saved to directory \n' '   ' outputdir '\n']);
