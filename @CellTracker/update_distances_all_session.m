function update_distances_all_session(obj)
         
% update pairwise correlations between every two session
for m=1:obj.n_sessions
    for n=m:obj.n_sessions
        if and(isempty(obj.D_all{m, n}),isempty(obj.D_all{n, m}))
            obj.cal_dist(obj, m,n)
        end
    end
end
end