% Y. Bok, H. Ha and I. S. Kweon
% Automated Checkerboard Detection and Indexing using Circular Boundaries
% Pattern Recognition Letters, February 2016

function CornerList=CheckerboardCorner(img_gray_double)

% DisplayIntermediateResult=true;
DisplayIntermediateResult=false;

sizeV=size(img_gray_double,1);
sizeH=size(img_gray_double,2);

boundary_initial=[3,3,2,1,0,-1,-2,-3,-3,-3,-2,-1,0,1,2,3;0,1,2,3,3,3,2,1,0,-1,-2,-3,-3,-3,-2,-1];
sizeH2=floor((sizeH-5)/2);
sizeV2=floor((sizeV-5)/2);
sizeb=sizeH2*sizeV2;
boundary=zeros(16,sizeb);
for i=1:16
    boundary(i,:)=reshape(img_gray_double(4+boundary_initial(2,i):2:sizeV-3+boundary_initial(2,i),4+boundary_initial(1,i):2:sizeH-3+boundary_initial(1,i)),1,sizeb);
end
boundary=boundary-repmat((min(boundary,[],1)+max(boundary,[],1))/2,16,1);
sign_change4=(sum((boundary(1:16,:).*[boundary(2:16,:);boundary(1,:)]<0)|(boundary==0),1)==4)&(max(boundary,[],1)>10);
[j,i]=find(reshape(sign_change4,sizeV2,sizeH2));

initial=[i(:)*2+3,j(:)*2+3]';

if DisplayIntermediateResult % Intermediate Result 1
    figure; imshow(uint8(img_gray_double)); hold on;
    plot(initial(1,:),initial(2,:),'r.'); hold off;
end

a=(0:10:360)*pi/180;
sample=[cos(a);sin(a)];

refined3=CornerRefinement(initial,img_gray_double,2);
idx=(~isnan(refined3(1,:)))&(refined3(1,:)>4)&(refined3(1,:)<sizeH-3)&(refined3(2,:)>4)&(refined3(2,:)<sizeV-3);
refined3=refined3(:,idx);
boundary_vector3=BoundaryVector(img_gray_double,refined3,3);
boundary_vector31=BoundaryVector(img_gray_double,refined3,1.5);
num3=size(refined3,2);

refined6=CornerRefinement(initial,img_gray_double,5);
idx=(~isnan(refined6(1,:)))&(refined6(1,:)>7)&(refined6(1,:)<sizeH-6)&(refined6(2,:)>7)&(refined6(2,:)<sizeV-6);
refined6=refined6(:,idx);
boundary_vector6=BoundaryVector(img_gray_double,refined6,6);
boundary_vector61=BoundaryVector(img_gray_double,refined6,3);
num6=size(refined6,2);

refined9=CornerRefinement(initial,img_gray_double,8);
idx=(~isnan(refined9(1,:)))&(refined9(1,:)>10)&(refined9(1,:)<sizeH-9)&(refined9(2,:)>10)&(refined9(2,:)<sizeV-9);
refined9=refined9(:,idx);
boundary_vector9=BoundaryVector(img_gray_double,refined9,9);
boundary_vector91=BoundaryVector(img_gray_double,refined9,4.5);
num9=size(refined9,2);

refined=[refined3,refined6,refined9;zeros(1,num3+num6+num9);ones(1,num3)*3,ones(1,num6)*6,ones(1,num9)*9];
boundary_vector=[boundary_vector3,boundary_vector6,boundary_vector9];
boundary_vector1=[boundary_vector31,boundary_vector61,boundary_vector91];

if DisplayIntermediateResult % Intermediate Result 2
    figure; imshow(uint8(img_gray_double)); hold on;
    temp=find(refined(4,:)==3); plot3(refined(1,temp),refined(2,temp),temp,'r.');
    temp=find(refined(4,:)==6); plot3(refined(1,temp),refined(2,temp),temp,'g.');
    temp=find(refined(4,:)==9); plot3(refined(1,temp),refined(2,temp),temp,'b.');
    hold off;
end

len=size(boundary_vector,1);
len2=len/2;
flip=(boundary_vector.*[boundary_vector(2:end,:);boundary_vector(1,:)]<0|boundary_vector==0);
flip1=(boundary_vector1.*[boundary_vector1(2:end,:);boundary_vector1(1,:)]<0|boundary_vector1==0);
idx_flip=find(sum(flip)==4&sum(flip1)==4);

refined=refined(:,idx_flip);
boundary_vector=boundary_vector(:,idx_flip);
flip=flip(:,idx_flip);
flip1=flip1(:,idx_flip);
num=length(idx_flip);
[j,~]=ind2sub(size(flip),find(flip));
boundary_index=reshape(j,4,num);
[j,~]=ind2sub(size(flip),find(flip1));
boundary_index1=reshape(j,4,num);
refined(3,:)=abs(boundary_index(3,:)-boundary_index(1,:)-len2)+abs(boundary_index(4,:)-boundary_index(2,:)-len2);

