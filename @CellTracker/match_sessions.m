function obj=match_sessions(obj,session_ind,varargin)
% 'Name-Value' input: 
% 'W0',W0: cells of (num of sessions x num of sessions) initialize
% 'start_new',1: true or false. Whether to keep old results and interate
%                  more from the old results or start from empty results over again.
%
%% input handling and parsing

options=obj.options;
keep_A=options.keep_A;
init_method=options.init_method;

% handling character indexing
session_ind=obj.id2ind(session_ind);
% keep A or not, if not, calculate spatial fft first;
if (~keep_A)&&(~isempty(obj.A_all{1}))&&(strcmp(options.init_method,'shape'))
    obj.update_spatial_fft()
    obj.update_image_fft()
    obj.delete_As;
end

p = inputParser;
addParameter(p,'W0',cell(obj.n_sessions));
addParameter(p,'start_new',0);
parse(p, varargin{:});
W0=p.Results.W0;
start_new=p.Results.start_new;


if and(and(~iscell(W0),ismatrix(W0)),obj.n_sessions==2)
    % if there are only two sessions to match, W0 might be input as a
    % matrix, but in this multi-session wrapper, W0 is a cell array.
    W0_ = cell(obj.n_sessions); W0_{session_ind(1),session_ind(2)}=W0; W0=W0_;
elseif ~and(size(W0,1)==obj.n_sessions,size(W0,2)==obj.n_sessions)
    error(['Please check your input of initiation. \n',...
         'The size should be of length(session_ind)*length(session_ind)'])
end

%% preparation
if options.move
    if options.d3==1; cb_ref = imref2d([options.d1,options.d2]);
    else; cb_ref = imref3d([options.d1,options.d2,options.d3]);
    end
else; cb_ref = [];   
end

if start_new
    for m=1:length(session_ind)
        session1=session_ind(m);
        for n=(m+1):length(session_ind)
            session2=session_ind(n);
            obj.reset_two_sessions(session1,session2)
            obj.reset_two_sessions(session2,session1)
        end
    end
end

retronum=options.retronum;
%% Real work starts here
% Start pairing neurons

% --------- initialize var. (for parfor) ---------
[N_all,W_all,W_msg_all,...
    W_final_all,X_moved_all,D_moved_all]=copy_results(obj,[],[]);

if options.parallel_num>0
    [m,binname]=obj2bin(obj); %use memmap to reduce RAM requirement
    OBJ=[];
else
    OBJ=mini_cts(session_ind,obj);
end

parfor (j=2:length(session_ind),options.parallel_num)
    session2=session_ind(j);
    
    % --------- slice var. (for parfor) ----------
    N_all_j=N_all(j,:);             W_all_j=W_all(j,:); W_msg_all_j=W_msg_all(j,:);
    W_final_all_j=W_final_all(j,:);
    X_moved_all_j=X_moved_all(j,:); D_moved_all_j=D_moved_all(j,:);
    
    for k=1:min(retronum,j-1)
        session1=session_ind(j-k);
    
        disp(['Matching session ' num2str(session2) '[ID ' obj.session_ids{session2},...
            '] to session ' num2str(session1) '[ID ' obj.session_ids{session1} ']'])
            
        if ~isempty(W0{session1,session2}); W0_input=W0{session1,session2};
        elseif ~isempty(W0{session2,session1}); W0_input=W0{session2,session1}; W0_input=W0_input(:,[2 1]);
        else; W0_input=[];
        end
        
