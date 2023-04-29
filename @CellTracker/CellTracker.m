classdef CellTracker < matlab.mixin.Copyable
    %   Object for tracking cells across multiple sessions (n)
    properties
        %% data
        n_sessions = 0;     % number of sessions
        session_ids = {};   % n*1 cell, each element is a unique number of string for each session
        n_added = 0;        % number of added sessions. (some sessions might be deleted during the analysis)
        A_all cell = {};    % n*1 cell, each element is a d1*d2(*d3)*N_i matrix
        FFT_image_all_1 = {}  % FFT of images, for rigid translation estimation at the beginning
        FFT_image_all_2 = {} % in reverse
        A_moved_all = {};   % n*n cell, pair-wise A's have relative global motion (translation) compensated.
        n_all = {};         % number of neurons in each session
        FFT_all_1 = {};     % n*1 cell, each element stores the FFT of all neurons in a single session
        FFT_all_2 = {};  % flipped, for calculating correlation   
        N_all = {};         %n*n cell, each cell is the cost matrices of each pair of session during matching.
        W_all = {};     % n*n cell, matrix of assignment matrices, n is the number of sessions
        W_msg_all ={};  % simple explanation for each cell in W_all. Thus same size as W_all.
        W_final_all = {}; % final W in the iterations.
        paired_all = {}; % similar to final W, but in absolute index.
        C_all = {};     % n*n cell, matrix of shape correlation
        X_all = {};     % n*1 cell, neuron centers; each element is a N_i * 2 or N_i * 3 matrix.
        X_moved_all = {}; % different from X_all, n*n cell, centers of moved
        D_all = {};     % n*n cell, center distances between all pairs of neurons
        D_moved_all = {};
        
        tmp=[];         % put whatever stuffs for tmp computation use.
        
        %% options
        yaml_path = '';    % YAML file for storing the configurations

        options=struct('d1',[],'d2',[],'d3',1,...
                       'nonconverge_method','min',... %;{'intersection','min'}, if it cannot converge, choose min across all iterations or choose intersection between the last     
                       'init_method','distance',...   %;{'shape','distance'}
                       'cal_corr',0,...               % 0 or 1. calculate correlation or not.
                       'keep_A',0,...                 % After obtaining shape correlation and distance, still keep A's or no.
                        'direction','both',...        %; {'uni','both'} uni: min on one direction; both: min on row and col
                        'crop_width',15,...  % ;For faster calculation of crosscorrelation: cropping a 81*81 window around a neuron rather than looking at the whole FOV.
                        'p_method','hard_flexible',...%;{'hard','gaussian'}(hard: recommended as it includes 'smart' dilation for neurons at less dense area),
                         ...                          %'gaussian', in which case I suggest R to be low
                        'R',40,...   % L. defining the min neighborhood.
                        'thresh',4,... %threshold, theta in the manuscript
                        'nRep',15,...% number of iterations. Usually 5-10 iterations are enough.
                        'max_shift',50,...              % In all iterations, only neurons within
                         ...                  % R<=2*max_shift is considered candidate for matching
                         ...   % if 'auto_move=True', and 'init_method=distance', then,...
                         ...   % max_shift is also used in initiation after motion compensation
                         'auto_move',0,... %when matching fails, apply auto translational motion correction.
                         'parallel_num',0,...%number of workers in parallel for-loop, parfor.
                         ... ----% legacy, no use in the current version
                        'move',0) %compensate motion found in the first round then move again
    end
    
    methods
        %% initialize a class object
        function obj = CellTracker(n_sessions)
            %% preallocate space for saving session information
            if ~exist('n_sessions', 'var') || isempty(n_sessions)
                n_sessions = 2;
            end
            obj.A_all = cell(n_sessions, 1);
            obj.FFT_image_all_1 = cell(n_sessions, 1);
            obj.FFT_image_all_2 = cell(n_sessions, 1);
            obj.A_moved_all = cell(n_sessions);
            obj.X_moved_all = cell(n_sessions);
            obj.n_all = cell(n_sessions, 1);
            obj.FFT_all_1 = cell(n_sessions, 1);
            obj.FFT_all_2 = cell(n_sessions, 1);
            obj.N_all = cell(n_sessions);
            obj.W_all = cell(n_sessions);
            obj.W_msg_all = cell(n_sessions);
            obj.W_final_all = cell(n_sessions);
            obj.paired_all = cell(n_sessions);
            obj.C_all = cell(n_sessions);
            obj.X_all = cell(n_sessions,1);
            obj.D_all = cell(n_sessions);
            obj.D_moved_all = cell(n_sessions);
            obj.session_ids=cell(1,n_sessions);
            
            obj.tmp = cell(n_sessions);
%             s=1:n_sessions;
%             obj.session_ids = strtrim(cellstr(num2str(s'))');
            
            %% configure options
            obj.yaml_path = fullfile(fileparts(which('CellTracker.m')), 'default_options.yaml');
            obj.read_config();
            
        end
        
        %% read and write configurations
        read_config(obj, path_file);
        write_config(obj, path_file);
        
        %% add sessions
        add_sessions(obj, A_new, IDs_new)
        
        %% delete A to save momory
        function delete_As(obj)
            obj.A_all = cell(obj.n_sessions, 1);
            obj.A_moved_all = cell(obj.n_sessions, 1);
        end
        
        %% For initiation: 
            % Calculate pairwise shape correlation or centroid distance
         update_spatial_fft(obj, session_id)
         update_image_fft(obj, session_id)
         vect=comprigid_two_sessions(obj,session1,session2);
        [D, ord] = cal_corr(obj,session1,session2,varargin)
        [D, ord] = cal_dist(obj, session1,session2,varargin)
        [i,j] = hungarian(obj,cost_matrix);
        
       %% For iteration
        [N,dim]=cal_neighbor_cost(obj,n1,n2,ctr,ctr_,W,p_method,varargin)
        %which is called within 'iteration_core.m', and it calls
        % other helper functions in the 'utilities'.
        
        %% compute all distances
        update_distances_all_session(obj)
        update_corr_all_session(obj)
            
      
        %% convert IDs to indices
        function IDs=id2ind(obj, IDs)
            if iscell(IDs)
                ischar_ind=cellfun(@ischar,IDs);
                if sum(ischar_ind)>=1
                    [~,IDs]=ismember(IDs(ischar_ind),obj.session_ids);
                end
            end
        end
        %% match sessions
        no_neuron_flag=match_two_sessions(obj,session1,session2,varargin);
        no_neuron_flag=match_two_sessions_full(obj,session1,session2,cb_ref,varargin)
        obj=match_sessions(obj,session_ind,varargin);
        
        %% find pairs and non-paired neurons in sessions
        [unpaired_1,unpaired_2,flag]=diagonse_two_sessions(obj,session1,session2,all_sessions);
        
        %% reset two sessions
        reset_two_sessions(obj,session1,session2)
        
        %% move one session relative to another (compensate for global motion)
        vect=move_two_sessions(obj,session1,session2,cb_ref);
        
        %% saving results
        last_ind=tally_W_final(obj,session1,session2,W_final,msg);
        [neuron_chain,neuron_chain_new,neuron_chain_conflict,session_ind]=object2result(obj,session_ind);
        save(obj,outputdir)
        export_results(obj,outputdir,filename,neuron_chain,neuron_chain_new,session_ind)
        
        %% parameter diagnose plots
        show_theta_plot(obj,session1,session2,plot_title)
        [diffs,corrs,distances]=show_L_plot(obj,session1,session2,plot_diff,plot_corr,nbins,varargin);
        
        %% for parfor
        [m,binname]=obj2bin(obj);
    end
end