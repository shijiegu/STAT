function nam = get_fullname(nam)
%% get the file's full path
%{
     by replacing relative locations like '.', '~'
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

tmp_dir = cd();
[dir_nm, file_nm, ext] = fileparts(nam);
if isempty(dir_nm)
    dir_nm = tmp_dir;
end
cd(dir_nm);
dir_nm = cd();
nam = [dir_nm,filesep, file_nm, ext];
cd(tmp_dir);
end