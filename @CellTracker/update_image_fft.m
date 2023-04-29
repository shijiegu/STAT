function update_image_fft(obj, session_id)
% calculate each image/volumn's fft

if ~exist('session_id', 'var')||isempty(session_id)
    session_id=1:obj.n_sessions; 
end

session_id=obj.id2ind(session_id);

for mm=1:length(session_id)
    m=session_id(mm);
    if ~isempty(obj.FFT_image_all_1{m}) % skip this session
        continue;
    end
    
    tmp_A = obj.A_all{m};
    d1=size(tmp_A,1);
    d2=size(tmp_A,2);
    d3=obj.options.d3;
    if d3==1
        tmp_A=sum(tmp_A,3);
    else
        tmp_A=sum(tmp_A,4);
    end
    tmp_A=tmp_A./(sqrt(sum(tmp_A(:).^2)));
    
    cdims=2.*size(obj.A_all{m})+1;  cdims(end)=[];
    FFT_1 = zeros(cdims, 'like', complex(0));
    FFT_2 = zeros(cdims, 'like', complex(0));
        
    A_pad1=zeros(cdims);
    A_pad2=zeros(cdims);
    
    if d3==1
        A_pad1(1:d1, 1:d2) = tmp_A;
        A_pad2(1:d1, 1:d2) = tmp_A(end:-1:1,end:-1:1);
        FFT_1(:, :) = fft2(A_pad1);
        FFT_2(:, :) = fft2(A_pad2);
    else
        A_pad1(1:d1, 1:d2, 1:d3) = tmp_A;
        A_pad2(1:d1, 1:d2, 1:d3) = tmp_A(end:-1:1,end:-1:1,end:-1:1);
        FFT_1(:, :, :) = fftn(A_pad1);
        FFT_2(:, :, :) = fftn(A_pad2);
    end
    
    obj.FFT_image_all_1{m} = FFT_1;
    obj.FFT_image_all_2{m} = FFT_2; 
end