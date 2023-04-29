RESULT_01=cell(3,5);
for i=1:3
    for j=1:5
        RESULT_01{i,j}=setdiff(RESULT_0{i,j},RESULT_1{i,j},'rows');
    end
end
%%
RESULT_10_key=cell(3,5);
for i=1:3
    for j=1:5
        if ~isempty(RESULT_10{i,j})
            RESULT_10_key{i,j}=setdiff(RESULT_10{i,j},answerkey,'rows');
        end
    end
end