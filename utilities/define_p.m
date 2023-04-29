function p=define_p(X,ind,w,method,R,d1,d2,d3)
% This function defines the weight of each neuron in the w for neurons in the ind,
% weight p is of size length(ind)xlength(w);
% Note: The weight is not normalized to sum of 1, that is, it only shows relative weights.
% This function calls another helper function 'define_neighborhood' when the method is "hard"
%   or "hard_flexible"
%
% Shijie Gu

p=zeros(length(ind),size(w,1)); %each neuron i's p's for all i* are in ith row

if strcmp(method,'hard')
    %%% define neighborhood: each neuron has a set of neurons being its neighborhood.
    n_ref=define_neighborhood(X,w,R,d1,d2,d3,'ind2cal',ind);
elseif strcmp(method,'hard_flexible')
    n_ref=define_neighborhood(X,w,R,d1,d2,d3,'ind2cal',ind,'expand_or_no',true);
elseif strcmp(method,'nearest_neighbor')
    yy = X(:,1);
    xx = X(:,2);
    if d3~=1
        zz = X(:,3);
    else
        zz=zeros(length(yy),1);
    end
    dist_v = sqrt(bsxfun(@minus, xx, xx').^2 + bsxfun(@minus, yy, yy').^2 + bsxfun(@minus, zz, zz').^2);
    dist_v = dist_v(:,w);
    for n=1:length(ind)
        [~,ia]=sort(dist_v(ind(n),:),'descend');
        p(n,ia(1:R))=1;
    end    
end

if or(strcmp(method,'hard'),strcmp(method,'hard_flexible'))
    for i=1:length(ind)
        tmp=n_ref{i};
        p(i,tmp)=1;
    end
end

if strcmp(method,'gaussian')
    yy = X(:,1);
    xx = X(:,2);
    if d3~=1 
        zz = X(:,3);
    else 
        zz=zeros(length(yy),1);
    end
    [~,ia,ib]=intersect(1:size(X,1),w);
    dist_v = sqrt(bsxfun(@minus, xx, xx').^2 + bsxfun(@minus, yy, yy').^2 + bsxfun(@minus, zz, zz').^2);
    
    for i=1:length(ind)
        if ismember(ind(i),w) %only those neurons that have matches can have defined neighbor weights.
            p(i,ib)= normpdf(dist_v(ind(i),ia),0,R);
        end
    end    
    
end
    
