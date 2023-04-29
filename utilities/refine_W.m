function W=refine_W(W2update,W_all,ctr,ctr_,p_method,options)
%W_tmp=W_single{it+it_};
P1=define_p(ctr,W2update(:,1),W_all(:,1),p_method,options.R,options.d1,options.d2,options.d3);
P2=define_p(ctr_,W2update(:,2),W_all(:,2),p_method,options.R,options.d1,options.d2,options.d3);
id_keep=or(sum(P1,2)>=1,sum(P2,2)>=1);
W=W2update(id_keep,:);