%         if k>1
%             W_fix=zeros(obj.n_all{session1},obj.n_all{session2});
%             for i=(j-k+1):(j-1)
%                 session_mid=session_ind(i);
%                 tmp1=pairs2W(obj.W_final_all{session1,session_mid},obj.n_all{session1},obj.n_all{session_mid});
%                 tmp2=pairs2W(obj.W_final_all{session_mid,session2},obj.n_all{session_mid},obj.n_all{session2});
%                 W_fix=W_fix+tmp1*tmp2;
%             end
% 
%             [row,col]=find(W_fix>0);
%             W_fix=[row,col];
%             
%             unpaired_1=reshape(setdiff(reshape(1:obj.n_all{session1},[],1),W_fix(:,1)),[],1);
%             unpaired_2=reshape(setdiff(reshape(1:obj.n_all{session2},[],1),W_fix(:,2)),[],1);
%             if and(isempty(unpaired_1),isempty(unpaired_2)) % have no unpaired in both days (rare)
%                 continue
%             end
%         else
            W_fix=[];
            unpaired_1=reshape(1:obj.n_all{session1},[],1);
            unpaired_2=reshape(1:obj.n_all{session2},[],1);
%         end
        
        W0_both=refine_W0(W0_input,W_fix); %refine W0, take out any neurons that are in W_final
        
        if options.parallel_num>0
            ct_=mini_cts([session1,session2],obj.options,m);
        else
            ct_=OBJ{session1,session2}; %without memmap
        end
        no_neuron_flag=match_two_sessions_full(ct_,1,2,cb_ref,'W0',W0_both,'W_final',W_fix,...
            'ind2cal_1',unpaired_1,'ind2cal_2',unpaired_2,'move',options.move,'max_shift',options.max_shift);
        
        % ------- fill in one slice (for parfor) --------
        [N_all_j{k},W_all_j{k},W_msg_all_j{k},...
            W_final_all_j{k},X_moved_all_j{k},D_moved_all_j{k}]=copy_results(ct_,1,2);
        % -----------------------------------------------

        if no_neuron_flag
            if k==1
                error(['No neurons found between session ' num2str(session1) 'ID:' obj.session_ids{session1}...
                    ' and session' num2str(session2) 'ID:' obj.session_ids{session2}, '\n',...
                    'Initiate by hand please.'])
            else
                disp(['No neurons found between session ' num2str(session1) 'ID:' obj.session_ids{session1}...
                    ' and session' num2str(session2) 'ID:' obj.session_ids{session2}])
                continue
            end
%         elseif ~isempty(W_fix) % check conflicts with those found before            
%             for i=(j-k+1):(j-1)
%                 session_mid=session_ind(i);
%                 tmp1=pairs2W(obj.W_final_all{session1,session2},obj.n_all{session1},obj.n_all{session2});
%                 tmp1_=pairs2W(obj.W_final_all{session_mid,session2},obj.n_all{session_mid},obj.n_all{session2});
%                 tmp1_=tmp1_';
%                 tmp2=pairs2W(obj.W_final_all{session1,session_mid},obj.n_all{session1},obj.n_all{session_mid});
%                 deter=(tmp1*tmp1_+tmp2)>0;
%                 ind_false=sum(deter,2)>1;
%                 if sum(ind_false)>=1
%                     ind=find(ind_false);
%                     tmp1(ind,:)=zeros(size(length(ind),obj.n_all{session2}));
%                 end
%                 [row,col]=find(tmp1);
%                 W_updated=[row,col];
%                 obj.tally_W_final(session1,session2,W_updated,'conflicts resolved');
%             end            
        end
    end
    % --------- fill in all slices (for parfor) ---------
    N_all(j,:)=N_all_j;             W_all(j,:)=W_all_j; W_msg_all(j,:)=W_msg_all_j;
    W_final_all(j,:)=W_final_all_j;
    X_moved_all(j,:)=X_moved_all_j; D_moved_all(j,:)=D_moved_all_j;
    
    % --------- clear initiations (for parfor) ---------
    N_all_j=[]; W_all_j=[]; W_msg_all_j=[]; W_final_all_j=[]; X_moved_all_j=[]; D_moved_all_j=[];
end

% ---------  copy for parfor --------- 
obj=copy_results_re(obj,session_ind,N_all,W_all,W_msg_all,W_final_all,X_moved_all,D_moved_all);
% ---------  clear variables for parfor ---------
if options.parallel_num>0
    clear m
    delete(binname)
end

disp('STAT finished its work! Check it Out.')
end