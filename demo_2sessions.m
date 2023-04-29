close all; clc; clear; 
%% configuring path 
run(fullfile('stat_setup.m')); 
data_folder = fullfile(STAT_dir, 'DemoData'); 

%% create a class wrapper 
nsessions = 2; 
ct = CellTracker(nsessions); 

%% Load data
% 3D example:
% datafile = fullfile(data_folder, '3D_data_two_sessions.mat'); 
% load(datafile); 
% ct.add_sessions(AsCell); 

% simulate data
datafile = fullfile(data_folder,'2D_2sessions_simulation_gp.mat'); 
load(datafile); 
ct.add_sessions(AsCell); 

%% change the configurations 
%  Here is the full list of options one can change.
%  Often, you'd only need a few of these.
ct.options.output_path=data_folder;       %specify output directory;

ct.options.nonconverge_method='intersection'; %;{'intersection','min'}, if it cannot converge, choose min across all iterations or choose intersection between the last     
ct.options.init_method='distance';...   %;{'shape','distance'}
ct.options.cal_corr=0;               % true or false.
ct.options.direction='both';...        %; {'uni','both'} uni: min on one direction; both: min on row and col
ct.options.crop_width=15;...  % ;For faster calculation of crosscorrelation: cropping a 81*81 window around a neuron rather than looking at the whole FOV.
ct.options.p_method='hard_flexible';...%;{'hard','gaussian'}(hard: recommended as it includes 'smart' dilation for neurons at less dense area),
                       ...             %'gaussian', in which case I suggest R, which is the standard dev, to be low
ct.options.R=20;...   % L. defining the min neighborhood.
ct.options.thresh=8;... %threshold, theta in the manuscript

ct.options.nRep=15;...% number of iterations. Usually 5-10 iterations are enough.
ct.options.auto_move=0; %when matching fails, apply auto translational motion correction.
ct.options.max_shift=30; % In all iterations, only neurons within
                         % R<=2*max_shift is considered candidate for matching
                         % if 'auto_move=True', and 'init_method=distance', then,...
                            % max_shift is also used in initiation after motion compensation
ct.options.keep_A=0; %once centriod is calculated, keep A.
ct.options.retronum=4; %max number of sessions to retrospectively match, default:4.
ct.options.parallel_num=0; %number of workers in parallel for-loop. set to 0 if session num is small
ct.options.strict=0;     %enforce a stricter criteria: threshold is lower for denser area

config_new=fullfile(fileparts(which('stat_setup.m')),'updated_options.yaml');
ct.write_config(config_new);

%% Running the algorithm
ind_to_match = [1:2]; 
ct.match_sessions(ind_to_match,'start_new',1); 

%% Curate result
[neuron_chain,neuron_chain_new,~,session_ind]=ct.object2result(ind_to_match);
% 
%% Visualization for 2D data, matched in the same color, non-matched in grey
h=figure;
text_flag=0; % add neuron index or not.
title='Session';
simple_plot_chain(neuron_chain_new,AsCell(session_ind),title,'h',h,'plot_all',1,'text_flag',text_flag);

%% Demo ends here, but below has code that might be useful: A,B,C,D,E
%% A. Visualization for 3D data, matched in the same color, non-matched in grey
% % only plotting 2 sessions shall be good (fast).
% session_ind=[1 2];
% % make projections
% in=5;  %intensify/"desentify" data color by a factor of "in"
% [projections,names]=make_projections(AsCell(session_ind),in); 
% AsCell_xy=projections{1}; AsCell_zx=projections{2}; AsCell_zy=projections{3}; names
% 
% % plot intersections
% h=figure; %if there are only 2 days, you can plot all three views in one plot, 
%           % otherwise plot each view in one single plot.
% simple_plot_chain(neuron_chain_new,AsCell_xy(session_ind),...
%             'X_Y plane','plot_all',0,'h',h,'SubplotPosition',[0 0.5 1 0.45]);
% simple_plot_chain(neuron_chain_new,AsCell_zx(session_ind),...
%             'X_Z plane','plot_all',0,'h',h,'SubplotPosition',[0 0.25 1 0.2]);
% simple_plot_chain(neuron_chain_new,AsCell_zy(session_ind),...
%             'Y_Z plane','plot_all',0,'h',h,'SubplotPosition',[0 0.0 1 0.2]);

%% B. Confirm Parameter: theta
% 
%this function shows a plot of the distribution of the lowest cost
%   and the second lowest cost of the potential matches for each neuron.

plot_title='';
session1=1;
session2=2;
ct.show_theta_plot(session1,session2,plot_title); 
% 
%% C. (Not very good) Confirm Parameter: neighborhood radius, L
plot_diff = 1;
plot_corr = 0;
nbins=5; %nbins is the number of data points to calculate the median trend line in the plot.
[diffs,corrs,distances]=ct.show_L_plot(session1,session2,plot_diff,plot_corr,nbins,'xlimit',100);
% 
%% D. Parameter Sweep: 
%     %% I. Running the algorithm across a 2D parameter space. It will take some time.
%     R_to_try=[30 40 50];
%     theta_to_try=[4 5 6 7 8];
%     RESULT=cell(length(R_to_try),length(theta_to_try));
%     for m=1:length(R_to_try)
%         disp(['R=' num2str(R_to_try(m))])
%         ct.options.R=R_to_try(m);
%         for n=1:length(theta_to_try)
%             disp(['theta=' num2str(theta_to_try(n))])
%             ct.options.thresh=theta_to_try(n);
%             
%             ct.match_sessions(ind_to_match,'start_new',1);
%             
%             [~,neuron_chain_new,session_ind]=ct.object2result(ind_to_match);
%             RESULT{m,n}=neuron_chain_new;
%         end
%     end
%     %save('/Users/gushijie/Documents/MATLAB/nm/utilities/simulate_data/parameters','RESULT','ct','session_ind','-v7.3')
% 
%     %% II. Find common results (very_confident) and unique ones (not_sure).
% 
%     neuron_chain_11=RESULT{1,1};
%     ia=true(size(neuron_chain_11,1),1);
%     for m=1:length(R_to_try)
%         for n=1:length(theta_to_try)
%             neuron_chain_new=RESULT{m,n};
%             ia_=ismember(neuron_chain_11,neuron_chain_new,'rows');
%             ia=ia.*reshape(ia_,[],1);
%         end
%     end
%     very_confident=neuron_chain_11(ia>0,:);
%     
%     not_sure=[];
%     for m=1:length(R_to_try)
%         for n=1:length(theta_to_try)
%             neuron_chain_new=RESULT{m,n};
%             not_sure_tmp=setdiff(neuron_chain_new,very_confident,'rows');
%             not_sure=[not_sure;not_sure_tmp];
%         end
%     end
%     not_sure=unique(not_sure,'rows');

%% E. Pick a pair of sessions, show matching iterations
% session1=1;
% session2=2;
% outputdir='/Users/gushijie/Documents/MATLAB/nm/visualization/';
% AsCell_{1}=AsCell{1}; %if you index into the ct object, make sure ct.options.keep_A is set to 1.
% AsCell_{2}=AsCell{2}; % otherwise, you will have to use directly from the input as this demo shows.
% if sum(~cellfun(@isempty,ct.W_all{session1,session2}))>0
%     show_iterations(ct.W_all{session1,session2},AsCell_,ct.options.d1,ct.options.d2,outputdir,'test_gif')
% end
%% save the class object 
% outputdir='';
% filename='';
% ct.save(outputdir,filename); 
% 
% %% export results 
% ct.export_results(outputdir,filename,neuron_chain,neuron_chain_new,session_ind)
