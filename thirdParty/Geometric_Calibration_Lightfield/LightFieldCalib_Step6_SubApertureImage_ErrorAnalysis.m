[file1,path1]=uigetfile('*.png','Raw Image','MultiSelect','on');
if length(path1)<2
    return;
end
if ~iscell(file1)
    file1=cellstr(file1);
end

location='SubAperture\';
extfile='ExtParamLF_';

if exist([path1,location],'dir')~=7
    mkdir(path1,location);
end

load([path1,'microlens_center_list.mat'],'radius');

pattern_size=load([path1,'pattern_size.txt']);

ProjectionError=cell(length(file1),radius*2-1,radius*2-1);
RayReprojectionError=cell(length(file1),radius*2-1,radius*2-1);

for n=1:length(file1)
    file2=file1{n}(1:end-4);
    load([path1,extfile,file2,'.mat']);
    for j=-radius+1:radius-1
        for i=-radius+1:radius-1
            file3=sprintf('_Sub_%d_%d',j+radius,i+radius);
            load([path1,location,file2,file3,'.mat']);
            ProjectionError{n,j+radius,i+radius}=sqrt((SubCorner(3,:)-SubCorner(5,:)).^2+(SubCorner(4,:)-SubCorner(6,:)).^2);
            ray=inv(SubIntParam)*[SubCorner(3:4,:);ones(1,size(SubCorner,2))];
            point=SubExtParam*ExtParamLF*[SubCorner(1:2,:)*pattern_size;zeros(1,size(SubCorner,2));ones(1,size(SubCorner,2))];
            scale=(ray(1,:).*point(1,:)+ray(2,:).*point(2,:)+ray(3,:).*point(3,:))./(ray(1,:).^2+ray(2,:).^2+ray(3,:).^2);
            RayReprojectionError{n,j+radius,i+radius}=sqrt((ray(1,:).*scale-point(1,:)).^2+(ray(2,:).*scale-point(2,:)).^2+(ray(3,:).*scale-point(3,:)).^2);
        end
    end
end

ProjectionErrorGrid=zeros(radius*2-1,radius*2-1);
RayReprojectionErrorGrid=zeros(radius*2-1,radius*2-1);
num=zeros(radius*2-1,radius*2-1);
ProjectionErrorRMS=0;
RayReprojectionErrorRMS=0;
ProjectionErrorRMS_Inside=0;
RayReprojectionErrorRMS_Inside=0;
num2=0;
for j=-radius+1:radius-1
    for i=-radius+1:radius-1
        for n=1:length(file1)
            ProjectionErrorGrid(j+radius,i+radius)=ProjectionErrorGrid(j+radius,i+radius)+sum(ProjectionError{n,j+radius,i+radius}.^2);
            RayReprojectionErrorGrid(j+radius,i+radius)=RayReprojectionErrorGrid(j+radius,i+radius)+sum(RayReprojectionError{n,j+radius,i+radius}.^2);
            ProjectionErrorRMS=ProjectionErrorRMS+sum(ProjectionError{n,j+radius,i+radius}.^2);
            RayReprojectionErrorRMS=RayReprojectionErrorRMS+sum(RayReprojectionError{n,j+radius,i+radius}.^2);
            num(j+radius,i+radius)=num(j+radius,i+radius)+size(ProjectionError{n,j+radius,i+radius},2);
            if i^2+j^2<(radius-1)^2
                ProjectionErrorRMS_Inside=ProjectionErrorRMS_Inside+sum(ProjectionError{n,j+radius,i+radius}.^2);
                RayReprojectionErrorRMS_Inside=RayReprojectionErrorRMS_Inside+sum(RayReprojectionError{n,j+radius,i+radius}.^2);
                num2=num2+size(ProjectionError{n,j+radius,i+radius},2);
            end
        end
    end
end
ProjectionErrorGrid=sqrt(ProjectionErrorGrid./num);
RayReprojectionErrorGrid=sqrt(RayReprojectionErrorGrid./num);
ProjectionErrorRMS=sqrt(ProjectionErrorRMS/sum(num(:)));
RayReprojectionErrorRMS=sqrt(RayReprojectionErrorRMS/sum(num(:)));
ProjectionErrorRMS_Inside=sqrt(ProjectionErrorRMS_Inside/num2);
RayReprojectionErrorRMS_Inside=sqrt(RayReprojectionErrorRMS_Inside/num2);
