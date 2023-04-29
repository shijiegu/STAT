function osci=osci_detector(W)
term=find(~cellfun(@isempty,W),1,'last');
nonconverge=true;
prev=1;
while nonconverge
    prev=prev+1;
    if prev==5 %max iteration detect 
        break
    end
    picked=term-prev;
    if picked<1
        break
    else
        if isempty(W{picked}); continue; end
        nonconverge=~and(isempty(setdiff(W{picked},W{term},'rows')),isempty(setdiff(W{term},W{picked},'rows')));
    end
end

if ~nonconverge
    osci=1;
else
    osci=0;
end