function obj=copy_results_re(obj,session_ind,...
    N_all,W_all,W_msg_all,W_final_all,X_moved_all,D_moved_all)
% this function is for 'parfor', called in match_sessions()

retronum=obj.options.retronum;
for j=2:length(session_ind)
    session2=session_ind(j);
    for k=1:min(retronum,j-1)
        session1=session_ind(j-k);
        obj.N_all{session1,session2}=N_all{j,k};
        obj.W_all{session1,session2}=W_all{j,k};
        obj.W_msg_all{session1,session2}=W_msg_all{j,k};

        obj.W_final_all{session1,session2}=W_final_all{j,k};
        obj.W_final_all{session2,session1} =reorder(W_final_all{j,k});
        
        paired=Convert2AbsoluteCoordinate(W_final_all{j,k},session1,session2,obj.n_all);
        obj.paired_all{session1,session2}=paired;
        obj.paired_all{session2,session1}=reorder(paired);
        
        obj.X_moved_all{session1,session2}=X_moved_all{j,k};
        obj.D_moved_all{session1,session2}=D_moved_all{j,k};
    end
end
