function image=A2image(A,textOrNot,color,PoporNOt,handle)
% make black and white image of A.
%   or red and white, or green and white of A.
% Specify color as 'red' or 'green' or [](black).
if nargin<2
    textOrNot=false;
end

if nargin<3
    color=[];
end

if nargin<4
    PoporNOt=false;
end

sizes=size(A);
d1=size(A,1);
d2=size(A,2);
d3=size(A,3);

A=reshape(A,d1*d2,[]);
A=A(:,any(A,1));
k = size(A,2);
sA = sum(A,1);
%A = bsxfun(@rdivide, A, sA)*prctile(sA, 5);
C=ones(k,1);

if isempty(color)==false
    if or(strcmp(color,'magenta'),strcmp(color,'red'))
        color_palet = 1-[1 0 1];
    elseif strcmp(color,'green')
        color_palet = 1-[0 1 0];
    else
        color_palet=color;
    end
        nColors = repmat(color_palet,size(A,2),1); 
        Ir = diag(nColors(:,1));
        Ig = diag(nColors(:,2));
        Ib = diag(nColors(:,3));
    
    Brainbow = 1-cat(3, A*Ir*C, A*Ig*C, A*Ib*C);
    Brainbow = reshape(Brainbow,d1,d2,3);
else
    Brainbow = 1-A*C;
    Brainbow(Brainbow<0)=0;
    Brainbow = reshape(Brainbow,d1,d2);
    %image=imshow(Brainbow); 
end
image=Brainbow;
if PoporNOt==true
    if nargin<5
        figure
    else
        axes(handle)
    end
    imshow(Brainbow)
end

if textOrNot==true
    Atemp=reshape(A,d1,d2,k);
    Position=zeros(2,k);
    for i=1:k
        Atemp_=Atemp(:,:,i);
        [row_ind,col_ind] = find(Atemp_>0);
        Position(2,i)=mean(row_ind);
        Position(1,i)=mean(col_ind);
    end
    text(Position(1,:),Position(2,:),cellstr(num2str((1:k)'))','Color','black')
    F = getframe(gca);
    image=F.cdata; 
end
