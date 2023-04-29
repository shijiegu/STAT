function cm = get_centers(A)

% center of mass calculation
% inputs:
% A: d1 X d2 (X d3) X nr matrix, each column in the spatial footprint of a neuron

% output:
% cm: nr x 2 (or 3) matrix, with the center of mass coordinates

%% the code is modified from https://github.com/flatironinstitute/CaImAn-MATLAB/blob/master/utilities/com.m

%% author: Pengcheng Zhou 

dims = size(A); 
nr = dims(end); 

d1 = dims(1); 
d2 = dims(2); 

if length(dims)==4
    d3 = dims(3); 
    ndim = 3;
else
    d3 = 1; 
    ndim = 2; 
end

A = reshape(A, [], nr); 
Coor.x = kron(ones(d2*d3,1),(1:d1)');
Coor.y = kron(ones(d3,1),kron((1:d2)',ones(d1,1)));
Coor.z = kron((1:d3)',ones(d2*d1,1));
cm = [Coor.x, Coor.y, Coor.z]'*A/spdiags(sum(A)',0,nr,nr);
cm = cm(1:ndim,:)';
cm(cm<0) = 0; 
cm(cm(:,1)>d1, 1) = d1; 
cm(cm(:,2)>d2, 2) = d2; 