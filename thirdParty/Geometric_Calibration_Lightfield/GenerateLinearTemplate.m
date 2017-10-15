function GenerateLinearTemplate(filename,radius)

TemplateAngle=(0.25:0.5:179.75)*pi/180;
TemplateSlope=[sin(TemplateAngle);cos(TemplateAngle)]';
TemplateDist=-radius+1.025:0.05:radius-1.025;
Template=cell(length(TemplateAngle),length(TemplateDist));
for j=1:length(TemplateAngle)
    for i=1:length(TemplateDist)
        Template(j,i)={LinearTemplate(radius-1,[TemplateSlope(j,:),TemplateDist(i)])};
    end
end
[i,j]=meshgrid(-radius+1:radius-1,-radius+1:radius-1);
TemplateWeight=exp((-i.*i-j.*j)/((radius-1)^2*3));

save(filename,'TemplateAngle','TemplateSlope','TemplateDist','Template','TemplateWeight');

end

function template=LinearTemplate(size_half,line_param)

size1=size_half*2+1;
template=zeros(size1,size1);
[I,J]=meshgrid(-size_half-0.5:size_half+0.5,-size_half-0.5:size_half+0.5);
d=line_param(1)*I+line_param(2)*J+line_param(3);
d(d<0)=-1;
d(d>=0)=1;
intersection_x=(-line_param(2)*(-size_half-0.5:size_half+0.5)-line_param(3))/line_param(1);
intersection_y=(-line_param(1)*(-size_half-0.5:size_half+0.5)-line_param(3))/line_param(2);
for j=1:size1
    for i=1:size1
        sum=d(j,i)+d(j,i+1)+d(j+1,i)+d(j+1,i+1);
        if sum==4
            template(j,i)=1;
        elseif sum==-4
            template(j,i)=0;
        elseif abs(sum)==2
            if d(j,i)*sum<0
                temp=abs(intersection_x(j)+size_half+1.5-i)*abs(intersection_y(i)+size_half+1.5-j)*0.5;
            elseif d(j,i+1)*sum<0
                temp=(1-abs(intersection_x(j)+size_half+1.5-i))*abs(intersection_y(i+1)+size_half+1.5-j)*0.5;
            elseif d(j+1,i)*sum<0
                temp=abs(intersection_x(j+1)+size_half+1.5-i)*(1-abs(intersection_y(i)+size_half+1.5-j))*0.5;
            else
                temp=(1-abs(intersection_x(j+1)+size_half+1.5-i))*(1-abs(intersection_y(i+1)+size_half+1.5-j))*0.5;
            end
            if sum>0
                template(j,i)=1-temp;
            else
                template(j,i)=temp;
            end
        else
            if d(j,i)+d(j,i+1)==0
                temp=(abs(intersection_x(j)+size_half+1.5-i)+abs(intersection_x(j+1)+size_half+1.5-i))*0.5;
            else
                temp=(abs(intersection_y(i)+size_half+1.5-j)+abs(intersection_y(i+1)+size_half+1.5-j))*0.5;
            end
            if d(j,i)>0
                template(j,i)=temp;
            else
                template(j,i)=1-temp;
            end
        end
    end
end

end