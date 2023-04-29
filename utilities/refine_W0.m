function W0_both=refine_W0(W0,W_final)
% refine W0, take out any neurons that are in W_final_
if and(~isempty(W_final),~isempty(W0))
    W0_both=unique([W0; W_final],'rows');
    all_=1:max(W0_both(:,1)); [count] = histc(W0_both(:,1),all_);
    [~,~,ia]=intersect(all_(count==1),W0_both(:,1));
    all_=1:max(W0_both(:,2)); [count] = histc(W0_both(:,2),all_);
    [~,~,ib]=intersect(all_(count==1),W0_both(:,2));
    ic=intersect(ia,ib);
    if ~isempty(ic)
        W0_both=W0_both(ic,:);
        W0_both=setdiff(W0_both,W_final,'rows');
    else
        W0_both=[];
    end
elseif isempty(W0)
    W0_both=[];
elseif isempty(W_final)
    W0_both=W0;
end