function [m,binname]=obj2bin(obj)

n_all=cell2mat(obj.n_all);
d1=obj.options.d1;
d2=obj.options.d2;
d3=obj.options.d3;

binname=fullfile(obj.options.output_path,'Tmp_File_Cell_Location.bin');
f = fopen(binname,'w');
for i=1:obj.n_sessions
    AS=reshape(obj.A_all{i},[],n_all(i));
    fwrite(f,AS,'double');
end
fclose(f);

sort_string=[];
for i=1:obj.n_sessions
    sort_string=[sort_string,['''double'',[n_all(' num2str(i) ') d1*d2*d3],' '''A' num2str(i) ''';']];
end
sort_string=['{' sort_string(1:end-1) '}'];
eval(['m = memmapfile(''', binname, ''', ''Format'',' sort_string ');']);

