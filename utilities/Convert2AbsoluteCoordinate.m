function neurons_reduced_abs=Convert2AbsoluteCoordinate(neurons_reduced,newday,oldday,sizesofeachday)
% takes neuron pairs in different days, return pairs in abs coordinates.
%  input in either a matrix of []x2 or cell of 1 x 2.
if isempty(neurons_reduced)
    neurons_reduced_abs=[];
    return
end

if iscell(sizesofeachday)
    sizesofeachday=cat(2,sizesofeachday{:});
end
sizes=cumsum(sizesofeachday);
if iscell(neurons_reduced)
    NEW=neurons_reduced{1};
    OLD=neurons_reduced{2};
else
    NEW=neurons_reduced(:,1);
    OLD=neurons_reduced(:,2);
end

if newday~=1
    NEW=NEW+sizes(newday-1);
end

if oldday~=1
    OLD=OLD+sizes(oldday-1);
end

if iscell(neurons_reduced)
    neurons_reduced_abs{1}=NEW;
    neurons_reduced_abs{2}=OLD;
else
    neurons_reduced_abs=[NEW OLD];
end
