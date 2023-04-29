# Pipeline 

1. load configurations/options (done)

2. add spatial footprints from all sessions and then compute neuron centers (done)

3. run STAT automatically.
     (this method is called match_sessions(), which calls obj.match_two_sessions(), 
        which further calls iteration_core.m to carry out the actual iterations.) 
    [ compute pairwise distances within the process as sometimes it is not necessary to calculate all neurons for all pairs]
    [ see obj.diagonse_two_sessions()]

4. data curation

5. visualization and manual verification 

6. parameter confirmation

7. save and export results. 