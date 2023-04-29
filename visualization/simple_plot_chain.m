function h=simple_plot_chain(neuron_chain,AsCell,title,varargin)
% This function plots tracked neuron --
%   matrix 'neuron_chain', where each row corresponds to one single neuron's indeces in each session (in columns)
% Sessions in columns, neurons ID in each session in rows. 
% If `plot_all`=true, neurons tracked in the same color, those
%   not tracked will be colored in grey. Otherwise, only tracked neurons
%   will be shown (those in grey colors will be omitted).
%
% Shijie Gu <techel@live.cn>

%% handling input
d1=size(AsCell{1},1);
d2=size(AsCell{1},2);
p = inputParser;
addParameter(p,'h',[]);
addParameter(p,'text_flag',0);
addParameter(p,'plot_all',1);
addParameter(p,'circle_flag',0);
addParameter(p,'outside_axes',[]);
addParameter(p,'SubplotPosition',[0 0 1 1])
parse(p, varargin{:});
h=p.Results.h;
text_flag=p.Results.text_flag;
plot_all=p.Results.plot_all;
circle_flag=p.Results.circle_flag;
SubplotPosition=p.Results.SubplotPosition;
outside_axes=p.Results.outside_axes;

if numel(AsCell)~=size(neuron_chain,2)
    error('Please make sure each column of neuron_chain corresponds to a cell in the A''s provided.')
end

d1=size(AsCell{1},1);
d2=size(AsCell{1},2);
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

for d=1:daynum
    A_current=reshape(AsCell{d},d1*d2,[]);
    ind_currentday_tracked=neuron_chain(:,d);
    
    if plot_all
        ind_currentday_un=(setdiff(1:size(A_current,2),ind_currentday_tracked))';      
        label_currentday=[ind_currentday_tracked; ind_currentday_un];        
        colorlabel=[1:size(neuron_chain,1) zeros(1,length(ind_currentday_un)).*0.5];
    else
        label_currentday=ind_currentday_tracked;
        colorlabel=[1:size(neuron_chain,1)];        
    end    
    ax=axes('parent', h,'Position', NestMe(subplots(d,:), SubplotPosition));
    if d==1; AX=ax;
    else; linkaxes([AX ax]); end

    ColorAllNeurons(A_current(:,label_currentday),d1,d2,[title  num2str(d)],[],label_currentday',colorlabel,'axe',ax,'text_flag',text_flag,'circle_flag',circle_flag);
    if ~isempty(outside_axes)
        linkaxes([outside_axes{d} ax])
    end
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
