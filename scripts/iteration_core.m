%% iteration core

%% calculate neighbor cost and match
% calculate raw cost
ctr=obj.X_all{session1};
if ~move 
    ctr_=obj.X_all{session2};
else
    ctr_=obj.X_moved_all{session1,session2};
end
n1=obj.n_all{session1};
n2=obj.n_all{session2};
[N,dist_v_self]=obj.cal_neighbor_cost(n1,n2,ctr,ctr_,W_single{it+it_-1},p_method,'ind2cal_1',ind2cal_1_,'ind2cal_2',ind2cal_2_);
N_single{it_+it}=N;
N=N(ind2cal_1_,:);
N=N(:,ind2cal_2_);

if options.strict
    dist_v_self=dist_v_self(ind2cal_1_,W_single{it+it_-1}(:,1));
    
    R_mean=zeros(size(N,1),1);
    for vi=1:size(N,1)
        vi_ind=sort(dist_v_self(vi,:),'ascend'); R_mean(vi)=mean(vi_ind(2:5)); end
    thresh_strict=min(thresh,R_mean.*0.1);
    obj.tmp{session1,session2}{it+it_}=thresh_strict;
    
    W=thresh_low_cost(N,thresh_strict,1); %minimize cost
else
    W=thresh_low_cost(N,thresh,1); %minimize cost
end


if ~isempty(W)
    W=[ind2cal_1_(W(:,1)),ind2cal_2_(W(:,2))];
end
%     if ~isempty(W_final)
%         P1=define_p(ctr,W(:,1),[W_final(:,1); W(:,1)],p_method,obj.options.R,obj.options.d1,obj.options.d2,obj.options.d3);
%     else
%         P1=define_p(ctr,W(:,1),W(:,1),p_method,obj.options.R,obj.options.d1,obj.options.d2,obj.options.d3);
%     end
%     W=W(sum(P1,2)>=1,:);
% end

if IT==1 %another direction
    [N,dist_v_self]=obj.cal_neighbor_cost(n2,n1,ctr_,ctr,W_single{it+it_-1}(:,[2 1]),p_method,'ind2cal_1',ind2cal_2_,'ind2cal_2',ind2cal_1_);
    N=N(ind2cal_2_,:);
    N=N(:,ind2cal_1_);
    
    if options.strict
        dist_v_self=dist_v_self(ind2cal_2_,W_single{it+it_-1}(:,2));
        
        R_mean=zeros(size(N,1),1);
        for vi=1:size(N,1)
            vi_ind=sort(dist_v_self(vi,:),'ascend'); R_mean(vi)=mean(vi_ind(2:5)); end
        thresh_strict=min(thresh,R_mean.*0.1);
        obj.tmp{session2,session1}{it+it_}=thresh_strict;
        
        W_2=thresh_low_cost(N,thresh_strict,1);
    else
        W_2=thresh_low_cost(N,thresh,1);
    end
    
    if ~isempty(W_2)
        W_2=[ind2cal_2_(W_2(:,1)),ind2cal_1_(W_2(:,2))];
    end
%         if ~isempty(W_final)
%             P1=define_p(ctr_,W_2(:,1),[W_final(:,2); W_2(:,1)],p_method,obj.options.R,obj.options.d1,obj.options.d2,obj.options.d3);
%         else
%             P1=define_p(ctr_,W_2(:,1),W_2(:,1),p_method,obj.options.R,obj.options.d1,obj.options.d2,obj.options.d3);
%         end
%         W_2=W_2(sum(P1,2)>=1,:);
%     end
    if and(~isempty(W),~isempty(W_2))
        W=intersect(W,W_2(:,[2 1]),'rows'); %minimize cost
    else
        W=[];
    end
else %single direction is fine

    % Keep only those unique pairs
    all_=1:max(W(:,2)); [count] = histc(W(:,2),all_);
    % Where is greater than one occurence
    [~,~,ia]=intersect(all_(count==1),W(:,2));
    W=W(ia,:);
end


%% check empty and tally this iteration

W_single{it+it_}=[W_final; W];% tally W for this iteration.

