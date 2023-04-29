function [vect,X2_moved,A2_moved]=max_xcross(sizes,A1_fft,A2_fft,X2,A2)
% return the translation vector for maximizing the cross-correlation
%   between A1 and A2: the vector moves A2 onto A1.
% This function can be used to roughly rigidly 'motion correct' data before using
%   'STAT'.
% Input: 
%        sizes: sizes of each session's image;
%           d1=sizes(1); d2=sizes(2); d3=sizes(3);
%        A1_fft: the fft of zero padded A1, 
%           with the whole zero-padded A1 of size (2*d1+1)*(2*d2+1)[*(2*d3+1)];
%        A2_fft: the fft of zero padded A2, but in conjugate
% Shijie Gu, techel@live.cn

if nargin<4 || isempty(X2)
    X2=[];
end
if nargin<5 || isempty(A2)
    A2=[];
end
d1=sizes(1); d2=sizes(2); d3=sizes(3);

if d3==1
    cb_ref = imref2d([d1,d2]);
else
    cb_ref = imref3d([d1,d2,d3]);
end
c = real(ifftn(A1_fft.*A2_fft));
[~,ind]=max(c(:));
if d3==1
    [ia,ib]=ind2sub(size(c),ind);
    d1_change=ia-d1;   d2_change=ib-d2;
    vect = [d1_change d2_change];
else
    [ia,ib,ic]=ind2sub(size(c),ind);
    d1_change=ia-d1;   d2_change=ib-d2; d3_change=ic-d3;
    vect = [d1_change d2_change d3_change];
end

if ~isempty(X2)
    X2_moved=X2+repmat(vect,size(X2,1),1);
else
    X2_moved=[];
end

A2_moved=zeros(size(A2));
if ~isempty(A2)
    if d3==1
        tform=affine2d([1 0 0; 0 1 0; vect(2) vect(1) 1]);
        for n=1:size(A2,3)
            A2_moved(:,:,n)=imwarp(A2(:,:,n),tform,'OutputView',cb_ref);
        end
    else
        tform=affine3d([1 0 0 0; 0 1 0 0; 0 0 1 0; vect(2) vect(1) vect(3) 1]);
        for n=1:size(A2,4)
            A2_moved(:,:,:,n)=imwarp(A2(:,:,:,n),tform,'OutputView',cb_ref);
        end
    end
end
