function img_center=CenterImage(img_raw,center_list,center_connection,radius)

temp=size(img_raw);
height=temp(1);
width=temp(2);
if length(temp)>2
    depth=temp(3);
else
    depth=1;
end

scale=radius*2;

source=[center_list;Interpolation4_Color(center_list,img_raw)];

height_scaled=length(0.5+scale*0.5:scale:height);
width_scaled=length(0.5+scale*0.5:scale:width);
img_center=zeros(height_scaled,width_scaled,depth);

[~,idx_row_start]=min((0.5+scale*0.5-center_list(1,:)).^2+(0.5+scale*0.5-center_list(2,:)).^2);
for j=1:height_scaled
    J=0.5+scale*0.5+scale*(j-1);
    for i=1:width_scaled
        I=0.5+scale*0.5+scale*(i-1);
        if i==1
            idx_prev=idx_row_start;
        else
            idx_prev=idx;
        end
        while true
            candidate=center_connection(:,idx_prev)';
            [~,idx]=min((J-center_list(2,candidate)).^2+(I-center_list(1,candidate)).^2);
            idx=candidate(idx);
            if idx==idx_prev
                break;
            else
                idx_prev=idx;
            end
        end
        if i==1
            idx_row_start=idx;
        end

        center_temp=center_list(:,idx);
        idx7=center_connection(:,idx)';
        center_neighbor=center_list(:,idx7);
        target=[I;J];

        value_set=false;
        for k=1:6
            for l=k+1:7
                if (center_neighbor(:,k)-center_temp)'*(center_neighbor(:,l)-center_temp)>0
                    v1=center_neighbor(:,k)-center_temp;
                    v2=target-center_temp;
                    v3=center_neighbor(:,l)-center_neighbor(:,k);
                    v4=target-center_neighbor(:,k);
                    v5=center_temp-center_neighbor(:,l);
                    v6=target-center_neighbor(:,l);
                    c1=v1(1)*v2(2)-v1(2)*v2(1);
                    c2=v3(1)*v4(2)-v3(2)*v4(1);
                    c3=v5(1)*v6(2)-v5(2)*v6(1);
                    if (c1>=0 && c2>=0 && c3>=0) || (c1<=0 && c2<=0 && c3<=0)
                        weight=InterpolationTriangleWeight(target,source(1:2,[idx,idx7(k),idx7(l)]));
                        img_center(j,i,:)=weight(1)*source(3:end,idx)+weight(2)*source(3:end,idx7(k))+weight(3)*source(3:end,idx7(l));
                        value_set=true;
                        break;
                    end
                end
            end
            if value_set
                break;
            end
        end
        if ~value_set
            [~,idx]=min((I-center_list(1,:)).^2+(J-center_list(1,:)).^2);
        end
    end
end

end