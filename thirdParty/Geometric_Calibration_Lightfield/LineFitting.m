function LineParam=LineFitting(img_gray_double,center,radius,initial,Template,TemplateSlope,TemplateDist,TemplateWeight)

center_int=round(center);
center_sub=center-center_int;
source=img_gray_double(center_int(2)-radius+1:center_int(2)+radius-1,center_int(1)-radius+1:center_int(1)+radius-1);
if sum(var(source,0,1))+sum(var(source,0,2))==0
    LineParam=[1,0,100];
    return;
end

slope_num=length(TemplateSlope(:,1));
dist_num=length(TemplateDist);

maxncc=0;
if length(initial)==2
    temp=initial/norm(initial);
    [~,idx]=min(abs(temp(1)*TemplateSlope(:,2)-temp(2)*TemplateSlope(:,1)));
    for i=5:10:dist_num
        template_line=cell2mat(Template(idx,i));
        ncc=abs(NCCw(source,template_line,TemplateWeight));
        if ncc>maxncc
            maxncc=ncc;
            LineParam=[TemplateSlope(idx,:),TemplateDist(i)+TemplateSlope(idx,:)*center_sub];
        end
    end
elseif length(initial)==3
    temp=initial/norm(initial(1:2));
    [~,idx1]=min(abs(temp(1)*TemplateSlope(:,2)-temp(2)*TemplateSlope(:,1)));
    dist_init=temp(3)-temp(1:2)*center_sub;
    [~,idx2]=min(abs(dist_init-TemplateDist));
    maxncc=0;
    for j=idx1-20:idx1+20
        if j<1
            J=j+slope_num;
        elseif j>slope_num
            J=j-slope_num;
        else
            J=j;
        end
        for i=idx2-20:idx2+20
            if i<1
                I=i+dist_num;
            elseif i>dist_num
                I=i-dist_num;
            else
                I=i;
            end
            template_line=cell2mat(Template(J,I));
            ncc=abs(NCCw(source,template_line,TemplateWeight));
            if ncc>maxncc
                maxncc=ncc;
                LineParam=[TemplateSlope(J,:),TemplateDist(I)+TemplateSlope(J,:)*center_sub];
            end
        end
    end
else
    for j=5:10:slope_num
        for i=5:10:dist_num
            template_line=cell2mat(Template(j,i));
            ncc=abs(NCCw(source,template_line,TemplateWeight));
            if ncc>maxncc
                maxncc=ncc;
                LineParam=[TemplateSlope(j,:),TemplateDist(i)+TemplateSlope(j,:)*center_sub];
            end
        end
    end
end

end

