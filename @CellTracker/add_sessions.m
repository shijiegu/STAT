function flag=add_sessions(obj, As_new, IDs_new)
%% add one session result 
%{
    if the pre-allocated space is empty, we need to expand it to store this
    new data. 
%}

%% inputs: 
%{
    As_new: 
    (one possibility) a cell array (of length K) of spatial footprint from K sessions. 
    Each cell is a d1*d2(*d3)*K
    ndarray or a d*K matrix. it corresponds to the spatial footprints of
    all neurons in the corresponding session.
    (or) it could be a cell array (of length K) of centriods of spatial footprint

    IDs_new: a cell array of K elements. each element provides a unique ID
    for the corresponding session. it can be either a number or a string
%}

%% outputs: 
%{
    flag: boolean, success (1) or not (0) 
%}

%% author: 
%{
    Pengcheng Zhou             & Shijie Gu
    Columbia University, 2018    ShanghaiTech University; Fee Lab at MIT, 2018
    zhoupc1988@gmail.com         techel@live.cn
%}

%%
%try
if ~iscell(As_new)
    % if As_new is not a cell array. this happens when you only want to add
    % one session. 
    % it's recommended to pass {A} instead of A in this case, but we will
    % handle this bad passing of input argument. 
    As_new = {As_new};
end

n_add = length(As_new);         % number of sessions to be added 
n_space = length(obj.A_all);    % number of total spaces
n_more = obj.n_sessions + n_add - n_space;  % more slots for storing new sessions 


% create session IDs if they were not provided 
if ~exist('IDs_new', 'var') || isempty(IDs_new)
    IDs_new = cell(n_add, 1);
    for m=1:n_add
        IDs_new{m} = num2str(m + obj.n_added);
    end
elseif ~iscell(IDs_new)
   IDs_new = {IDs_new};  
end

% check if added data has already been added.
if sum(~cellfun(@isempty,obj.session_ids))>=1
    Lia=ismember(IDs_new,obj.session_ids);
    IDs_new=IDs_new(~Lia);
    As_new=As_new(~Lia);
    if isempty(IDs_new)
        flag=0;
        disp('No new data added.')
        return
    end
end



% expand the space for saving new session information
if n_more >0
    n = n_space + n_more;
    obj.A_all{n} = [];      % spatial shapes 
    obj.A_moved_all{n,n} = []; 
    obj.n_all{n} = [];      
    obj.W_final_all{n,n} = [];% matching matrix
    obj.X_all{n} = [];      % neuron centers 
    obj.X_moved_all{n,n} = []; 
    obj.session_ids{n} = [];    % IDs 
    obj.FFT_all_1{n}=[];
    obj.FFT_all_2{n}=[];
    
    obj.W_all{n, n} = [];   % matching matrix 
    obj.W_msg_all{n, n} = [];   
    obj.paired_all{n, n} = {};
    obj.N_all{n, n} = [];   % matching matrix 
    obj.C_all{n, n} = [];   % shape correlation matrix     
    obj.D_all{n, n} = [];    % center distances 
    obj.D_moved_all{n, n} = [];
    
end

% put all spatial shapes into A_all
idx0 = obj.n_sessions; 
obj.session_ids(idx0+(1:n_add)) = IDs_new;

sizes=size(As_new{1});
if length(sizes)>2 %spatial footprint input
    obj.A_all(idx0+ (1:n_add)) = As_new;
    obj.options.d1=sizes(1);
    obj.options.d2=sizes(2);
    if numel(sizes)==3
        obj.options.d3=1;
    elseif numel(sizes)==4
        obj.options.d3=sizes(3);
    end
    for m=1:n_add
    % save neuron centers 
    obj.X_all{idx0+m} = get_centers(As_new{m});
    
%     % compress spatial shapes 
%     obj.A_all{idx0+m} = sparse(obj.reshape(As_new{m}, 1)); 
    
    % count the number of neurons in this session
    if obj.options.d3==1
        obj.n_all{idx0+m} = size(obj.A_all{idx0+m}, 3); 
    else
        obj.n_all{idx0+m} = size(obj.A_all{idx0+m}, 4); 
    end
    end
else
    for m=1:n_add
        obj.X_all{idx0+m} = As_new{m};
        obj.n_all{idx0+m} = size(As_new{m},1); 
    end
end


obj.n_sessions = obj.n_sessions + n_add;
obj.n_added = obj.n_added + n_add;
flag=1;
% catch e
%     flag=0;
%     disp('loading data unsuccessful.')
%     display(e)
% end
%%
