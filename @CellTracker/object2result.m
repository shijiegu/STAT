function [neuron_chain,neuron_chain_new,neuron_chain_conflict,session_ind]=object2result(obj,session_ind)
% Concatenate results from all the pairwise matches in the designated sessions
% 'neuron_chain': each row corresponds to one single neuron's indeces in each session (in columns)
%   (sessions in columns, neurons ID in each session in rows)
%   For neurons missing in certain days,
%   they are shown as zero.
% 'neuron_chain_new' is one that excludes those rows with zeros: each row of 
%   the neuron_chain_new is a chain with neurons found in every session.
% 'session_ind': the session indeces in obj.session_ids.
% Shijie Gu
%% handling character indexing
all_sessions=obj.id2ind(session_ind);

%% making the chain (call chain_neuron.m)

all_session_pairs=nchoosek(all_sessions,2);
all_pairs=[];
for i=1:size(all_session_pairs,1)
    if ~isempty(obj.paired_all{all_session_pairs(i,1),all_session_pairs(i,2)})
        all_pairs=[all_pairs; obj.paired_all{all_session_pairs(i,1),all_session_pairs(i,2)}];
    end
end

sizesofeachday=cell2mat(obj.n_all(1:max(all_sessions)));
sizes_sum=[0; cumsum(sizesofeachday)];
sizes_sum=sizes_sum(all_sessions);

[neuron_chain,neuron_chain_conflict]=chain_neuron(all_pairs,sizesofeachday);% make a table of neuron-chains using all the neuron pairs

[~,ia,ib]=intersect(all_sessions,1:max(all_sessions));
[~,ia_]=sort(ia,'ascend');
ia=ia(ia_);        ib=ib(ia_);
neuron_chain=neuron_chain(:,ib);
neuron_chain_conflict=neuron_chain_conflict(:,ib);
session_ind=all_sessions(ia);

neuron_chain=bsxfun(@minus, neuron_chain, reshape(sizes_sum(ia),1,[]));
neuron_chain(neuron_chain<0)=0;

neuron_chain_new=neuron_chain(sum(neuron_chain>0,2)==size(neuron_chain,2),:);
