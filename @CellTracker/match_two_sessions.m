function no_neuron_flag=match_two_sessions(obj,session1,session2,varargin)
% This method matches neurons from two specific sessions indicated by the first 2 argument.
% Some useful 'Name-Value' pairs are 'ind2cal_1',and 'ind2cal_2',
%      which can specify which neurons to match. In this case, the algorithm will
%       initiate W0 based only on these two pools of neurons.
%       In addition, W_final, if is not empty, will also be used in
%       iteration along with the new W0, and matches in W_final are not allowed to
%       change, they are only there to help.
% Another 'Name-Value' pair is 'start_new', if set to true, anything
%       happened before between session1 and session2 will be discarded.
%       This 'Name-Value' pair is not used in the full implementation of
%       STAT. But it is kept for potential use when this method is called
%       like a function.
% The final 'Name-Value' pair is 'W0', you can also specify in the Name-Value pair W0 as:'W0',W0.
%       In this case, the algorithm will not use Hungarian method to
%       initiate.
%
% Shijie Gu, Sept 2018

%% input and parameters

% if sessions are specified using id rather than number.
if ischar(session1); [~,session1]=ismember(session1,obj.session_ids); end
if ischar(session2); [~,session2]=ismember(session2,obj.session_ids); end

options=obj.options;
d1=options.d1; % dimension 1 (row number) of the FOV
d2=options.d2; % dimension 2 (col number) of the FOV
d3=options.d3;
cal_corr=options.cal_corr;
init_method=options.init_method;
R=options.R;   % L. defining the min neighborhood.
thresh=options.thresh;%threshold for sifting W
nRep=options.nRep;%number of iterations
w=options.crop_width;
p_method=options.p_method;
direction=options.direction;
n1=obj.n_all{session1};
n2=obj.n_all{session2};
keep_A=options.keep_A;

if strcmp(p_method,'hard_flexible')
    p_method='hard'; %used in iteration_core: 'hard_flexible' uses 'hard' first, then 'hard_flexible'.
end

p = inputParser;
addParameter(p,'ind2cal_1',reshape(1:n1,[],1)); %specify which neurons in session 1 to match
addParameter(p,'ind2cal_2',reshape(1:n2,[],1)); %specify which neurons in session 2 to match
addParameter(p,'W0',[]);      % input W0
addParameter(p,'W_final',[]); % this option can let you overwrite W_final in the object.
addParameter(p,'move',0);     % if 'move' is true, the algorithm will use obj.X_moved_all rather than obj.X_all
addParameter(p,'start_new',0);
addParameter(p,'max_shift',[]); % threshold max distance between a proposed pair 
                                %in initiation if distance is used for initiation

% keep A or not, if not, calculate spatial fft first;
% this section is called within match_session, but reproduced here in case
% match_two_sessions is called by itself.
if (~keep_A) * (~isempty(obj.A_all{1}))
    obj.update_spatial_fft([session1,session2])
    obj.delete_As();
end


parse(p, varargin{:});
W0=p.Results.W0;
W_final=p.Results.W_final;
ind2cal_1=p.Results.ind2cal_1;
ind2cal_2=p.Results.ind2cal_2;
move=p.Results.move;
start_new=p.Results.start_new;
max_shift=p.Results.max_shift;

if start_new; reset_two_sessions(obj,session1,session2); end

if isempty(W_final)
        W_final=obj.W_final_all{session1,session2};
end

update_ind2cal; %not necessary, just to be safe for some illegal use of the function.


%% matrices needed in initiation 
if or(strcmp(init_method,'shape'),strcmp(init_method,'correlation'))
    % Calculate Distance (for initiation) ...
    %    ... and potnetially shape correlation matrix (for initiation or for manual intervention in the end)
    C=obj.cal_corr(session1,session2,'ind2cal_1',ind2cal_1_,'ind2cal_2',ind2cal_2_); 
    init_cost=C(ind2cal_1_,ind2cal_2_);
elseif strcmp(init_method,'distance')
    D=obj.cal_dist(session1,session2,'ind2cal_1',ind2cal_1_,'ind2cal_2',ind2cal_2_,'move',move); 
    init_cost=D(ind2cal_1_,ind2cal_2_);
end


% do not overwrite old results, only append, when this function is called
% again.
if strcmp(direction,'both')
    if strcmp(options.p_method,'hard') || strcmp(options.p_method,'gaussian')
        total_iteration_round=1;
    elseif strcmp(options.p_method,'hard_flexible')
        total_iteration_round=2;
    end
elseif strcmp(direction,'uni')
    if strcmp(options.p_method,'hard') || strcmp(options.p_method,'gaussian')
        total_iteration_round=2;
    elseif strcmp(options.p_method,'hard_flexible')
        total_iteration_round=4;
    end
end

W_single=cell(1,total_iteration_round*(nRep+2)); %preallocation for each repetition.
N_single=cell(1,total_iteration_round*(nRep+2)+1);
W_msg_single=W_single;
   
