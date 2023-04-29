function [N,dist_v_self]=cal_neighbor_cost(obj,n1,n2,ctr,ctr_,W,p_method,varargin)

% This is the function that calculates neighbor cost.
% if provided 'ind2cal_1' and 'ind2cal_2', only those neurons' N will be
% calculated, and other entries are left as zero

% Shijie Gu

if size(W,1)<=1
    error('Zero or only one pair of matched neurons. Neighborhood cost does not apply. \n',...
        'Please re-do initiatiation.')
end

p = inputParser;
addParameter(p,'ind2cal_1',1:n1);
addParameter(p,'ind2cal_2',1:n2);

parse(p, varargin{:});
ind2cal_1=p.Results.ind2cal_1;
ind2cal_2=p.Results.ind2cal_2;

options=obj.options;
R=options.R;
d1=options.d1;
d2=options.d2;
d3=options.d3;

% Give each neuron j(in column),(those in W) a weight based on how close it is to the neuron i(in row),(all of the A's).
P1=define_p(ctr,ind2cal_1,W(:,1),p_method,R,d1,d2,d3);

% calculate distance between neuron i in session 1 and neuron j in session 2.
yy = ctr(:,1); xx = ctr(:,2);
yy_ = ctr_(:,1); xx_ = ctr_(:,2);
if d3~=1
    zz = ctr(:,3); zz_ = ctr_(:,3);
else
    zz=zeros(length(yy),1); zz_=zeros(length(yy_),1);
end
dist_v = sqrt(bsxfun(@minus, xx, xx_').^2 + bsxfun(@minus, yy, yy_').^2 + bsxfun(@minus, zz, zz_').^2);
dist_v = dist_v(ind2cal_1,ind2cal_2);
dist_v_b = dist_v<=obj.options.max_shift*2;

dist_v_self = sqrt(bsxfun(@minus, xx, xx').^2 + bsxfun(@minus, yy, yy').^2 + bsxfun(@minus, zz, zz').^2);

%%% calculate neighborhood N
% N(i,j): assume neuron i in session1 and neuron j in session2 match.
N=NaN(n1,n2);
for ni=1:length(ind2cal_1)
    i=ind2cal_1(ni);
    ie_1=W(:,1)~=i;    % neurons in session 1 other than neuron i
    
    if sum(P1(ni,:))==0
        if sum(~ie_1)==1
            j=W(W(:,1)==i,2);
            N(i,j)=0;
        end
        continue
    end
    
    %only consider neurons within a distance
    ind2cal_2_crop=ind2cal_2(dist_v_b(ni,:));
    for nj=1:length(ind2cal_2_crop)
        j=ind2cal_2_crop(nj);
        arrow_center=ctr(i,:)-ctr_(j,:);
        % Step2 follows
        ie_2=W(:,2)~=j; % neurons in session 2 other than neuron j
        ie=ie_1.*ie_2>0;
        neighbor_pairs=W(ie,:);
        arrow_neighbor=ctr(neighbor_pairs(:,1),:)-ctr_(neighbor_pairs(:,2),:);
        
        %             endpoint=W(ie_1(ie_2),1);      % imaging these neurons in session 1 surround neuron i, with neuron i being the center and they are endpoints
        %             arrow_1=[ones(size(endpoint,1),1).*i endpoint];
        %             arrow_1=ctr(arrow_1(:,1),:)-ctr(arrow_1(:,2),:); % ctr_ref(ii) is the vector from the center to endpint(ii)
        %
        %             % same for session 2
        %             endpoint=W(ie_1(ie_2),2);
        %             arrow_2=[ones(size(endpoint,1),1).*j endpoint];
        %             arrow_2=ctr_(arrow_2(:,1),:)-ctr_(arrow_2(:,2),:);
        
        p_ref=P1(ni,ie);%not i
        p=p_ref/sum(p_ref);
        
        % compare pairs of radiating vectors in session 1 and session2, calculate
        % the difference vector between pairs, and get the L2 norm of each. Then
        % take the mean of all the L2 norms.
        
        temp = bsxfun(@minus, arrow_neighbor, arrow_center);
        N_paired=sqrt(sum(temp.^2,2))'*p'; % mean      
        N(i,j)=N_paired;
    end
    
end