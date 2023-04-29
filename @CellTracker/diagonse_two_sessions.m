function [unpaired_1,unpaired_2,flag]=diagonse_two_sessions(obj,session1,session2,all_sessions)
% find matched neurons and unmatched neurons for a pair of sessions.

% Shijie Gu
%%
[neuron_chain,~,all_sessions]=object2result(obj,all_sessions);

[~,session1_ind]=ismember(session1,all_sessions);
[~,session2_ind]=ismember(session2,all_sessions);
n1=obj.n_all{session1};
n2=obj.n_all{session2};

%% finds unpaired neurons between dc and dr

emptyrows=sum(neuron_chain(:,[session1_ind,session2_ind])>0,2)<2;         % find broken neuron-chains
pairedrows=sum(neuron_chain(:,[session1_ind,session2_ind])>0,2)==2;         % find pairs

if sum(pairedrows)>0
    W_final=[neuron_chain(~emptyrows,[session1_ind session2_ind])];
    obj.W_final_all{session1,session2}=W_final;
    obj.W_final_all{session2,session1}=W_final(:,[2 1]);
    
    unpaired_1=reshape(setdiff(reshape(1:n1,[],1),W_final(:,1)),[],1);
    unpaired_2=reshape(setdiff(reshape(1:n2,[],1),W_final(:,2)),[],1);
else
    unpaired_1=reshape(1:n1,[],1);
    unpaired_2=reshape(1:n2,[],1);
end

if and(~isempty(unpaired_1),~isempty(unpaired_2))
    flag=true;
end