if DisplayIntermediateResult % Intermediate Result 3
    figure; imshow(uint8(img_gray_double)); hold on;
    temp=find(refined(4,:)==3); plot3(refined(1,temp),refined(2,temp),temp,'r.');
    temp=find(refined(4,:)==6); plot3(refined(1,temp),refined(2,temp),temp,'g.');
    temp=find(refined(4,:)==9); plot3(refined(1,temp),refined(2,temp),temp,'b.');
    hold off;
end

idx=(abs(boundary_index(3,:)-boundary_index(1,:)-len2<=3)&abs(boundary_index(4,:)-boundary_index(2,:)-len2)<=3&max(abs(BoundaryIndexDifference(boundary_index,boundary_index1,len)),[],1)<=3);
refined=refined(:,idx);
boundary_vector=boundary_vector(:,idx);
boundary_index=boundary_index(:,idx);
num=size(refined,2);

if DisplayIntermediateResult % Intermediate Result 4
    figure; imshow(uint8(img_gray_double)); hold on;
    plot3(refined(1,:),refined(2,:),1:size(refined,2),'r.');
    hold off;
end

bin=true(1,num);
for j=1:num
    if bin(j)
        dist2=(refined(1,:)-refined(1,j)).^2+(refined(2,:)-refined(2,j)).^2;
        bin=bin&(dist2>=4|refined(3,:)<refined(3,j)|(refined(3,:)==refined(3,j)&refined(4,:)<refined(4,j)));
        bin(j)=true;
    end
end
refined=refined(:,bin);
boundary_index=boundary_index(:,bin);
boundary_vector=boundary_vector(:,bin);
num=size(refined,2);

if DisplayIntermediateResult % Intermediate Result 5
    figure; imshow(uint8(img_gray_double)); hold on;
    temp=find(refined(4,:)==3); plot3(refined(1,temp),refined(2,temp),temp,'r.');
    temp=find(refined(4,:)==6); plot3(refined(1,temp),refined(2,temp),temp,'g.');
    temp=find(refined(4,:)==9); plot3(refined(1,temp),refined(2,temp),temp,'b.');
    hold off;
end

