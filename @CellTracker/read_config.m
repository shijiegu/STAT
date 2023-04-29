function flag = read_config(obj, path_file)
%% what does this function do
%{
    read configurations for running STAT from a YAML file
%}

%% inputs:
%{
    path_file: the path of the yaml file. if it's empty, they use the
    default yaml file obj.yaml_path
%}

%% outputs:
%{
    flag: boolean variable, success or no
%}

%% author:
%{
    Pengcheng Zhou
    Columbia University, 2018
    zhoupc1988@gmail.com
%}

%% code

% check the input arguments
if ~exist('path_file', 'var') || isempty(path_file) || ~exist(path_file, 'file')
    path_file = obj.yaml_path;
else
    obj.yaml_path = get_fullname(path_file); 
end

% load yaml file
configs = yaml.ReadYaml(path_file);

% pass configs to the class object
try
    obj.options = configs;
    fprintf(sprintf('The configurations in the YAML file \n\t%s \nhas been successfully loaded.\n\n', ...
        get_fullname(path_file)));
    flag = true; 
catch
    flag = false;
    fprintf('Loading configurations has failed.');
end
