function h=plot_not_sure(neuron_chains,AsCell,title,varargin)
% This function plots tracked neuron --
%   matrix 'neuron_chain', where each row corresponds to one single neuron's indeces in each session (in columns)
% Sessions in columns, neurons ID in each session in rows. 
% If `plot_all`=true, neurons tracked in the same color, those
%   not tracked will be colored in grey. Otherwise, only tracked neurons
%   will be shown (those in grey colors will be omitted).
%
% Shijie Gu <techel@live.cn>

%% handling input


p = inputParser;
addParameter(p,'h',[]);
addParameter(p,'text_flag',[]);
addParameter(p,'plot_all',1);
addParameter(p,'multicolor',1);
addParameter(p,'SubplotPosition',[0 0 1 1])
parse(p, varargin{:});
h=p.Results.h;
text_flag=p.Results.text_flag;
plot_all=p.Results.plot_all;
SubplotPosition=p.Results.SubplotPosition;
multicolor=p.Results.multicolor;

neuron_chain=neuron_chains{1};
not_sure=neuron_chains{2};
if numel(neuron_chains)>=3
    fp=neuron_chains{3};
else
    fp=[];
end
if numel(neuron_chains)>=4
    fp_2=neuron_chains{4};
else
    fp_2=[];
end

if isempty(not_sure)*isempty(fp)*isempty(fp_2)
    h=simple_plot_chain(neuron_chain,AsCell,d1,d2,title,'h',h,'plot_all',plot_all,'text_flag',text_flag,'SubplotPosition',SubplotPosition);
    return
end

if numel(AsCell)~=size(neuron_chain,2)
    error('Please make sure each column of neuron_chain corresponds to a cell in the A''s provided.')
end

%% decide plot location (necessary if the plot is plotted within some canvas space)
daynum=numel(AsCell); %session number.
subplots=zeros(daynum,4);
h2=figure;
for d=1:daynum
    temp_axe=subplot(ceil(daynum/2),2,d);
    subplots(d,:)=temp_axe.Position;
    delete(temp_axe)
end
delete(h2)

%% actual plotting

% plotting neurons tracked in the same colors throughout the day.
% plotting non-tracked in gray.
d1=size(AsCell{1},1);
d2=size(AsCell{1},2);
for d=1:daynum
    A_current=reshape(AsCell{d},d1*d2,[]);
    ind_currentday_tracked=neuron_chain(:,d);
    if ~isempty(not_sure)
        ind_not_sure=not_sure(:,d);
    else
        ind_not_sure=[];
    end
    if ~isempty(fp)
        ind_fp=fp(:,d);
    else
        ind_fp=[];
    end
    if ~isempty(fp_2)
        ind_fp_2=fp_2(:,d);
    else
        ind_fp_2=[];
    end
    
    if plot_all
        ind_currentday_un=(setdiff(1:size(A_current,2),[ind_currentday_tracked; ind_not_sure; ind_fp; ind_fp_2]))';  
        ind_currentday=[ind_currentday_tracked; ind_currentday_un; ind_not_sure; ind_fp; ind_fp_2]; 
        label_currentday=[ind_currentday_tracked.*0; ind_currentday_un.*0; ind_not_sure; ind_fp; ind_fp_2];
        if multicolor
            colorlabel=[2:(size(neuron_chain,1)+1) zeros(1,length(ind_currentday_un)) ones(1,length(ind_not_sure)) 7.*ones(1,length(ind_fp)) 8.*ones(1,length(ind_fp_2))];
        else
            colorlabel=[ones(1,size(neuron_chain,1)).*6 zeros(1,length(ind_currentday_un)) ones(1,length(ind_not_sure)) 7.*ones(1,length(ind_fp)) 8.*ones(1,length(ind_fp_2))];
        end
        
    else
        ind_currentday=[ind_currentday_tracked; ind_not_sure]; 
        label_currentday=[ind_currentday_tracked.*0; ind_not_sure]; 
        if multicolor
            colorlabel=[2:(size(neuron_chain,1)+1) ones(1,length(ind_not_sure))]; 
        else
            colorlabel=[ones(1,size(neuron_chain,1)).*2 ones(1,length(ind_not_sure))];
        end
    end    
    ax=axes(h,'Position', NestMe(subplots(d,:), SubplotPosition));
    if d==1; AX=ax;
    else; linkaxes([AX ax]); end

    ColorAllNeurons(A_current(:,ind_currentday),d1,d2,[title  num2str(d)],[],label_currentday',colorlabel,'axe',ax,'text_flag',text_flag);
end
return


        %ColorAllNeurons(A_current(:,[ind_currentday_tracked]),d1,d2,[],[],label_currentday,label_currentday');        
        %              h=getframe(1);
        %         [A,map] = rgb2ind(h.cdata,256);
        %         if d == 1
        %             imwrite(A,map,filename,'gif','LoopCount',Inf,'DelayTime',1);
        %         else
        %             imwrite(A,map,filename,'gif','WriteMode','append','DelayTime',1);
        %         end



function NestedPosition = NestMe(UnNested, NestPosition)
    NestedPosition = UnNested...
        .*[NestPosition(3) NestPosition(4) NestPosition(3) NestPosition(4)]...
        + [NestPosition(1) NestPosition(2) 0 0]; 
end
end
