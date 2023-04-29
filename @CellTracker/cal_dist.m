function [D, ord] = cal_dist(obj, session1,session2,varargin)
%% calculate the distances of neuron centers
%% inputs:
%   from the onject and session1,session2
%           ctr1: N1 * ndims matrix
%           ctr2: N2 * ndims matrix
%   varargin's 'Name,Value' pair can be
%           'ind2cal_1',ind2cal_1,'ind2cal_2',ind2_cal2
%           In this case, this function will only caluculate these neurons
%           'move', true or false. If true, it will use obj.X_moved_all

%% outputs:
%   D: N1*N2 matrix
%   ord: order, either [1 2] or [2 1], denoting which side of the matrix
%       session1 and session2 are on. [1 2]: Session1 is on the left side
%       (in row) and session2 in column.

%% author
% Shijie Gu & Pengcheng Zhou

%% Input parsing
N1=obj.n_all{session1};
N2=obj.n_all{session2};
p = inputParser;
addParameter(p,'ind2cal_1',1:N1);
addParameter(p,'ind2cal_2',1:N2);
addParameter(p,'move',0);
parse(p, varargin{:});
ind2cal_1=sort(p.Results.ind2cal_1,'ascend');
ind2cal_2=sort(p.Results.ind2cal_2,'ascend');
move=p.Results.move;

%%
% get data dimension
if move
    ctr1=obj.X_all{session1};
    ctr2=obj.X_moved_all{session1,session2};
else
    X_all=obj.X_all; ctr1=X_all{session1}; ctr2=X_all{session2};
end


[N1, ndims] = size(ctr1);
N2 = size(ctr2, 1);
D = zeros(N1,N2);
D_ = zeros(length(ind2cal_1), length(ind2cal_2));

% compute distances
for m=1:ndims
    D_ = D_ + bsxfun(@minus, ctr1(ind2cal_1, m), ctr2(ind2cal_2, m)').^2; 
end
D_ = sqrt(D_); 


D(ind2cal_1,ind2cal_2)=D_;

if ~obj.options.move
    D_all=obj.D_all;
else
    D_all=obj.D_moved_all;
end

if session1<=session2 %only tally one side
    D_all{session1,session2}=D;
else
    D_all{session2,session1}=D';
end

if ~move
    obj.D_all=D_all;
else
    obj.D_moved_all=D_all;
end

if length(ind2cal_1)>length(ind2cal_2)
    ord = [2 1]; %put smaller number neuron on the first for the imported Hungrian function.
else
    ord = [1 2];
end
