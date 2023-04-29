function n_ind=define_neighborhood(X,w,R,d1,d2,d3,varargin)
% n_ind is a cell array, 1*length(number of neurons to calculate). n_ind{i} the nearby 
%    neurons(neighborhood) in the index of w defined for neuron i.
% If allow expand,
%   It finds at least two matched neurons in R first,
%   if it can find them,
%       neighborhood is defined as all the neurons in R.
%   if it cannot find at least 2,
%       R will be increased to 1.1*R until there are two matched neurons found.
%       neighborhood is defined as all the neurons in R.
%
% Shijie Gu

p = inputParser;
addParameter(p,'ind2cal',1:size(X,1));
addParameter(p,'expand_or_no',0);
parse(p, varargin{:});
ind=p.Results.ind2cal;
expand_or_no=p.Results.expand_or_no;

n_ind=cell(1,length(ind));
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
    ind_n_w=find(w==ind(n));
    if ~isempty(ind_n_w); ind_n=ind_n_w; else; ind_n=0; end
    R_=R;
    if expand_or_no
        tmp=find(dist_v(ind(n),:)<=R_);
        tmp=tmp(tmp~=ind_n);
        unfound=numel(tmp)<3;
        while unfound %2 others
            R_=1.1*R_;
            tmp=find(dist_v(ind(n),:)<=R_);
            tmp=tmp(tmp~=ind_n);
            unfound=numel(tmp)<3;
            if or(R_>d1,R_>d2)
                break
            end
        end
    end
    tmp=find(dist_v(ind(n),:)<=R_);
    try
    n_ind{n}=tmp(tmp~=ind_n);
    catch
    end
end