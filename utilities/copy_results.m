function [N_all,W_all,W_msg_all,...
    W_final_all,X_moved_all,D_moved_all]=copy_results(obj,session1,session2)
% this function is for 'parfor'

fields_to_copy={'N_all','W_all','W_msg_all',...
    'W_final_all','X_moved_all','D_moved_all'};

if isempty(session1)
    for fi=1:numel(fields_to_copy)
        eval([fields_to_copy{fi} '=obj.' fields_to_copy{fi} ';']);
    end
    
else
    for fi=1:numel(fields_to_copy)
        eval([fields_to_copy{fi} '=obj.' fields_to_copy{fi} '{session1,session2};']);
    end
end