function [diffs_matrix,corrs_matrix,distances_matrix]=show_L_plot(obj,session1,session2,plot_diff,plot_corr,nbins,varargin)
% Show displacement cector's pairwise relationship versus distance.
% if "plot_diff", it will plot the pairwise difference.
% if "plot_corr", it will plot the pairwise correlation.
% Shijie Gu

%% Input handling
if ischar(session1); [~,session1]=ismember(session1,obj.session_ids); end
if ischar(session2); [~,session2]=ismember(session2,obj.session_ids); end

if session1<=session2
    W_final=obj.W_final_all{session1,session2};
else
    W_final=obj.W_final_all{session2,session1};
    W_final=reorder(W_final);
end

if isempty(W_final)
    error(['There is no neurons matched between these session ' num2str(session1) ' and session' num2str(session2)]);
end

%%
p = inputParser;
addParameter(p,'xlimit',50);
parse(p, varargin{:});
xlimit=p.Results.xlimit;

%%

X1=obj.X_all{session1};
X2=obj.X_all{session2};
all_vects=X1(W_final(:,1),:)-X2(W_final(:,2),:);

corrs=zeros(size(all_vects,1),size(all_vects,1));
for dim=1:size(X1,2)
    corrs=corrs+bsxfun(@times,all_vects(:,dim),all_vects(:,dim)');
end
corrs=bsxfun(@rdivide,corrs,sqrt(sum(all_vects.^2,2)));
corrs=bsxfun(@rdivide,corrs,sqrt(sum(all_vects.^2,2))');

diffs=zeros(size(all_vects,1),size(all_vects,1));
for dim=1:size(X1,2)
    diffs=diffs+bsxfun(@minus,all_vects(:,dim),all_vects(:,dim)').^2;
end
diffs=sqrt(diffs);

distances=zeros(size(all_vects,1),size(all_vects,1));
for dim=1:size(X1,2)
    distances=distances+bsxfun(@minus,X1(W_final(:,1),dim),X2(W_final(:,2),dim)').^2;
end
distances=sqrt(distances);

distances_matrix=distances;
corrs_matrix=corrs;
diffs_matrix=diffs;

partial = triu(ones(size(distances,1)),1);
distances=distances(partial==1);
corrs=corrs(partial==1);
diffs=diffs(partial==1);
%% calculate mean trend line

started=linspace(1,xlimit,nbins+1);
loc=zeros(1,nbins);
corrs_mean=zeros(1,nbins);
diffs_mean=zeros(1,nbins);
for i=1:nbins
    op=started(i);
    ed=started(i+1);
    loc(i)=(op+ed)/2;
    
    ind_picked=and(distances>=op,distances<=ed);
    corrs_=corrs(ind_picked);
    corrs_mean(i)=mean(corrs_(:));
    
    diffs_=diffs(ind_picked);
    diffs_mean(i)=mean(diffs_(:));
end

%%

figure;
if plot_diff  
    yyaxis left
    title('Displacement Vector''s Pairwise Relationship','FontSize',14)
    scatter(distances(:),diffs(:));
    xlabel('Distance (pixel)')
    ylabel('Difference')
    xlim([0 xlimit]);
    hold on
    plot(loc,diffs_mean,'LineWidth',1);
end

if plot_corr
    yyaxis right
    scatter(distances(:),corrs(:));
    ylabel('Correlation')
    xlim([0 xlimit])
    hold on
    plot(loc,corrs_mean,'LineWidth',1);
end