function [MC,MC_dayinfo,mergegroups]=merge_group_full(list,sizesofeachday)
% MC is a matrix of zeros (total neuron number) x (number of pairs), except
%   those neurons pair in one pair(column) will have 1's in their entries.
% MC_dayinfo: Same format as MC, except from being 1's in entries,
%   each entries is now abs(day number(session number) difference) between the
%   neurons in each pair(column),
%   and NaN's are used to filled in the rest of entries rather than using 0.
% Mergegroup is mainly for debug. Cell array of size 1 x (number of pairs).
%   Each cell contains candidate neuron ID in that 'pair'
%
% Shijie Gu <techel@live.cn>
MC=[];
MC_dayinfo=[];
mergegroups={};
sizes=cumsum(sizesofeachday);
totalnum=sizes(end);

for i=1:size(list,1)
        ind_temp_2=list(i,:);
        day_dist=abs(find(ind_temp_2(1)<=sizes,1)-find(ind_temp_2(2)<=sizes,1));
        
        % see if any member of this incoming pair has been paired before.
        mergegroups_intersect = cellfun(@(x) intersect(x,ind_temp_2),mergegroups,'UniformOutput', false);
        mergegroups_idx = find(~cellfun('isempty',mergegroups_intersect));
        if ~isempty(mergegroups_idx)
            % add to pre-existing group
            mergegroups{mergegroups_idx(1)}=unique(cat(2,ind_temp_2,mergegroups{mergegroups_idx}));
            % fill in MC
            MC(:,mergegroups_idx(1))=sum(MC(:,mergegroups_idx),2)>0;
            MC(ind_temp_2(1),mergegroups_idx(1))=true;
            MC(ind_temp_2(2),mergegroups_idx(1))=true;
            
            MC_dayinfo(:,mergegroups_idx(1))=min(MC_dayinfo(:,mergegroups_idx),[],2);            
            MC_dayinfo(ind_temp_2(1),mergegroups_idx(1))=min(MC_dayinfo(ind_temp_2(1),mergegroups_idx(1)),day_dist);
            MC_dayinfo(ind_temp_2(2),mergegroups_idx(1))=min(MC_dayinfo(ind_temp_2(2),mergegroups_idx(1)),day_dist);
            
            if length(mergegroups_idx)>1
                mergegroups(mergegroups_idx(2:end))=[];
                MC(:,mergegroups_idx(2:end))=[];
                MC_dayinfo(:,mergegroups_idx(2:end))=[];
            end
        else
            mergegroups{end+1}=ind_temp_2;
           
            new=false(totalnum,1);new(ind_temp_2)=true;
            MC=[MC,new];
            
            new_dayinfo=NaN(totalnum,1); %min(NaN,2)=2
            new_dayinfo(ind_temp_2(1))=day_dist; new_dayinfo(ind_temp_2(2))=day_dist;
            MC_dayinfo=[MC_dayinfo,new_dayinfo]; 
        end
end