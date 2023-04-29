function  Brainbow=ColorAllNeurons(A,d1,d2,Picname,outputdir,ind_for_text,colorlabel,varargin)
% Example: ColorAllNeurons(A,d1,d2)
% If you provide `Picname`, the title and the picture name will be
%       `Picname`;
% If `outputdir` is provided, the picture will be saved to that directory
%       with `Picname`. That is, you must provide `Picname` when providing
%       `outputdir`.
% `ind_for_text` can be used when you scramble the A's column when you for
%       the input A. `ind_for_text` is the label for each neuron in column
%       in A, left to right.
% `colorlabel` is the color index for each column/neuron in A.
%       zero entries in `colorlabel` will be color gray. entries in ones will be red.
%       Others are in random colors.
%
% Emily Mackevicius, Shijie Gu

p = inputParser;
addParameter(p,'axe',[]);
addParameter(p,'text_flag',0);
addParameter(p,'circle_flag',0);
parse(p, varargin{:});
axe=p.Results.axe;
text_flag=p.Results.text_flag;
circle_flag=p.Results.circle_flag;
if isempty(axe); axe=gca; end

    k = size(A,2);
    if nargin <5 || isempty(outputdir)
        outputdir = {};
    end
    if nargin<4 || isempty(Picname)
        Picname = {};
    end
    if nargin <6 || isempty(ind_for_text)
        ind_for_text=1:k;
    end
    if nargin <7 || isempty(colorlabel)
        colorlabel=1:k;
    end
    if isempty(ind_for_text); ind_for_text=1:k; end

%     figure; 
%    hold all
    if size(colorlabel,2)==3
        nColors=colorlabel;
    else
        color_palet = 1-[[1 .6 0]; [.7 .6 .4]; [.6 .8 .3]; [0 .6 .3]; [0 0 1]; [0 .6 1]; [0 .7 .7]; [.7 0 .7];  [.7 .4 1]];
        color_palet = color_palet([1:2:end 2:2:end],:); % scramble slightly
        nColors = color_palet(mod(colorlabel,size(color_palet,1))+1,:);
        if sum(colorlabel==0)>0
            nColors(colorlabel==0,:)=repmat([0.2,0.2,0.2],sum(colorlabel==0),1);
        end
        if sum(colorlabel==0.5)>0
            nColors(colorlabel==0.5,:)=repmat([0,1,1],sum(colorlabel==1),1);
        end
    end
        Ir = diag(nColors(:,1));
        Ig = diag(nColors(:,2));
        Ib = diag(nColors(:,3));
    
    if ~circle_flag
        %pA=prctile(A,90,1);
        %A = bsxfun(@(a,b) a>b, A, pA);
        %sA = sum(A,1);
        %A = bsxfun(@rdivide, A, sA)*prctile(sA, 5);
        
        C=ones(k,1);
        
        Brainbow = 1-cat(3, A*Ir*C, A*Ig*C, A*Ib*C);
        Brainbow = reshape(Brainbow,d1,d2,3);
        hold on
        image(axe,Brainbow)
        %image(Brainbow, 'parent', axe)
        
    end
    set(axe, 'ydir', 'reverse')
    axis image
    axis off;
    axis tight;
    alpha_data=double(sum(Brainbow,3)>2.5);
    K = 0.125*ones(3);
    alpha_data = conv2(1-alpha_data,K,'same');
    alpha(alpha_data);

    Atemp=reshape(A,d1,d2,k);
    X=get_centers(Atemp);
    Position=zeros(2,k);
    for i=1:k
        Atemp_=Atemp(:,:,i);
        [row_ind,col_ind] = find(Atemp_>0);
        Position(2,i)=mean(row_ind);
        Position(1,i)=mean(col_ind);
        if circle_flag
            viscircles([X(i,2),X(i,1)],3,'Color',nColors(i,:));
        end
    end
    
    if text_flag
        first_ind=find(ind_for_text,1);
        text(axe,Position(1,first_ind:end),Position(2,first_ind:end),cellstr(num2str(ind_for_text(first_ind:end)'))','Color','black')
    end

    if numel(Picname)>0
        title(Picname,'FontWeight','normal','interpreter','none')
    end
    
    fig=gcf;
    if numel(outputdir)>0

        fignam=[outputdir Picname,'.png'];

        saveas(gcf,fignam);
    end
    