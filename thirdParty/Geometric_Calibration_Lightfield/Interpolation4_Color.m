function val=Interpolation4_Color(location,img)
i=floor(location);
s=location-i;
k=length(img(1,1,:));
val=zeros(k,length(location(1,:)));
img_size=size(img);
index=find(i(1,:)<1|i(1,:)>img_size(2)-1|i(2,:)<1|i(2,:)>img_size(1)-1);
i(:,index)=1;
for n=1:k
    temp=img(:,:,n);
    i00=temp(sub2ind(size(temp),i(2,:),i(1,:)));
    i01=temp(sub2ind(size(temp),i(2,:),i(1,:)+1));
    i10=temp(sub2ind(size(temp),i(2,:)+1,i(1,:)));
    i11=temp(sub2ind(size(temp),i(2,:)+1,i(1,:)+1));
    val(n,:)=(i00.*(1-s(1,:))+i01.*s(1,:)).*(1-s(2,:))+(i10.*(1-s(1,:))+i11.*s(1,:)).*s(2,:);
end
val(:,index)=-1;