function vector=BoundaryVector(img_gray_double,center_list,radius)

a=(0:10:360)*pi/180;
a(end)=[];
sample=radius*[cos(a);sin(a)];

sample_len=size(sample,2);
center_num=size(center_list,2);
img_size=size(img_gray_double);

center_x=center_list(1,:);
center_y=center_list(2,:);

temp_x=repmat(center_x,sample_len,1)+repmat(sample(1,:)',1,center_num);
temp_y=repmat(center_y,sample_len,1)+repmat(sample(2,:)',1,center_num);
temp_lx=floor(temp_x);
temp_ly=floor(temp_y);
temp_dx=temp_x-temp_lx;
temp_dy=temp_y-temp_ly;
temp_rx=temp_lx+1;
temp_ry=temp_ly+1;
temp_ll=sub2ind(img_size,temp_ly,temp_lx);
temp_lr=sub2ind(img_size,temp_ry,temp_lx);
temp_rl=sub2ind(img_size,temp_ly,temp_rx);
temp_rr=sub2ind(img_size,temp_ry,temp_rx);
weight_ll=(1-temp_dx).*(1-temp_dy);
weight_lr=(1-temp_dx).*(temp_dy);
weight_rl=(temp_dx).*(1-temp_dy);
weight_rr=(temp_dx).*(temp_dy);
intensity_ll=img_gray_double(temp_ll);
intensity_lr=img_gray_double(temp_lr);
intensity_rl=img_gray_double(temp_rl);
intensity_rr=img_gray_double(temp_rr);
temp=intensity_ll.*weight_ll+intensity_lr.*weight_lr+intensity_rl.*weight_rl+intensity_rr.*weight_rr;
vector=temp-repmat(min(temp)*0.5+max(temp)*0.5,sample_len,1);

end