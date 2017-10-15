function cost=LightFieldLineError(Param,world_h,center_h,line_h,num_h,world_v,center_v,line_v,num_v,pattern_size)



%canceled the distortion
ImageNum=length(num_h);
ParamNum=8;

if length(num_v)~=ImageNum || length(Param)<ParamNum+6*ImageNum || length(pattern_size)<ImageNum
    error('LightFieldLineError : Different number of frames');
end
if sum(num_h)>length(world_h) || sum(num_h)>length(center_h) || sum(num_h)>length(line_h)
    error('LightFieldLineError : Unexpected number of features (H)');
end
if sum(num_v)>length(world_v) || sum(num_v)>length(center_v) || sum(num_v)>length(line_v)
    error('LightFieldLineError : Unexpected number of features (V)');
end

K1=Param(1);
K2=Param(2);
fx=Param(3);
fy=Param(4);
cx=Param(5);
cy=Param(6);
k1=Param(7);
k2=Param(8);

idxh=0;
idxv=0;
idxc=0;

cost=zeros(1,sum(num_h)*3+sum(num_v)*3);

for n=1:ImageNum
    nh=num_h(n);
    nv=num_v(n);
    wh=world_h(:,idxh+1:idxh+nh);
    ch=center_h(:,idxh+1:idxh+nh);
    lh=line_h(:,idxh+1:idxh+nh);
    wv=world_v(:,idxv+1:idxv+nv);
    cv=center_v(:,idxv+1:idxv+nv);
    lv=line_v(:,idxv+1:idxv+nv);
    RT=SetAxis(Param(n*6+ParamNum-5:n*6+ParamNum));
    RT=RT(1:3,:);
    ps=pattern_size(n);
    
    Q1=RT*[wh(1,:)*ps;wh(2,:)*ps;zeros(1,nh);ones(1,nh)];
    Q2=RT*[wh(1,:)*ps-ps;wh(2,:)*ps;zeros(1,nh);ones(1,nh)];
    
    u=-lh(1,:).*lh(3,:)+ch(1,:);
    v=-lh(2,:).*lh(3,:)+ch(2,:);
    [xc,yc]=RemoveDistortion((ch(1,:)-cx)/fx,(ch(2,:)-cy)/fy,k1,k2);
    [x,y]=RemoveDistortion((u-cx)/fx,(v-cy)/fy,k1,k2);
    xr=K1*(x-xc)+xc;
    yr=K1*(y-yc)+yc;
    X0=K2*(x-xc);
    Y0=K2*(y-yc);
    
    cost(idxc+1:idxc+nh)=VectLineDist([X0;Y0;zeros(1,nh)],[xr;yr;ones(1,nh)],Q1,Q2);
    idxc=idxc+nh;
    
    Q1=RT*[wv(1,:)*ps;wv(2,:)*ps;zeros(1,nv);ones(1,nv)];
    Q2=RT*[wv(1,:)*ps;wv(2,:)*ps-ps;zeros(1,nv);ones(1,nv)];

    u=-lv(1,:).*lv(3,:)+cv(1,:);
    v=-lv(2,:).*lv(3,:)+cv(2,:);
    [xc,yc]=RemoveDistortion((cv(1,:)-cx)/fx,(cv(2,:)-cy)/fy,k1,k2);
    [x,y]=RemoveDistortion((u-cx)/fx,(v-cy)/fy,k1,k2);
    xr=K1*(x-xc)+xc;
    yr=K1*(y-yc)+yc;
    X0=K2*(x-xc);
    Y0=K2*(y-yc);
    cost(idxc+1:idxc+nv)=VectLineDist([X0;Y0;zeros(1,nv)],[xr;yr;ones(1,nv)],Q1,Q2);
    idxc=idxc+nv;

    idxh=idxh+nh;
    idxv=idxv+nv;
end

end

function dist=VectLineDist(q0,dr,q1,q2)

q01=q0-q1;
q21=q2-q1;
q01dr=sum(q01.*dr,1);
q21dr=sum(q21.*dr,1);
dr_2=sum(dr.^2,1);
q21_2=sum(q21.^2,1);
q01q21=sum(q01.*q21,1);
l1=(q01q21.*q21dr-q01dr.*q21_2)./(dr_2.*q21_2-(q21dr).^2);
l2=(q01q21.*dr_2-q01dr.*q21dr)./(dr_2.*q21_2-(q21dr).^2);
dist=sqrt(sum((q0+repmat(l1,3,1).*dr-q1-repmat(l2,3,1).*q21).^2,1));

end