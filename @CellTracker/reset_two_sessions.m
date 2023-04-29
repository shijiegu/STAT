function reset_two_sessions(obj,session1,session2)
    obj.N_all{session1,session2}={};        obj.N_all{session2,session1}={};   
    obj.W_all{session1,session2} = {};      obj.W_all{session2,session1} = {};
    obj.W_msg_all{session1,session2} = {};      obj.W_msg_all{session2,session1} = {};
    obj.W_final_all{session1,session2} = [];obj.W_final_all{session2,session1} = [];
    obj.paired_all{session1,session2} = []; obj.paired_all{session2,session1} = [];
    obj.tmp{session1,session2}={};          obj.tmp{session2,session1}={};
end