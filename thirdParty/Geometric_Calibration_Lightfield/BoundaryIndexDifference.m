function Diff=BoundaryIndexDifference(index1,index2,BoundaryLength)

bl2=BoundaryLength/2;
diff1=mod(index1-index2+BoundaryLength+bl2,BoundaryLength)-bl2;
diff2=mod(index1-[index2(4,:)-BoundaryLength;index2(1:3,:)]+BoundaryLength+bl2,BoundaryLength)-bl2;
diff3=mod(index1-[index2(2:4,:);index2(1,:)+BoundaryLength]+BoundaryLength+bl2,BoundaryLength)-bl2;
idx1=find(sum(abs(diff1))<=sum(abs(diff2))&sum(abs(diff1))<=sum(abs(diff3)));
idx2=find(sum(abs(diff2))<=sum(abs(diff1))&sum(abs(diff2))<=sum(abs(diff3)));
idx3=find(sum(abs(diff3))<=sum(abs(diff1))&sum(abs(diff3))<=sum(abs(diff2)));
Diff=zeros(4,size(index1,2));
Diff(:,idx1)=diff1(:,idx1);
Diff(:,idx2)=diff2(:,idx2);
Diff(:,idx3)=diff3(:,idx3);

end