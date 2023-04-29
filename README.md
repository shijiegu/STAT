# ReadME: STAT

**STAT** is a cell tracking algorithm based on the simple idea of 'neurons Stay Together, Align Together'. 

STAT method to track neuron is developed out of our own need to study songbird vocal learning, where we have nonrigid motion in the brain between calcium imaging sessions. Compared to previous methods, STAT aims to be as automated as possible with as few parameters as possible. Our parameters also have physics meaning to serve as a confident index. In addition to our songbird data, we have tried it on 3D volumn imaging data, as well as very dense 2p calcium imaging data, which all seems to work well.

Here we publicize this package with the hope that it will help your research. We are welcoming feedbacks. To introduce how STAT works, we have prepared a set of slides 📎 [STAT_intro.pdf](STAT_intro.pdf). To get started using STAT, please see the two demos we provide: [demo_2sessions.m](demo_2sessions.m). The only **input** STAT needs is the spatial footprints(d1 x d2 x n) of ROIs from each session, put in a cell array.

A more formal manuscript will come soon. Meanwhile, feel free to show us your results and ask us questions if STAT confuses you.

## Requirements
It is written in MATLAB, so it runs on MATLAB...

## Tips

1. **memory**: Usually memory is not an issue unless you are dealing with volumn data. In all cases, full spatial footprint is not necessary for STAT---just centroids will work. If your spatial footprints are huge, simply do this:
```
nsessions=numel(AsCell);
XsCell=cell(1,nsessions);
for ci=1:nsessions
  XsCell{ci}=get_centers(AsCell{ci}); %replace A (spatial footprint) with X (ROI centroids)
end
ct = CellTracker(nsessions);
ct.add_sessions(XsCell);
...
... %same as the demo
...
options.init_method='distance'; %make sure you choose the initialization method as 'distance' not 'shape'
...
```
2. **multiple-session matching**: The current implementation matches all sessions in a pair-wise manner, or it matches session n with session n-1, n-2, ..., n-a, where a is a variable that you can define as `options.retronum` in the code. All the pair-wise matches are independent so we offer an option to parallelize if you set `options.parallel_num` to a value great than 1. 
Apparently, there is redundancy compared with only matching session n and session n-1. This redundancy gives robustness to mistakes that occur between one pair of sessions. Specifically, with the redundancy, STAT output complier function `object2result()` checks all cell matches and outputs a `neuron_chain_new` of cell matches that can be stitched together without conflicts, and another table called `neuron_chain_conflict` that has all the cell matches involved with conflicts. You would have to check `neuron_chain_conflict` manually. Usually there are only very few conflicts occured.


## Authors


Shijie Gu [email](mailto:shijiegu@berkeley.edu) (currently @UCSF-UCBerkeley), Emily Mackevicius (currently @Columbia) & Michale Fee @MIT

Pengcheng Zhou @Columbia

2018-2019
