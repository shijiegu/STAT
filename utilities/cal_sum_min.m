function [W_min,it]=cal_sum_min(W_single,N_single,theta,ind_1,ind_2)
% calculate the sum of all the costs as in the manuscript.
% Input: ind_1 and ind_2 will specify the range of sum.
% Output: W_min is the W that has the min cost.
%         "it" is the iteration(index) in the obj.W_all{session1,session2}
%         that gives the W_min
%
% Shijie Gu


ind_bg=find(~cellfun(@isempty, W_single),1);
ind_ed=find(~cellfun(@isempty, W_single),1,'last');
ind_range=ind_bg:ind_ed;
sizeN=size(N_single{ind_bg+1});
M=zeros(1,length(ind_range));

for i=1:length(ind_range)
    it=ind_range(i);
    w=W_single{it};
    n=N_single{it+1};
    [~,w_1,ind_1_]=intersect(w(:,1),ind_1);
    [~,w_1,ind_2_]=intersect(w(w_1,2),ind_2,'stable');
    ind = sub2ind(sizeN, ind_1(ind_1_(w_1)), ind_2(ind_2_));
    if ~isempty(n)
        picked_value=n(ind);
        ind_isnan=isnan(picked_value); %in 'cal_neighbor_cost',
                                       % 'nan' is applied to both non-match
                                       %   and the non-matched neighbor case.
        ind_large=picked_value>theta;
        picked_value(ind_isnan)=theta;
        picked_value(ind_large)=theta;
        non_match=length(ind_1)-length(ind);
        M(i)=sum(picked_value)+non_match*theta;
    else
        M(i)=length(ind_1)*theta;
    end
end
if sum(isnan(M))>=1
    error('M has nan value. Neighborhood cost is calculated wrong.')
end
[~,i]=min(M);
it=ind_range(i); 
W_min=W_single{it};