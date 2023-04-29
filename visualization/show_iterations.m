function show_iterations(WW,AsCell,d1,d2,outputdir,filename,ind,WW_msg)
% This function makes a gif for showing iterations between a pair of
%   sessions (2 sessions), whose shapes are provided in AsCell.
% When providing inputs, make sure WW are 1*n cells, where each one
% contains an iteration you want to plot. We typically uses
%   ct.W_all{session1,session2}. Note that the first cell is the result from initiation.
% You can specify the range of iterations in the "ind" argument. If you
%   leave it empty or omit this input, all non-zero entries of WW's will be
%   plotted.
% Please also make sure the 1st column of each cell in WW corresponds to
% the first session in AsCell (AsCell{1}), and same for the second.
%
% Shijie Gu, 2018
%%
if ~exist('ind','var') || isempty(ind)
    op=find(~cellfun(@isempty,WW),1);
    ed=find(~cellfun(@isempty,WW),1,'last');
    ind=[op:ed];
end

if (~exist('filename','var') + ~exist('outputdir','var')) || (isempty(filename) + isempty(outputdir))
    error('Please specify a directory and a filename for the result.')
end

clf
for i=1:length(ind)
    it=ind(i);
    W=WW{it};
    clf
    if ~exist('WW_msg','var')
        suptitle(['Iteration ' num2str(it-1)])
    else
        msg=WW_msg{it};
        sp=suptitle({['Total Iteration ' num2str(it-1)],msg});
        sp.Interpreter = 'none';
    end
     
    for d=1:2
        A_current=AsCell{d};
        A_size_current=size(A_current);
        A_current=reshape(A_current,d1*d2,[]);
        ind_currentday_tracked=W(:,d);
        ind_currentday_un=(setdiff(1:(A_size_current(end)),ind_currentday_tracked))';
        
        label_currentday=[ind_currentday_tracked; ind_currentday_un];
        
        colorlabel=[ones(1,size(W,1)).*10 zeros(1,length(ind_currentday_un))];
        
        subplot(1,2,d)
        
        ColorAllNeurons(A_current(:,[ind_currentday_tracked;ind_currentday_un]),d1,d2,['Day ' num2str(d)],[],label_currentday',colorlabel);
    end
    h=getframe(1);
    [A,map] = rgb2ind(h.cdata,256);
    if i == 1
        imwrite(A,map,fullfile(outputdir,filename),'gif','LoopCount',Inf,'DelayTime',1);
    else
        imwrite(A,map,fullfile(outputdir,filename),'gif','WriteMode','append','DelayTime',1);
    end
end
