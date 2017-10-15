function center=MicroLensCenter(vig,center_initial,radius,iteration)

radius_int=ceil(radius);
filename=sprintf('Concentric%d.mat',radius_int);
if exist(filename)
    load(filename);
else
    concentric=[0;0];
    for n=1:radius_int-1
        angle=(1:n*6)*(pi/n/3);
        concentric=[concentric,n*[cos(angle);sin(angle)]];
    end
    concentric_num=length(concentric(1,:));
    save(filename,'concentric','concentric_num');
end

center_num=length(center_initial(1,:));

center_x=center_initial(1,:)';
center_y=center_initial(2,:)';
for iter=1:iteration
    loc_x=ones(center_num,1)*concentric(1,:)+center_x*ones(1,concentric_num);
    x=reshape(loc_x,1,center_num*concentric_num);
    loc_y=ones(center_num,1)*concentric(2,:)+center_y*ones(1,concentric_num);
    y=reshape(loc_y,1,center_num*concentric_num);
    val=reshape(Interpolation4_Color([x;y],vig),center_num,concentric_num);
    center_x=sum(loc_x.*val,2)./sum(val,2);
    center_y=sum(loc_y.*val,2)./sum(val,2);
end
center=[center_x,center_y]';

center(:,min(val,[],2)<0)=-1;
center(:,center_initial(1,:)<radius_int|center_initial(1,:)>=length(vig(1,:))-radius_int+1|center_initial(2,:)<radius_int|center_initial(2,:)>=length(vig(:,1))-radius_int+1)=-1;

end