[Gx,Gy]=gradient(img_gray_double);
bin=false(1,num);
for k=1:num
    r=refined(4,k);
    [i,j]=meshgrid(-r:r,-r:r);
    i=i(:)+round(refined(1,k));
    j=j(:)+round(refined(2,k));
    dx=i-refined(1,k);
    dy=j-refined(2,k);
    z=[dx,dy]*sample(:,boundary_index(:,k)');
    dist=dx.^2+dy.^2;
    idx1=find(z(:,1)>=z(:,2)&z(:,1)>=z(:,3)&z(:,1)>=z(:,4)&dist>=r^2/4&dist<=r^2);
    idx2=find(z(:,2)>=z(:,3)&z(:,2)>=z(:,4)&z(:,2)>=z(:,1)&dist>=r^2/4&dist<=r^2);
    idx3=find(z(:,3)>=z(:,4)&z(:,3)>=z(:,1)&z(:,3)>=z(:,2)&dist>=r^2/4&dist<=r^2);
    idx4=find(z(:,4)>=z(:,1)&z(:,4)>=z(:,2)&z(:,4)>=z(:,3)&dist>=r^2/4&dist<=r^2);
    idx1=sub2ind([sizeV,sizeH],j(idx1),i(idx1));
    idx2=sub2ind([sizeV,sizeH],j(idx2),i(idx2));
    idx3=sub2ind([sizeV,sizeH],j(idx3),i(idx3));
    idx4=sub2ind([sizeV,sizeH],j(idx4),i(idx4));
    
    g1=[sum(Gx(idx1));sum(Gy(idx1))]; g1=g1/norm(g1);
    g2=[sum(Gx(idx2));sum(Gy(idx2))]; g2=g2/norm(g2);
    g3=[sum(Gx(idx3));sum(Gy(idx3))]; g3=g3/norm(g3);
    g4=[sum(Gx(idx4));sum(Gy(idx4))]; g4=g4/norm(g4);
    [~,k1]=max(abs(g1'*[g3,g2,g4]));
    [~,k2]=max(abs(g2'*[g4,g1,g3]));
    [~,k3]=max(abs(g3'*[g1,g2,g4]));
    [~,k4]=max(abs(g4'*[g2,g1,g3]));
    if k1==1 && k2==1 && k3==1 && k4==1
        bin(k)=true;
    end
end
refined=refined(:,bin);
boundary_index=boundary_index(:,bin);
boundary_vector=boundary_vector(:,bin);
num=size(refined,2);

if DisplayIntermediateResult % Intermediate Result 6
    figure; imshow(uint8(img_gray_double)); hold on;
    temp=find(refined(4,:)==3); plot3(refined(1,temp),refined(2,temp),temp,'r.');
    temp=find(refined(4,:)==6); plot3(refined(1,temp),refined(2,temp),temp,'g.');
    temp=find(refined(4,:)==9); plot3(refined(1,temp),refined(2,temp),temp,'b.');
    hold off;
end

boundary_vector_correlation=false(num,num);
boundary_index_diff=false(num,num);

for j=1:num
    v1=max(boundary_vector(:,j));
    v2=max(boundary_vector,[],1);
    boundary_vector_correlation(j,:)=(boundary_vector(:,j)'*boundary_vector<0);
    boundary_index_diff(j,:)=(max(abs(BoundaryIndexDifference(repmat(boundary_index(:,j),1,num),boundary_index,len)),[],1)<=3)&(min(v1*ones(1,num),v2)>max(v1*ones(1,num),v2)*0.2);
end

CornerList=[];
max_assign_idx=[];

if num<=0
    return;
end

for iter=1:50
    n=ceil(rand(1)*num);
    temp=sample(:,boundary_index(:,n));
    diff=temp(:,1:2)-temp(:,3:4);
    if abs(diff(2,1)*diff(1,2))<abs(diff(1,1)*diff(2,2))
        lineX=cross([temp(:,1);1],[temp(:,3);1]);
        lineY=cross([temp(:,2);1],[temp(:,4);1]);
    else
        lineY=cross([temp(:,1);1],[temp(:,3);1]);
        lineX=cross([temp(:,2);1],[temp(:,4);1]);
    end
    lineX=lineX'/norm(lineX(1:2));
    lineY=lineY'/norm(lineY(1:2));
    if lineX(2)<0
        lineX=-lineX;
    end
    if lineY(1)<0
        lineY=-lineY;
    end
    diff=[refined(1,:)-refined(1,n);refined(2,:)-refined(2,n);ones(1,num)];
    dist=diff(1,:).^2+diff(2,:).^2;
    
    idx1=find(boundary_vector_correlation(n,:)&boundary_index_diff(n,:)&abs(lineX*diff)<abs(lineY*diff));
    if length(idx1)<2
        continue;
    end
    [~,idx]=min(dist(idx1)+(lineX*diff(:,idx1)).^2);
    idxX=idx1(idx);
    idx0=n;
    idx0_prev=0;
    while idx0~=idx0_prev
        idx0_prev=idx0;
        temp=refined(1:2,idxX)-refined(1:2,idx0_prev);
        idxX=ClosestPoint(idx0_prev,temp,refined,boundary_vector_correlation(idx0_prev,:),boundary_index_diff(idx0_prev,:));
        idx0=ClosestPoint(idxX,-temp,refined,boundary_vector_correlation(idxX,:),boundary_index_diff(idxX,:));
    end
    idxX2=ClosestPoint(idx0,-temp,refined,boundary_vector_correlation(idx0,:),boundary_index_diff(idx0,:));
    if idxX2<1
        continue;
    end
    idx02=ClosestPoint(idxX2,temp,refined,boundary_vector_correlation(idxX2,:),boundary_index_diff(idxX2,:));
    if idx02~=idx0
        continue;
    end
    if lineY*diff(:,idxX)<0
        idxX=idxX2;
    end
    
    idx1=find(boundary_vector_correlation(n,:)&boundary_index_diff(n,:)&abs(lineX*diff)>abs(lineY*diff));
    if length(idx1)<2
        continue;
    end
    [~,idx]=min(dist(idx1)+(lineY*diff(:,idx1)).^2);
    idxY=idx1(idx);
    temp=refined(1:2,idxY)-refined(1:2,idx0);
    idxY=ClosestPoint(idx0,temp,refined,boundary_vector_correlation(idx0,:),boundary_index_diff(idx0,:));
    idxY2=ClosestPoint(idx0,-temp,refined,boundary_vector_correlation(idx0,:),boundary_index_diff(idx0,:));
    if idxY<0 || idxY2<0
        continue;
    end
    if lineX*diff(:,idxY)<0
        idxY=idxY2;
    end

    world_coordinate=CoordinateExtension(n,idxX,idxY,refined,boundary_vector_correlation,boundary_index_diff);
    idx=find(~isinf(world_coordinate(1,:))&~isnan(world_coordinate(1,:)));
    if length(idx)>length(max_assign_idx)
        CornerList=[world_coordinate(:,idx);refined(:,idx)];
        max_assign_idx=idx;
    end
end

if DisplayIntermediateResult % Intermediate Result 7
    figure; imshow(uint8(img_gray_double)); hold on;
    temp=find(CornerList(6,:)==3); plot3(CornerList(3,temp),CornerList(4,temp),temp,'r.');
    temp=find(CornerList(6,:)==6); plot3(CornerList(3,temp),CornerList(4,temp),temp,'g.');
    temp=find(CornerList(6,:)==9); plot3(CornerList(3,temp),CornerList(4,temp),temp,'b.');
    hold off;
end

end