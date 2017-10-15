[file1,path1]=uigetfile('L*.mat','Image','MultiSelect','on');
if length(path1)<2
    return;
end
if ~iscell(file1)
    file1=cellstr(file1);
end

sample_num=10000;

load([path1,'microlens_center_list.mat']);
ImageCenterInitial=image_size/2;

PatternSize=load([path1,'pattern_size.txt']);

ImageNum=length(file1);
singularvector=zeros(12,ImageNum*12);
singularvalue=zeros(12,ImageNum);

wh=[];
ch=[];
lh=[];
nh=[];
wv=[];
cv=[];
lv=[];
nv=[];

for n=1:length(file1)
    load([path1,file1{n}]);
    num_h=length(line_h(1,:));
    num_v=length(line_v(1,:));
    Q=zeros((num_h+num_v)*2,12);
    idx=0;

    for i=1:num_h
        a=line_h(1,i);
        b=line_h(2,i);
        c=line_h(3,i);
        idx=idx+2;
        p=[world_h(1,i)*PatternSize,world_h(2,i)*PatternSize,1];
        Q(idx-1,:)=[a*p,b*p,-(a*(center_h(1,i)-ImageCenterInitial(1))+b*(center_h(2,i)-ImageCenterInitial(2)))*p,c*p];
        p=[world_h(1,i)*PatternSize-PatternSize,world_h(2,i)*PatternSize,1];
        Q(idx,:)=[a*p,b*p,-(a*(center_h(1,i)-ImageCenterInitial(1))+b*(center_h(2,i)-ImageCenterInitial(2)))*p,c*p];
    end
    for i=1:num_v
        a=line_v(1,i);
        b=line_v(2,i);
        c=line_v(3,i);
        idx=idx+2;
        p=[world_v(1,i)*PatternSize,world_v(2,i)*PatternSize,1];
        Q(idx-1,:)=[a*p,b*p,-(a*(center_v(1,i)-ImageCenterInitial(1))+b*(center_v(2,i)-ImageCenterInitial(2)))*p,c*p];
        p=[world_v(1,i)*PatternSize,world_v(2,i)*PatternSize-PatternSize,1];
        Q(idx,:)=[a*p,b*p,-(a*(center_v(1,i)-ImageCenterInitial(1))+b*(center_v(2,i)-ImageCenterInitial(2)))*p,c*p];
    end
    
    sample=ceil(sort(rand(1,sample_num))*length(Q(:,1)));
    sample(sample(1:length(sample)-1)==sample(2:length(sample)))=[];
    Q=Q(sample,:);

    [U,D,V]=svd(Q);
    
    singularvector(:,n*12-11:n*12)=V;
    singularvalue(:,n)=diag(D);
    
    wh=[wh,world_h];
    ch=[ch,center_h];
    lh=[lh,line_h];
    nh=[nh,num_h];
    
    wv=[wv,world_v];
    cv=[cv,center_v];
    lv=[lv,line_v];
    nv=[nv,num_v];
end

f_=zeros(1,ImageNum);
for n=1:ImageNum
    v=singularvector(:,n*12);
    f_(n)=sqrt(-(v(1)*v(2)+v(4)*v(5))/(v(7)*v(8)));
end

f=median(f_(imag(f_)==0));

lambda_=zeros(1,ImageNum);
K1_=zeros(1,ImageNum);
K2_=zeros(1,ImageNum);
RT=zeros(1,ImageNum*6);
for n=1:ImageNum
    v=singularvector(:,n*12);
    r1=[v(1)/f;v(4)/f;v(7)];
    lambda_(n)=norm(r1);
    r1=r1/lambda_(n);
    r2=[v(2)/f;v(5)/f;v(8)];
    r3=cross(r1,r2);
    r3=r3/norm(r3);
    r2=cross(r3,r1);
    R=[r1,r2,r3];
    T=[v(3)/f;v(6)/f;v(9)]/lambda_(n);

    K1_(n)=(v(10)+v(11))/(R(3,1)+R(3,2))/lambda_(n);
    K2_(n)=v(12)/lambda_(n)-K1_(n)*T(3);
    
    if T(3)<0
        v=-v;
        R=[-R(:,1),-R(:,2),R(:,3)];
        T=-T;
        K1_(n)=-K1_(n);
        K2_(n)=-K2_(n);
    end
    
    RT(n*6-5:n*6)=GetAxis([R,T;0,0,0,1]);
end

K1=median(K1_);
K2=median(K2_);

option=optimset('LargeScale','on','Display','iter','TolFun',1e-10,'TolX',1e-10,'MaxFunEvals',100000,'MaxIter',1000);
pattern_size=ones(1,ImageNum)*PatternSize;
param_init=[K1,K2,f,f,ImageCenterInitial,0,0,RT];
param=lsqnonlin(@(x) LightFieldLineError(x,wh,ch,lh,nh,wv,cv,lv,nv,pattern_size),param_init,[],[],option);
IntParamLF=param(1:8);
for n=1:ImageNum
    ExtParamLF=SetAxis(param(n*6+3:n*6+8));
    save([path1,'ExtParamLF_',file1{n}(3:end-4),'.mat'],'ExtParamLF');
end
save([path1,'IntParamLF.mat'],'IntParamLF');

err=LightFieldLineError(param,wh,ch,lh,nh,wv,cv,lv,nv,pattern_size);
fprintf('RMS ray re-projection error: %f\n',sqrt(mean(err.^2)));
