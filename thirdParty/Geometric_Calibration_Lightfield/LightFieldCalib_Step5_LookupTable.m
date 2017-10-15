[file1,path1]=uigetfile('*.mat','Intrinsic Parameter');
if length(path1)<2
    return;
end
load([path1,file1]);
load([path1,'microlens_center_list.mat']);

f=max(IntParamLF(3:4));
scale=radius*2;
SubIntParam=[IntParamLF(3)/scale,0,IntParamLF(5)/scale;0,IntParamLF(3)/scale,IntParamLF(6)/scale;0,0,1];

width=floor(image_size(1)/scale);
height=floor(image_size(2)/scale);
interp_init=[ones(3,width*height);zeros(3,width*height)];

SubApertureSample=cell(radius*2-1,radius*2-1);
SubApertureInterpolation=cell(radius*2-1,radius*2-1);
SubExtParam_=cell(radius*2-1,radius*2-1);
Unit=1/f;
[xc,yc]=RemoveDistortion((center_list(1,:)-IntParamLF(5))/IntParamLF(3),(center_list(2,:)-IntParamLF(6))/IntParamLF(4),IntParamLF(7),IntParamLF(8));
for j=-radius+1:radius-1
    dy=j*Unit;
    for i=-radius+1:radius-1
        fprintf('Processing (%d,%d) of (%d:%d,%d:%d)\n',j,i,-radius+1,radius-1,-radius+1,radius-1);
        dx=i*Unit;
        x=xc+dx;
        y=yc+dy;
        [xx,yy]=AddDistortionIteration(x,y,IntParamLF(7),IntParamLF(8),10);
        xr=IntParamLF(1)*dx+xc;
        yr=IntParamLF(1)*dy+yc;
        SubApertureSample{j+radius,i+radius}=[xx*IntParamLF(3)+IntParamLF(5);yy*IntParamLF(4)+IntParamLF(6)];
        sample=[xr*SubIntParam(1,1)+SubIntParam(1,3);yr*SubIntParam(2,2)+SubIntParam(2,3)];
        
        SubExtParam_{j+radius,i+radius}=diag(ones(1,4));
        SubExtParam_{j+radius,i+radius}(1:2,4)=-IntParamLF(2)*[dx;dy];
        
        SubApertureInterpolation{j+radius,i+radius}=interp_init;
        [~,idx_row_start]=min((1-sample(2,:)).^2+(1-sample(1,:)).^2);
        for k=1:width*height
            [J,I]=ind2sub([height,width],k);
            if I==1
                idx_prev=idx_row_start;
            else
                idx_prev=idx;
            end
            while true
                candidate=center_connection(:,idx_prev)';
                [~,idx]=min((J-sample(2,candidate)).^2+(I-sample(1,candidate)).^2);
                idx=candidate(idx);
                if idx==idx_prev
                    break;
                else
                    idx_prev=idx;
                end
            end
            if I==1
                idx_row_start=idx;
            end
            t=[I;J];
            s=sample(:,idx);
            idx7=center_connection(:,idx)';
            s7=sample(:,idx7);
            for k1=1:length(idx7)-1
                s1=s7(:,k1);
                for k2=k1+1:length(idx7)
                    s2=s7(:,k2);
                    if (s1-s)'*(s2-s)>0
                        source=[idx,idx7(k1),idx7(k2)];
                        weight=InterpolationTriangleWeight(t,sample(:,source));
                        if weight(1)>=0 && weight(2)>=0 && weight(3)>=0
                            SubApertureInterpolation{j+radius,i+radius}(1:6,k)=[source,weight]';
                            break;
                        end
                    end
                end
                if sum(SubApertureInterpolation{j+radius,i+radius}(1:3,k))>3
                    break;
                end
            end
        end
    end
end

SubImageSize=[width,height];
save([path1,'SubApertureInfo.mat'],'SubApertureSample','SubApertureInterpolation','SubIntParam','SubExtParam_','SubImageSize');
