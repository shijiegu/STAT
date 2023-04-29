function flag = write_config(obj, path_file)
%% what does this function do 
%{
    write the configurations to a YAML file 
%}

%% inputs: 
%{
    path_file: the yaml file 
%}

%% outputs: 
%{
    flag: boolean, success (1) or not (0) 
%}

%% author: 
%{
    Pengcheng Zhou 
    Columbia University, 2018 
    zhoupc1988@gmail.com
%}

%% code 
options = obj.options;

% useful configurations. 
% temp = fieldnames(options); 
% useful_fields = {'d1', ...
%     'd2', ...
%     'd3', ...
%     'nonconverge_method', ...
%     'direction', ...
%     'init_method', ...
%     'crop_window', ...
%     'p_method', ...
%     'R', ...
%     'thresh', ...
%     'nRep'}; 

% x = struct(); 
% for m=1:length(useful_fields)
%     tmp_var = useful_fields{m}; 
%     eval(sprintf('x.%s=options.%s; ', tmp_var, tmp_var)); 
% end

% check the input arguments
if ~exist('path_file', 'var') || isempty(path_file) 
    path_file = obj.yaml_path;
else
    obj.yaml_path = path_file; 
end

try 
    yaml.WriteYaml(path_file, options); 
    flag = true; 
    fprintf('The configurations have been dumped to YAML file\n%s\n', path_file); 
catch 
    flag = false; 
    fprintf('Writing configurations to a YAML file failed\n'); 
end 