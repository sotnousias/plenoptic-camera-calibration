[file1,path1]=uigetfile('*.png;*.jpg','Image','MultiSelect','on');
if length(path1)<2
    return;
end
if ~iscell(file1)
    file1=cellstr(file1);
end

load([path1,'microlens_center_list.mat']);

ImageNum=length(file1);
for n=1:ImageNum
    temp=imread([path1,file1{n}]);
    source_type=class(temp);
    img_raw=double(temp);
    b=size(img_raw,3);
    
    fprintf('Processing : %s',file1{n});
    
    idx=reshape(CenterImageInfo(1:3,:),1,3*size(CenterImageInfo,2));
    s1=Interpolation4_Color(center_list(:,CenterImageInfo(1,:)),img_raw);
    s2=Interpolation4_Color(center_list(:,CenterImageInfo(2,:)),img_raw);
    s3=Interpolation4_Color(center_list(:,CenterImageInfo(3,:)),img_raw);
    interp=s1.*repmat(CenterImageInfo(4,:),b,1)+s2.*repmat(CenterImageInfo(5,:),b,1)+s3.*repmat(CenterImageInfo(6,:),b,1);
    img_center=zeros(CenterImageSize(2),CenterImageSize(1),b);
    for k=1:b
        img_center(:,:,k)=reshape(interp(k,:),CenterImageSize(2),CenterImageSize(1));
    end

    switch source_type
        case 'uint8'
            img_center=uint8(round(img_center));
        case 'uint16'
            img_center=uint8(round(img_center/256));
    end
    imwrite(img_center,[path1,'CI_',file1{n}(1:end-4),'.bmp']);

    fprintf(' CenterImage');
    
    corner=CheckerboardCorner(double(rgb2gray(img_center)));
    
    save([path1,'CI_',file1{n}(1:end-4),'.mat'],'corner');
    
    fprintf(' CornerList\n');
end
