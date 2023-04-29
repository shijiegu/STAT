function show_theta_plot(obj,session1,session2,plot_title)
% show lowest and second lowest cost for each neuron's match.
% Input should be the N_final for a W_final. (eg: ct.N_final_all{1,2})
%% Input handling
if ischar(session1); [~,session1]=ismember(session1,obj.session_ids); end
if ischar(session2); [~,session2]=ismember(session2,obj.session_ids); end

%%
if session1<=session2
    W_final=obj.W_final_all{session1,session2};
else
    W_final=obj.W_final_all{session2,session1};
    W_final=reorder(W_final);
end

if isempty(W_final)
    error(['There is no neurons matched between these session ' num2str(session1) ' and session' num2str(session2)]);
end

ind2cal_1=1:obj.n_all{session1};
ind2cal_2=1:obj.n_all{session2};
p_method=obj.options.p_method;

N=obj.cal_neighbor_cost(obj.n_all{session1},obj.n_all{session2},obj.X_all{session1},obj.X_all{session2},W_final,p_method,'ind2cal_1',ind2cal_1,'ind2cal_2',ind2cal_2);
sorted_N = sort(N,2,'ascend');
max_1=sorted_N(:,1);
max_2=sorted_N(:,2);
[max_2_c] = histcounts(max_2,1:max(max_2));
[max_1_c] = histcounts(max_1,1:max(max_2));
baredges=1.5:1:(max(max_2)-0.5);

figure
b=bar([max_1_c' max_2_c']);
b(1).BarWidth=1;b(2).BarWidth=1;

l{1}='Lowest in each row';
l{2}='second lowest in each row';
legend(b,l)
if nargin<=3 || isempty(plot_title)
    plot_title=['theta plot: session ' num2str(session1) ' and session ' num2str(session2)];
end
title(plot_title);
%title(['With day ' num2str(dc) ' Picking \theta'])