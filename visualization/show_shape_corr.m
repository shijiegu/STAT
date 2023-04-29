%% Look at matched pairs' shape correlation

[D, ord] = ct.cal_corr(1,2);
picked=sub2ind(size(D),neuron_chain(:,ord(1)),neuron_chain(:,ord(2)));
C=D(picked);

%% Color code correlation
if ct.options.d3==1; AsCell_=AsCell; else; AsCell_=AsCell_xy; end;
daynum=numel(AsCell_);
dates=[1 2];
figure
   for d=1:daynum
       d_=dates(d);
        A_current=reshape(AsCell_{d_},ct.options.d1*ct.options.d2,[]);
        size_=size(A_current);
        ind_currentday_tracked=neuron_chain(:,d_);
        ind_currentday_un=(setdiff(1:size_(end),ind_currentday_tracked))';
        
        label_currentday=[ind_currentday_tracked; ind_currentday_un];
        [colorlabel,palette,discretor]=color_intensity(C,0.8,1,0); 
        colorlabel=[colorlabel; 
            ones(length(ind_currentday_un),3).*0.2];
        
        g=subplot(ceil(daynum/2),2,d);
        g.CLim=[min(discretor) max(discretor)];
             
        ColorAllNeurons(A_current(:,[ind_currentday_tracked;ind_currentday_un]),ct.options.d1,ct.options.d2,['Day ' num2str(d)],[],label_currentday',colorlabel);
        if d==daynum
        colormap(1-palette)
        round(discretor,2)
        c = colorbar('YTickLabel',cellstr(num2str(discretor'))', ...
               'YTick', linspace(0.1,1,numel(discretor)));
        end
   end
suptitle('Correlation color coded')
papersize = [11 8];
    set(gcf, 'papersize', papersize, 'paperposition', [0 0 papersize]);
    set(gcf, 'RendererMode', 'manual', 'Renderer', 'painters')
    saveas(gcf, fullfile(datafolder, ['b', bName, '_STAT_shape_corr.pdf']))