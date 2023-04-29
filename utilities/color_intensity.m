function [colors,palette,discretor]=color_intensity(C,MIN,MAX,small_strong)
% MIN, MAX: used in discreter, 
%   values lower than MIN will be shown in the same color,
%   similarly, values larger than MAX will be shown in the same color.
% Shijie Gu

if nargin<4
    small_strong=0;
end

palette=1-[255,255,204; %weak color - khaki
255,237,160;
254,217,118;
254,178,76;
253,141,60;
252,78,42;
227,26,28;
189,0,38;   %strong color - blood red
128,0,38;]./256; %from color brewer: 9-class YlOrRd

if small_strong
    palette=flipud(palette);
end
    
discretor=round(linspace(MIN,MAX,size(palette,1)),2);
ind=arrayfun(@(x) find(x<=discretor,1),C,'UniformOutput',0);
empty_ind=find(cellfun(@isempty,ind));
for i=1:length(empty_ind) 
    if small_strong
        ind{empty_ind(i)}=size(palette,1);
    else
        ind{empty_ind(i)}=1;
    end
end
ind=cell2mat(ind);
colors=palette(ind,:);

