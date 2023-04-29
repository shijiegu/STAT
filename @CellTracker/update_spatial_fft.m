function update_spatial_fft(obj, session_id)
%% compute the FFT for all spatial footprints

if ~exist('session_id', 'var')||isempty(session_id)
    session_id=1:obj.n_sessions; 
end

session_id=obj.id2ind(session_id);

w = obj.options.crop_width;
d1 = obj.options.d1;
d2 = obj.options.d2;
d3 = obj.options.d3;
if (d3==1) && (numel(w)==1)
    w = [w, w];
else
    w = [w, w, w];
end
w = reshape(w, 1, []); %make sure it is a row vector
cdims = 4*w+1;

% calculate a boundary of neuron centers
ctr_min = w + 1;
if d3==1
    ctr_max = [d1, d2] - w;
else
    ctr_max = [d1, d2, d3] - w;
end

%
for mm=1:length(session_id)
    m=session_id(mm);
    if ~isempty(obj.FFT_all_1{m}) % skip this session
        continue;
    end

    tmp_A = obj.A_all{m};
    tmp_X = round(obj.X_all{m});
    K = size(tmp_X, 1);
    FFT_1 = zeros([cdims, K], 'like', complex(0));
    FFT_2 = zeros([cdims, K], 'like', complex(0));
    
    for n=1:K
        if d3==1
            ai = tmp_A(:,:,n);
        else
            ai = tmp_A(:,:,:,n);
        end
        % neuron center
        ctr = round(tmp_X(n, :));
        ctr = max(ctr, ctr_min);
        ctr = min(ctr, ctr_max);
        
        % crop neuron
        if d3==1
            ai_crop = ai(ctr(1)+(-w(1):w(1)), ctr(2)+(-w(2):w(2)));
        else
            ai_crop = ai(ctr(1)+(-w(1):w(1)), ctr(2)+(-w(2):w(2)), ctr(3)+(-w(3):w(3)));
        end
        
        % normalize neuron
        ai_crop = ai_crop / sqrt(sum(ai_crop(:).^2));
        
        % pad neuron and compute FFT
        ai_pad1 = zeros(cdims);
        ai_pad2 = zeros(cdims);
        
        if d3==1
            ai_pad1(1:(2*w(1)+1), 1:(2*w(2)+1)) = ai_crop;
            ai_pad2(1:(2*w(1)+1), 1:(2*w(2)+1)) = ai_crop(end:-1:1, end:-1:1);
            FFT_1(:, :, n) = fft2(ai_pad1);
            FFT_2(:, :, n) = fft2(ai_pad2);
        else
            ai_pad1(1:(2*w(1)+1), 1:(2*w(2)+1), 1:(2*w(3)+1)) = ai_crop;
            ai_pad2(1:(2*w(1)+1), 1:(2*w(2)+1), 1:(2*w(3)+1)) = ai_crop(end:-1:1, end:-1:1, end:-1:1);
            FFT_1(:, :, :, n) = fftn(ai_pad1);
            FFT_2(:, :, :, n) = fftn(ai_pad2);
        end
    end
    obj.FFT_all_1{m} = FFT_1;
    obj.FFT_all_2{m} = FFT_2;
end
end