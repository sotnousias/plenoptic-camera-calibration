[file1,path1]=uigetfile('*.png','Image','MultiSelect','on');
if length(path1)<2
    return;
end

if length(char(file1(1)))==1
    temp=file1;
    file1=cell(1,1);
    file1(1,1)=java.lang.String(temp);
end

load([path1,'microlens_center_list.mat']);

ImageNum=length(file1);
for n=1:ImageNum
    filename=char(file1(n));
    filename2=filename;
    len=length(filename2);
    filename2(len-2:len)='txt';
    temp=imread([path1,filename]);
    source_type=class(temp);
    if length(size(temp))>2
        img_double=double(rgb2gray(temp));
    else
        img_double=double(temp);
    end
    
    filename3=filename;
    filename3(len-2:len)='mat';
    load([path1,'L_',filename3]);
    
    figure;
    switch source_type
        case 'uint8'
            imshow(uint8(img_double));
        case 'uint16'
            imshow(uint16(img_double));
    end
    hold on;

    b=[-radius+0.5,radius-0.5];
    for i=1:length(line_h(1,:))
        boundary=[b;-(b*line_h(1,i)+line_h(3,i))/line_h(2,i)];
        plot(boundary(1,:)+center_h(1,i),boundary(2,:)+center_h(2,i),'g-','LineWidth',1);
    end
    for i=1:length(line_v(1,:))
        boundary=[-(b*line_v(2,i)+line_v(3,i))/line_v(1,i);b];
        plot(boundary(1,:)+center_v(1,i),boundary(2,:)+center_v(2,i),'g-','LineWidth',1);
    end
    plot(center_h(1,:),center_h(2,:),'r.','MarkerSize',5);
    plot(center_v(1,:),center_v(2,:),'r.','MarkerSize',5);
    hold off;
end

