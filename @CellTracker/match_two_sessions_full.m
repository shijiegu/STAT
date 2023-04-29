function no_neuron_flag=match_two_sessions_full(obj,session1,session2,cb_ref,varargin)
%%
if ischar(session1); [~,session1]=ismember(session1,obj.session_ids); end
if ischar(session2); [~,session2]=ismember(session2,obj.session_ids); end

n1=obj.n_all{session1};
n2=obj.n_all{session2};

p = inputParser;
addParameter(p,'ind2cal_1',reshape(1:n1,[],1)); %specify which neurons in session 1 to match
addParameter(p,'ind2cal_2',reshape(1:n2,[],1)); %specify which neurons in session 2 to match
addParameter(p,'W0',[]);      % input W0
addParameter(p,'W_final',[]); % this option can let you overwrite W_final in the object.
addParameter(p,'move',0);     % if 'move' is true, the algorithm will use obj.X_moved_all rather than obj.X_all
addParameter(p,'start_new',0); %not used in the full implemenation of STAT, leave to potential use
addParameter(p,'max_shift',[]); % threshold max distance between a proposed pair 
                                %in initiation if distance is used for initiation
parse(p, varargin{:});
W0=p.Results.W0;
W_final=p.Results.W_final;
ind2cal_1=p.Results.ind2cal_1;
ind2cal_2=p.Results.ind2cal_2;
move=p.Results.move;
start_new=p.Results.start_new; %not used in the full implemenation of STAT, leave to potential use
max_shift=p.Results.max_shift;
%%

no_neuron_flag=obj.match_two_sessions(session1,session2,'ind2cal_1',ind2cal_1,'ind2cal_2',ind2cal_2,...
                                                        'W0',W0,'W_final',W_final,'move',0);
if and(no_neuron_flag,obj.options.auto_move)
    disp('Applying automatic intensity based rigid motion compensation...')
    vect=comprigid_two_sessions(obj,session1,session2);
    disp('The motion vector is')
    display(vect)
    disp('motion compensated by maxing correlation...')
    last_ind=find(~cellfun(@isempty,obj.W_msg_all{session1,session2}),1,'last');
    obj.W_msg_all{session1,session2}{last_ind+1}='motion compensated by maxing correlation.';
    obj.W_all{session1,session2}{last_ind+1}=[]; obj.W_all{session2,session1}{last_ind+1}=[];
    obj.N_all{session1,session2}{last_ind+2}=[];
    no_neuron_flag=obj.match_two_sessions(session1,session2,'ind2cal_1',ind2cal_1,'ind2cal_2',ind2cal_2,...
                                                    'W0',W0,'W_final',W_final,'move',1,'max_shift',max_shift);
end

if and(no_neuron_flag,isempty(W_final))
    return
end

if move
    vect=move_two_sessions(obj,session1,session2,cb_ref);
    disp('motion compensated from estimated pairs...the motion vector is')
    display(vect)

    last_ind=tally_W_final(obj,session1,session2,[],'motion compensated from estimated pairs.');  

    obj.N_all{session1,session2}{last_ind+2}= [];
    
    obj.match_two_sessions(session1,session2,'ind2cal_1',ind2cal_1,'ind2cal_2',ind2cal_2,...
                                    'W0',W0,'W_final',W_final,'move',1,'max_shift',max_shift);
end
no_neuron_flag=0;