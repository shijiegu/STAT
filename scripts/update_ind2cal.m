%% update ind2cal
if ~isempty(W_final) %not changing those matched already
    ind2cal_1_=reshape(setdiff(ind2cal_1,W_final(:,1)),[],1);
    ind2cal_2_=reshape(setdiff(ind2cal_2,W_final(:,2)),[],1);
else
    ind2cal_1_=ind2cal_1; 
    ind2cal_2_=ind2cal_2;
end