if or(size(W_single{it+it_},1)<=1,isempty(W)) %empty result basically
    disp('no neurons found in this mode.'); 
    
    if isempty(W); W_msg_single{it_+it}='In this round W is empty, keeping the same W_final';
    else; W_msg_single{it_+it}='Only one pair, not confident -> discarded.';
    end
    N_single{it_+it+1}=[];
    
    W_single{it_+it+1}=W_final;     % the end of this iteration's record
    W_msg_single{it_+it+1}='End of iteration, used previous W found';
    if ~isempty(W_final)
        try
        N_single{it_+it+2}=obj.cal_neighbor_cost(n1,n2,ctr,ctr_,W_final,p_method,'ind2cal_1',ind2cal_1_,'ind2cal_2',ind2cal_2_);
        catch
            disp('here')
        end
    else
        N_single{it_+it+2}=[];
    end
        
    iteration_core_flag=1; % use 'iteration_core_flag' to end iteration
    return
else
    W_msg_single{it_+it}=['iteration' num2str(it)];
end


%% detecting the end of iteration
% detecting the end of iterations.
if and(isempty(setdiff(W_single{it+it_},W_single{it+it_-1},'rows')),isempty(setdiff(W_single{it+it_-1},W_single{it+it_},'rows')))
    disp(['session (' num2str(session1) ',' num2str(session2) ') Answer Converged'])
    W=refine_W(W,W_single{it+it_},ctr,ctr_,p_method,obj.options);
    W_single{it+it_+1}=[W_final; W]; W_msg_single{it+it_+1}='Answer Converged';
    

    N_single{it_+it+1}=obj.cal_neighbor_cost(n1,n2,ctr,ctr_,W_single{it+it_},p_method,'ind2cal_1',ind2cal_1_,'ind2cal_2',ind2cal_2_);   
        
    N_single{it_+it+2}=obj.cal_neighbor_cost(n1,n2,ctr,ctr_,W_single{it+it_+1},p_method,'ind2cal_1',ind2cal_1_,'ind2cal_2',ind2cal_2_);    
    iteration_core_flag=1;
    return
elseif it>=4
    osci=osci_detector(W_single);
    
    if or(it==nRep,osci) %end of iteration
        % calculate neighbor cost based on the last two W.
        N_single{it_+it+1}=obj.cal_neighbor_cost(n1,n2,ctr,ctr_,W_single{it+it_},p_method,'ind2cal_1',ind2cal_1_,'ind2cal_2',ind2cal_2_);

        if osci; warning(['session (' num2str(session1) ',' num2str(session2) ') Oscillation Detected.'])
        else
            warning(['session (' num2str(session1) ',' num2str(session2) ') Did NOT CONVERGE'])
        end
        if strcmp(options.nonconverge_method,'intersection')
            W_tmp=intersect(W_single{it+it_},W_single{it+it_-1},'rows');%in this case, pick those common in the last two iterations
            W=refine_W(W,W_tmp,ctr,ctr_,p_method,obj.options);
            W_single{it+it_+1}=[W_final; W];
            
            if size(W_single{it+it_+1},1)>1
                W_msg_single{it+it_+1}='Not Converged, picked the intersection of the last two Ws.';
                N=obj.cal_neighbor_cost(n1,n2,ctr,ctr_,W_single{it+it_+1},p_method,'ind2cal_1',ind2cal_1_,'ind2cal_2',ind2cal_2_);
                N_single{it_+it+2}=N;
            else
                W_single{it+it_+1}=[];
                N_single{it_+it+2}=[];
                if size(W_single{it+it_+1},1)==1
                    W_msg_single{it+it_+1}='Not Converged, the intersection of the last two Ws leaves only one row -> discarded.';
                elseif size(W_single{it+it_+1},1)==0
                    W_msg_single{it+it_+1}='Not Converged, the intersection of the last two Ws is empty.';
                end
            end
            
        elseif strcmp(options.nonconverge_method,'min')
            [W_tmp,m]=cal_sum_min(W_single((it_+1):(it+it_)),N_single,thresh,ind2cal_1_,ind2cal_2_);
            W_msg_single{it+it_+1}=['Not Converged, picked the min of all Ws: from iteration ' num2str(m)];
            
            W=refine_W(W,W_tmp,ctr,ctr_,p_method,obj.options);
            W_single{it+it_+1}=[W_final; W];
            N_single{it_+it+2}=obj.cal_neighbor_cost(n1,n2,ctr,ctr_,W_single{it+it_+1},p_method,'ind2cal_1',ind2cal_1_,'ind2cal_2',ind2cal_2_);            
        end
        
        iteration_core_flag=1;
        return
    end
end
iteration_core_flag=0;