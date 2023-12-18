function [D, ord] = cal_corr(obj,session1,session2,varargin)
%% calculate the distances of neuron centers
%% inputs:
%   from the object and session1,session2
%           FFT's of spatial footprints from the two sessions
%           sum of A's for normalizing correlation
%   varargin's 'Name,Value' pair can be
%           'ind2cal_1',ind2cal_1,'ind2cal_2',ind2_cal2
%           In this case, this function will only cal

%% outputs:
%   D: N1*N2 matrix
%   ord: same as in "cal_dist.m"

%% author
% Shijie Gu & Pengcheng Zhou

%%

FFT_1=obj.FFT_all_1{session1};
FFT_2=obj.FFT_all_2{session2};
if isempty(FFT_1);  obj.update_spatial_fft(session1); FFT_1=obj.FFT_all_1{session1};  end
if isempty(FFT_2);  obj.update_spatial_fft(session2); FFT_2=obj.FFT_all_2{session2};  end

sizes = size(FFT_1);
N1=sizes(end);
sizes = size(FFT_2);
N2=sizes(end);

p = inputParser;
addParameter(p,'ind2cal_1',1:N1);
addParameter(p,'ind2cal_2',1:N2);
addParameter(p,'mode','max');
parse(p, varargin{:});
ind2cal_1=sort(p.Results.ind2cal_1,'ascend');
ind2cal_2=sort(p.Results.ind2cal_2,'ascend');
mode=p.Results.mode;

D = zeros(N1, N2);
s1=size(FFT_1(:,:,1),1);
s2=size(FFT_1(:,:,1),2);

% compute max correlation
for i=1:length(ind2cal_1)
    ni=ind2cal_1(i);
    if length(sizes)==3
        FFT_1_tmp=FFT_1(:,:,ni);
    else
        FFT_1_tmp=FFT_1(:,:,:,ni);
    end
    for j=1:length(ind2cal_2)
        nj=ind2cal_2(j);
        if length(sizes)==3
            FFT_2_tmp=FFT_2(:,:,nj);
        else
            FFT_2_tmp=FFT_2(:,:,:,nj);
        end        
        c = real(ifftn(FFT_1_tmp.*FFT_2_tmp));
        if strcmp(mode,'max')
            D(ni,nj)=max(c(:));
        elseif strcmp(mode,'center')
            D(ni,nj)=c((s1+1)/2,(s2+1)/2);
        end
    end
end

C_all=obj.C_all;
if session1<=session2
    C_all{session1,session2}=D;
else
    C_all{session2,session1}=D';
end
obj.C_all=C_all;

if length(ind2cal_1)>length(ind2cal_2)
    ord = [2 1]; %put smaller number neuron on the first for the imported Hungrian function.
else
    ord = [1 2];
end

