function [nchain,nchain_conflict]=chain_neuron(pairs,sizesofeachday)
% Takes in all the pairs of neurons in pairs (neuron ID in abs coordinate),
%   stitch them up, if redundent/conflicting stitching occurs (will not occur in STAT), use the one
%   with the shortest day distance (it is kept for potential use).
% Ouput: a matrix of size
%  (number of neuron chain) x sizes of each day.
% Note: Calls the helper function merge_group_full
%
% Shijie Gu <techel@live.cn>

sizes=cumsum(sizesofeachday);
[MC,MC_dayinfo,~]=merge_group_full(pairs,sizesofeachday);
MC_new=MC;
% for each day, there might be another neuron matched to another neuron in
%   another day:
%   only keep the one with the smallest day distance - MC_new

conflict_ind=false(1,size(MC_dayinfo,2));
for m=1:size(MC_dayinfo,2)
    %%%%
    MC_current=MC(:,m);
    MC_current_split=mat2cell(MC_current,sizesofeachday,1);
    conflict_ind(m)=any(cellfun(@(x) sum(x>0),MC_current_split)>1);
    %%%%
    
%     MC_dayinfo_current=MC_dayinfo(:,m);
%     MC_current_split=mat2cell(MC_dayinfo_current,sizesofeachday,1);
%     
%     %MC_new(:,m)=cell2mat(cellfun(@(x) sum(x>0),MC_current_split,'UniformOutput',false));
%     
%     MC_new(:,m)=cell2mat(cellfun(@(x) x==min(x),MC_current_split,'UniformOutput',false));
%     
end
%   MC_new=MC.*MC_new; %This line is necessary: NaN=min(NaN,NaN)

nchain=zeros(sum(~conflict_ind),numel(sizesofeachday));
nchain_conflict=cell(sum(conflict_ind),numel(sizesofeachday));

MC_new=MC(:,~conflict_ind);
MC_conflict=MC(:,conflict_ind);
for i=1:sum(~conflict_ind)
    days=arrayfun(@(x) find(x<=sizes,1),find(MC_new(:,i)));
    nchain(i,days')=find(MC_new(:,i));
end

for i=1:sum(conflict_ind)
    MC_split=mat2cell(MC_conflict(:,i),sizesofeachday,1);
    MC_split=cellfun(@(x) find(x),MC_split,'UniformOutput',false);
    nchain_conflict(i,:)=MC_split';    
end