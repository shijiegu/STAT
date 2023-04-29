function [i,j]=hungarian(obj,cost_matrix)
[d1,d2]=size(cost_matrix);
if d1>d2
    [j, i] = linear_sum_assignment(cost_matrix');
else
    [i, j] = linear_sum_assignment(cost_matrix);
end