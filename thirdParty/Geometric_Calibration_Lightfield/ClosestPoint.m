function IndexTarget=ClosestPoint(IndexSource,InitDiff,CornerList,CornerCorrelationSource,BoundaryDifferenceSource)

if IndexSource<=0 || IndexSource>size(CornerList,2)
    IndexTarget=-1;
    return;
end

dist=(CornerList(1,IndexSource)+InitDiff(1)-CornerList(1,:)).^2+(CornerList(2,IndexSource)+InitDiff(2)-CornerList(2,:)).^2;
idx=find(dist<InitDiff'*InitDiff/9&CornerCorrelationSource&BoundaryDifferenceSource);
if isempty(idx)
    IndexTarget=-1;
else
    [~,idx2]=min(CornerList(3,idx));
    IndexTarget=idx(idx2);
end

end