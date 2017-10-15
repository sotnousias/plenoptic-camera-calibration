[file1,path1]=uigetfile('*.png','Raw Image','MultiSelect','on');
if length(path1)<2
    return;
end
if ~iscell(file1)
    file1=cellstr(file1);
end

DetectCorner=false;

load([path1,'SubApertureInfo.mat']);
load([path1,'microlens_center_list.mat'],'radius');
location='SubAperture\';
extfile='ExtParamLF_';

if exist([path1,location],'dir')~=7
    mkdir(path1,location);
end

if DetectCorner
    pattern_size=load([path1,'pattern_size.txt']);
end

for n=1:length(file1)
    file0=char(file1(n));
    temp=imread([path1,file0]);
    source_type=class(temp);
    raw=double(temp);
    B=size(temp,3);
    file2=file0(1:length(file0)-4);
    file_corner=['CI_',file2,'.mat'];
    extfile2=[extfile,file2,'.mat'];

    img=zeros(SubImageSize(2),SubImageSize(1),B);
    for j=-radius+1:radius-1
        jj=j+radius;
        for i=-radius+1:radius-1
            ii=i+radius;
            s=Interpolation4_Color(SubApertureSample{jj,ii},raw);
            s1=s(:,SubApertureInterpolation{jj,ii}(1,:));
            s2=s(:,SubApertureInterpolation{jj,ii}(2,:));
            s3=s(:,SubApertureInterpolation{jj,ii}(3,:));
            tmp=repmat(SubApertureInterpolation{jj,ii}(4,:),B,1).*s1+repmat(SubApertureInterpolation{jj,ii}(5,:),B,1).*s2+repmat(SubApertureInterpolation{jj,ii}(6,:),B,1).*s3;
            for b=1:B
                img(:,:,b)=reshape(tmp(b,:),SubImageSize(2),SubImageSize(1));
            end
            
            file3=sprintf('_Sub_%d_%d',jj,ii);
            switch source_type
                case 'uint8'
                    imwrite(uint8(round(img)),[path1,location,file2,file3,'.png']);
                case 'uint16'
                    imwrite(uint16(round(img)),[path1,location,file2,file3,'.png']);
            end
            SubExtParam=SubExtParam_{jj,ii};
            
            if DetectCorner && exist([path1,file_corner],'file')>0 && exist([path1,extfile2],'file')>0
                load([path1,file_corner]);
                corner_num=length(corner(1,:));
                load([path1,extfile,file2,'.mat']);

                corner_initial=SubIntParam*SubExtParam(1:3,:)*ExtParamLF*[corner(1:2,:)*pattern_size;zeros(1,length(corner(1,:)));ones(1,length(corner(1,:)))];
                corner_initial=[corner_initial(1,:)./corner_initial(3,:);corner_initial(2,:)./corner_initial(3,:)];
                corner_winsize=zeros(1,corner_num);

                SubCorner=zeros(6,size(corner,2));
                for winsize=3:3:9
                    idx=find(corner(6,:)==winsize);
                    SubCorner(:,idx)=[corner(1:2,idx);CornerRefinement(corner_initial(:,idx),img,winsize);corner_initial(:,idx)];
%                     SubCorner(:,idx)=[corner(1:2,idx);CornerRefinement(corner_initial(:,idx),img,3);corner_initial(:,idx)];
                end
%                 corner3=CornerRefinement(corner_initial,img,3);
%                 corner6=CornerRefinement(corner_initial,img,6);
%                 corner9=CornerRefinement(corner_initial,img,9);
%                 diff3=sum((corner3-corner_initial).^2,1);
%                 diff6=sum((corner6-corner_initial).^2,1);
%                 diff9=sum((corner9-corner_initial).^2,1);
%                 [~,idx]=min([diff3;diff6;diff9],[],1);
%                 SubCorner(:,idx==1)=[corner(1:2,idx==1);corner3(:,idx==1);corner_initial(:,idx==1)];
%                 SubCorner(:,idx==2)=[corner(1:2,idx==2);corner6(:,idx==2);corner_initial(:,idx==2)];
%                 SubCorner(:,idx==3)=[corner(1:2,idx==3);corner3(:,idx==3);corner_initial(:,idx==3)];
                SubCorner=SubCorner(:,~isnan(SubCorner(3,:)));

                save([path1,location,file2,file3,'.mat'],'SubIntParam','SubExtParam','SubCorner');
            else
                save([path1,location,file2,file3,'.mat'],'SubIntParam','SubExtParam');
            end
        end
    end
end
