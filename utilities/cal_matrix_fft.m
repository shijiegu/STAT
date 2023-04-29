function ffta=cal_matrix_fft(a,cdim)
adim = size(a);

if length(cdim)==1
    cdim=[cdim(1) cdim(2)];
end
apad = zeros(cdim);

if length(cdim)==2   
    apad(1:adim(1),1:adim(2)) = a;
    ffta = fft2(apad);
else % 3d
    apad(1:adim(1),1:adim(2),1:adim(3)) = a;
    ffta = fft3(apad);
end

% % Matrix dimensions
% adim = size(a);
% bdim = size(b);
% % Cross-correlation dimension
% cdim = adim+bdim-1;
% 
% bpad = zeros(cdim);
% apad = zeros(cdim);
% 
% 
% bpad(1:bdim(1),1:bdim(2)) = b(end:-1:1,end:-1:1);
% 
% fftb = fft2(bpad);
% c = real(ifft2(ffta.*fftb));