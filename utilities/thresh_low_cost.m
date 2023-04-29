function [W,flag]=thresh_low_cost(N,thresh,dim)
% Given the cost function and threshold, find the match matrix.
% flag=1 or 0, reflecting if W is empty or no.
% Shijie Gu

if dim==1
    i=reshape(1:size(N,1),[],1);
    [minN,j]=min(N,[],2); %for each neuron in row, find its best match by finding the lowest neighbor cost
    ia=minN<thresh;      % minN has to be small, otherwise the pair does not count in this iteration.
    W=[i(ia),j(ia)];   
    if isempty(W); flag=0; return; end
elseif dim==2
    j=reshape(1:size(N,2),[],1);
    [minN,i]=min(N,[],1); %for each neuron in column, find its best match by finding the lowest neighbor cost
    i=reshape(i,[],1);
    ia=minN<thresh;      % minN has to be small, otherwise the pair does not count in this iteration.
    W=[i(ia),j(ia)];
    if isempty(W); flag=0; return; end
end


% if dim==12
%     W_1=thresh_low_cost(N,thresh,1);
%     W_2=thresh_low_cost(N,thresh,2);
%     if or(isempty(W_1),isempty(W_2))
%         W=[]; flag=0; return;
%     else
%         W=intersect(W_1,W_2,'rows');
%     end
% elseif dim==1
%     %% Keep only those unique pairs
%     all_=1:max(j(ia)); [count] = histc(j(ia),all_);
%     % Where is greater than one occurence
%     [~,~,ia]=intersect(all_(count==1),j(ia));
%     W=W(ia,:);
%     if isempty(W); flag=0; return; end
% elseif dim==2
%     %% Keep only those unique pairs
%     all_=1:max(i(ia)); [count] = histc(i(ia),all_);
%     % Where is greater than one occurence
%     [~,~,ia]=intersect(all_(count==1),i(ia));
%     W=W(ia,:);
%     if isempty(W); flag=0; return; end
% end
flag=1;