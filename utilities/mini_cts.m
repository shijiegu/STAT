function OBJ=mini_cts(session_ind,obj,m)
% this function is for 'parfor', called in match_sessions()
% Two tracks:
% (a) if two inputs, it expects session_ind,Cell Tracker Object
%       output is a cell array
% (b) if three inputs, it expects session_ind,ct.options,m
%       output is a single small object.
% Shijie Gu, shijiegu@berkeley.edu

if nargin<3
    retronum=obj.options.retronum; 
    OBJ=cell(obj.n_sessions);
    for j=2:length(session_ind)
        session2=session_ind(j);
        for k=1:min(retronum,j-1)
            session1=session_ind(j-k);
            
            obj_ = CellTracker(2);
            obj_.add_sessions(obj.A_all([session1,session2]));
            obj_.options=obj.options;
            
            OBJ{session1,session2}=obj_.copy();
        end
    end

else
    d1=obj.d1; d2=obj.d2; d3=obj.d3;
    A_=cell(1,2);
    session1=session_ind(1);
    session2=session_ind(2);
    session1_data=['m.Data.A' num2str(session1)];
    session2_data=['m.Data.A' num2str(session2)];
    eval(['A1_=' session1_data ';']);
    eval(['A2_=' session2_data ';']);
    if d3==1
        A_{1}=reshape(A1_,d1,d2,[]);
        A_{2}=reshape(A2_,d1,d2,[]);
    else
        A_{1}=reshape(A1_,d1,d2,d3,[]);
        A_{2}=reshape(A2_,d1,d2,d3,[]);
    end
    obj_ = CellTracker(2);
    obj_.add_sessions(A_);
    obj_.options=obj;
    OBJ=obj_.copy();
end
