function last_ind=tally_W_final(obj,session1,session2,W_final,msg)

last_ind=find(~cellfun(@isempty,obj.W_msg_all{session1,session2}),1,'last');
paired=Convert2AbsoluteCoordinate(W_final,session1,session2,obj.n_all);

obj.W_msg_all{session1,session2}{last_ind+1}=msg;
obj.W_all{session1,session2}{last_ind+1}=W_final;

obj.W_final_all{session1,session2} = W_final; 
obj.W_final_all{session2,session1} =reorder(W_final);

obj.paired_all{session1,session2} = paired;
obj.paired_all{session2,session1} = reorder(paired);