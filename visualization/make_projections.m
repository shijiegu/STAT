function [projections,names]=make_projections(AsCell,in)
% AsCell_xy=cellfun(@(x) reshape(squeeze(sum(x.*in,3)),d1*d2,[]), AsCell,'UniformOutput',false);
% AsCell_zx=cellfun(@(x) reshape(permute(squeeze(sum(x.*in,1)),[2 1 3]),d3*d2,[]), AsCell,'UniformOutput',false);
% AsCell_zy=cellfun(@(x) reshape(permute(squeeze(sum(x.*in,2)),[2 1 3]),d3*d1,[]), AsCell,'UniformOutput',false);

AsCell_xy=cellfun(@(x) squeeze(sum(x.*in,3)), AsCell,'UniformOutput',false);
AsCell_zx=cellfun(@(x) permute(squeeze(sum(x.*in,1)),[2 1 3]), AsCell,'UniformOutput',false);
AsCell_zy=cellfun(@(x) permute(squeeze(sum(x.*in,2)),[2 1 3]), AsCell,'UniformOutput',false);
projections{1}=AsCell_xy;
projections{2}=AsCell_zx;
projections{3}=AsCell_zy;
names{1}='xy'; names{2}='zx'; names{3}='zy';
end