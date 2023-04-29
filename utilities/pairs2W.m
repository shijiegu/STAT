function W=pairs2W(pairs,n1,n2)
% column 1 in pairs corresponds to session 1, which has n1 neurons.
% column 2 in pairs corresponds to session 2, which has n2 neurons.

W=zeros(n1,n2);
W(sub2ind([n1,n2],pairs(:,1),pairs(:,2)))=1;