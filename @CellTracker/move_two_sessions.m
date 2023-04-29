function vect=move_two_sessions(obj,session1,session2,cb_ref)
% Move session2 to session1.
%
% Shijie Gu


pair_tmp=obj.W_final_all{session1,session2};

X1=obj.X_all{session1};
X2=obj.X_all{session2};
vect=mean(X1(pair_tmp(:,1),:)-X2(pair_tmp(:,2),:),1);
X2_moved=X2+repmat(vect,size(X2,1),1);
obj.X_moved_all{session1,session2}=X2_moved;

if ~isempty(obj.A_all{session2})
    A2move=obj.A_all{session2};
    A_new=zeros(size(A2move));
    if or(obj.options.keep_A,~isempty(A2move))
        if obj.options.d3==1
            tform=affine2d([1 0 0; 0 1 0; vect(2) vect(1) 1]);
            for n=1:size(A2move,3)
                A_new(:,:,n)=imwarp(A2move(:,:,n),tform,'OutputView',cb_ref);
            end
        else
            tform=affine3d([1 0 0 0; 0 1 0 0; 0 0 1 0; vect(2) vect(1) vect(3) 1]);
            for n=1:size(A2move,4)
                A_new(:,:,:,n)=imwarp(A2move(:,:,:,n),tform,'OutputView',cb_ref);
            end
        end
        obj.A_moved_all{session1,session2}=A_new;
end
end

