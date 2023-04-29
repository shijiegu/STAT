function D=tform2D(tform,d1,d2)
% make a displacement field that corresponds to MATLAB's tform object
% not used in STAT, but kept here for potential use.

[X,Y] = meshgrid(1:d2,1:d1); % make grids with x and y coordinates of pixels
[XT,YT] = transformPointsForward(tform,X,Y); % Transform pixel coordinates using tform
D = zeros(d1,d2,2);
D(:,:,1) = XT-X; % displacement field should be the difference!? 
D(:,:,2) = YT-Y;