function vect=comprigid_two_sessions(obj,session1,session2)
% Compute rigid translation through maximizing the correlation between the
%   two images. Calls the utility function 'max_xcross'.
% Shijie Gu
options=obj.options;
d1=options.d1; d2=options.d2; d3=options.d3;
sizes=[d1,d2,d3];
    
    if isempty(obj.FFT_image_all_1{session1})
        update_image_fft(obj, session1);
    end
    A1_fft=obj.FFT_image_all_1{session1};
    
    if isempty(obj.FFT_image_all_2{session2})
        update_image_fft(obj, session2);
    end
    A2_fft=obj.FFT_image_all_2{session2}; 
    
    X2=obj.X_all{session2};
    A2move=obj.A_all{session2};
    [vect,X2_moved,A2_moved]=max_xcross(sizes,A1_fft,A2_fft,X2,A2move);
       
    obj.X_moved_all{session1,session2}=X2_moved;
    obj.A_moved_all{session1,session2}=A2_moved;

end