if or(numel(obj.W_all{session1,session2})>0,numel(obj.W_all{session2,session1})>0)
    W_single_old=obj.W_all{session1,session2};
    W_msg_single_old=obj.W_msg_all{session1,session2};
    N_single_old=obj.N_all{session1,session2};
    
    last_ind=find(~cellfun(@isempty,W_msg_single_old),1,'last');
    it_=last_ind;
    W_single_old=W_single_old(1:last_ind); W_msg_single_old=W_msg_single_old(1:last_ind);
    N_single_old=N_single_old(1:(last_ind+1));
    
    W_single=cat(2,W_single_old,W_single);
    W_msg_single=cat(2,W_msg_single_old,W_msg_single);
    N_single=cat(2,N_single_old,N_single);
else
    it_=0;
end

%% Initiation using Hungarian algorithm

if isempty(W0)  
    [i, j] = obj.hungarian(init_cost);
    costs=init_cost(sub2ind(size(init_cost),i,j));
    if ~and(isempty(max_shift),strcmp(init_method,'distance'))
        i=i(costs<=max_shift);
        j=j(costs<=max_shift);
    end
    W0=[ind2cal_1_(i),ind2cal_2_(j)];
end

% record in W_single
W_single{it_+1}=[W_final; W0];

if ~move
    if ~isempty(W_final); W_msg_single{it_+1}='New round: previous W_final';
    else;                 W_msg_single{it_+1}='New round: new W0';
    end
else
    if ~isempty(W_final); W_msg_single{it_+1}='After motion compensation: previous W_final';
    else;                 W_msg_single{it_+1}='After motion compensation: new W0';
    end
end
if size(W_single{it_+1},1)<=1
%     if session1<=session2 %only tally one side to save memory
        
        obj.W_all{session1,session2}=W_single;
        obj.W_msg_all{session1,session2}=W_msg_single;
        obj.N_all{session1,session2}=N_single;
        obj.W_final_all{session1,session2}=W_final;
%    else
%         obj.W_all{session2,session1}=cellfun(@reorder,W_single,'UniformOutput',false);
%         obj.W_msg_all{session2,session1}=W_msg_single;
%         obj.N_all{session2,session1}=cellfun(@addprime,N_single,'UniformOutput',false);
%         obj.W_final_all{session2,session1}=reorder(W_final);
%    end
    no_neuron_flag=1;
    return
end

%% Iteration
it_=it_+1; %it_ is the last filled timepoint in W_single.

for IT=1:2 %in the first direction require bidirectionality.
    
    for it=1:nRep %hard, the neighborhood radius is not able to stretch
        disp(['session (' num2str(session1) ',' num2str(session2) ') Matching....iteration = ' num2str(it)]); 
        iteration_core; 
        if iteration_core_flag
            break
        end
    end
    
    W_final_old=W_final;
    W_final=W_single{it_+it+1};
    update_ind2cal;
      
    %for hard_flexible, stretch L for neurons far now.
    it_=it+it_+1;
    if strcmp(options.p_method,'hard_flexible')
        p_method='hard_flexible';
        % define the initiation of 'hard_flexible'
        if ~isempty(W_final_old)
            W_increase=setdiff(W_final,W_final_old,'rows');
        else
            W_increase=W_final;
        end
        
        if isempty(W_increase) %no new neurons found in the previous iteratiom
            W_single{it_+1}=W_single{1};
            W_msg_single{it_+1}='(Flexible neighborhood). New round initiation: re-start from old initiation';
        else
            W_single{it_+1}=W_final;
            W_msg_single{it_+1}='(Flexible neighborhood).New round initiation: previous result';
        end

        
        it_=it_+1;
        % Iteration again, but with p_method='hard_flexible';
        for it=1:(nRep)
            disp(['session (' num2str(session1) ',' num2str(session2) ') Matching....iteration with extended neighd. (for some unmatched neurons) = ' num2str(it)])
            iteration_core
            if iteration_core_flag
                break
            end
        end
        W_final=W_single{it+it_+1};
        update_ind2cal;
    end
    
    it_=it+it_+1;
    if or(strcmp(direction,'both'),strcmp(direction,'bi'))
        break
    else % define initiation W0 for later iterations
        if isempty(W_final); W_single{it_+1}=W0; W_msg_single{it_+1}='(Single direction) New round: Use old W0 again.';
        else; W_single{it_+1}=W_final;           W_msg_single{it_+1}='(Single direction) New round: previous W_final';
        end
        it_=it_+1;
    end
end

%% Tally final results

%if session1<=session2 %only tally one side to save memory
    obj.W_all{session1,session2}=W_single;
    obj.W_msg_all{session1,session2}=W_msg_single;
    obj.N_all{session1,session2}=N_single;    
% else
%     obj.W_all{session2,session1}=cellfun(@reorder,W_single,'UniformOutput',false);
%     obj.W_msg_all{session2,session1}=W_msg_single;
%     obj.N_all{session2,session1}=cellfun(@addprime,N_single,'UniformOutput',false);    
% end
obj.W_final_all{session1,session2}=W_final;
obj.W_final_all{session2,session1}=reorder(W_final);

% convert to absolute index
if isempty(W_final)
    disp(['session (' num2str(session1) ',' num2str(session2) ') No neurons found.']); 
    no_neuron_flag=1;
    return
else
    no_neuron_flag=0;
end
% paired=Convert2AbsoluteCoordinate(W_final,session1,session2,obj.n_all);
% obj.paired_all{session1,session2}=paired;
% obj.paired_all{session2,session1}=reorder(paired);

end