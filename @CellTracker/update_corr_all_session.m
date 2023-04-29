function update_corr_all_session(obj)
% compute FFT of all spatial footprints
obj.update_spatial_fft();

% update pairwise correlations between every two session
for m=1:obj.n_sessions
    for n=m:obj.n_sessions
        if and(isempty(obj.C_all{m, n}),isempty(obj.C_all{n, m}))
            obj.cal_corr(obj,m,n)
        end
    end
end
end