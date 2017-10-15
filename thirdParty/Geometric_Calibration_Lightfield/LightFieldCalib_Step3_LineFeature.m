[file1,path1]=uigetfile('*.png','Image','MultiSelect','on');
if length(path1)<2
    return;
end
if ~iscell(file1)
    file1=cellstr(file1);
end

load([path1,'microlens_center_list.mat']);

scale=radius*2;
center_list_scale=(center_list-0.5-scale*0.5)/scale+1;
center_num=length(center_list_scale(1,:));

feature_distance_max_for_line_fitting=radius*0.5;
distance_scale_for_corner_removal=1.6;

option=optimset('LargeScale','on','Display','off','TolFun',1e-10,'TolX',1e-10,'MaxFunEvals',100000);

TemplateName=sprintf('LinearTemplate%d.mat',radius);
if ~exist(TemplateName)
    GenerateLinearTemplate(TemplateName,radius);
end
load(TemplateName);

ImageNum=length(file1);
for n=1:ImageNum
    temp=imread([path1,file1{n}]);
    source_type=class(temp);
    if size(temp,3)==3
        img_double=double(rgb2gray(temp));
    else
        img_double=double(temp);
    end
    load([path1,'CI_',file1{n}(1:end-4),'.mat']);
    
    fprintf('Processing : %s',file1{n});
    
    world_h=-10000*ones(2,center_num);
    world_v=-10000*ones(2,center_num);
    line_idx_h=zeros(1,center_num);
    line_idx_v=zeros(1,center_num);

    line_dist_h=zeros(6,1000);
    line_dist_h_num=0;
    line_dist_v=zeros(6,1000);
    line_dist_v_num=0;

    for k1=1:length(corner(1,:))
        k2=find(corner(1,:)==corner(1,k1)-1&corner(2,:)==corner(2,k1));
        if ~isempty(k2)
            line_center=(corner(3:4,k2)+corner(3:4,k1))*0.5;
            [~,idx]=sort((center_list_scale(1,:)-line_center(1)).^2+(center_list_scale(2,:)-line_center(2)).^2);

            line=cross([corner(3:4,k1);1],[corner(3:4,k2);1]);
            line=line/norm(line(1:2));

            fitting_result=zeros(3,100);
            for i=1:100
                fitting_result(1:3,i)=LineFitting(img_double,center_list(:,idx(i)),radius,line(1:2),Template,TemplateSlope,TemplateDist,TemplateWeight);
                if abs(fitting_result(3,i))>feature_distance_max_for_line_fitting
                    fitting_result=fitting_result(:,1:i-1);
                    break;
                end
            end
            l=length(fitting_result(1,:));

            line_refined=line;
            temp=line_refined'*[center_list_scale(:,idx(1:l));ones(1,l)];
            x=abs(temp);
            y=abs(fitting_result(3,:));
            slope=sum(y)/sum(x);
            line_dist_h_num=line_dist_h_num+1;
            line_dist_h(:,line_dist_h_num)=[k1;k2;line_refined;feature_distance_max_for_line_fitting/slope];
        end

        k2=find(corner(1,:)==corner(1,k1)&corner(2,:)==corner(2,k1)-1);
        if ~isempty(k2)
            line_center=(corner(3:4,k2)+corner(3:4,k1))*0.5;
            [~,idx]=sort((center_list_scale(1,:)-line_center(1)).^2+(center_list_scale(2,:)-line_center(2)).^2);

            line=cross([corner(3:4,k1);1],[corner(3:4,k2);1]);
            line=line/norm(line(1:2));

            fitting_result=zeros(3,100);
            for i=1:100
                fitting_result(1:3,i)=LineFitting(img_double,center_list(:,idx(i)),radius,line(1:2),Template,TemplateSlope,TemplateDist,TemplateWeight);
                if abs(fitting_result(3,i))>feature_distance_max_for_line_fitting
                    fitting_result=fitting_result(:,1:i-1);
                    break;
                end
            end
            l=length(fitting_result(1,:));

            line_refined=line;
            temp=line_refined'*[center_list_scale(:,idx(1:l));ones(1,l)];
            x=abs(temp);
            y=abs(fitting_result(3,:));
            slope=sum(y)/sum(x);
            line_dist_v_num=line_dist_v_num+1;
            line_dist_v(:,line_dist_v_num)=[k1;k2;line_refined;feature_distance_max_for_line_fitting/slope];
        end
    end
    line_dist_h=line_dist_h(:,1:line_dist_h_num);
    line_dist_v=line_dist_v(:,1:line_dist_v_num);

    for k=1:line_dist_h_num
        k1=line_dist_h(1,k);
        k2=line_dist_h(2,k);
        k11=find(line_dist_v(1,:)==k1);
        k12=find(line_dist_v(2,:)==k1);
        k21=find(line_dist_v(1,:)==k2);
        k22=find(line_dist_v(2,:)==k2);
        if (isempty(k11) && isempty(k12)) || (isempty(k21) && isempty(k22))
            continue;
        end

        line=line_dist_h(3:5,k);
        dist_line=abs(line'*[center_list_scale;ones(1,center_num)]);
        angle1=(corner(3:4,k2)-corner(3:4,k1))'*(center_list_scale-corner(3:4,k1)*ones(1,center_num));
        angle2=(corner(3:4,k1)-corner(3:4,k2))'*(center_list_scale-corner(3:4,k2)*ones(1,center_num));
        index=find(dist_line<line_dist_h(6,k)&angle1>0&angle2>0);

        index2=ones(1,length(index));
        if ~isempty(k11)
            dist_line11=abs(line_dist_v(3:5,k11)'*[center_list_scale(:,index);ones(1,length(index))]);
            index2(dist_line11<line_dist_v(6,k11)*distance_scale_for_corner_removal)=0;
        end
        if ~isempty(k12)
            dist_line12=abs(line_dist_v(3:5,k12)'*[center_list_scale(:,index);ones(1,length(index))]);
            index2(dist_line12<line_dist_v(6,k12)*distance_scale_for_corner_removal)=0;
        end
        if ~isempty(k21)
            dist_line21=abs(line_dist_v(3:5,k21)'*[center_list_scale(:,index);ones(1,length(index))]);
            index2(dist_line21<line_dist_v(6,k21)*distance_scale_for_corner_removal)=0;
        end
        if ~isempty(k22)
            dist_line22=abs(line_dist_v(3:5,k22)'*[center_list_scale(:,index);ones(1,length(index))]);
            index2(dist_line22<line_dist_v(6,k22)*distance_scale_for_corner_removal)=0;
        end
        index(index2==0)=[];
        world_h(:,index)=corner(1:2,k1)*ones(1,length(index));
        line_idx_h(index)=k*ones(1,length(index));
    end

    for k=1:line_dist_v_num

        k1=line_dist_v(1,k);
        k2=line_dist_v(2,k);
        k11=find(line_dist_h(1,:)==k1);
        k12=find(line_dist_h(2,:)==k1);
        k21=find(line_dist_h(1,:)==k2);
        k22=find(line_dist_h(2,:)==k2);
        if (isempty(k11) && isempty(k12)) || (isempty(k21) && isempty(k22))
            continue;
        end

        line=line_dist_v(3:5,k);
        dist_line=abs(line'*[center_list_scale;ones(1,center_num)]);
        angle1=(corner(3:4,k2)-corner(3:4,k1))'*(center_list_scale-corner(3:4,k1)*ones(1,center_num));
        angle2=(corner(3:4,k1)-corner(3:4,k2))'*(center_list_scale-corner(3:4,k2)*ones(1,center_num));
        index=find(dist_line<line_dist_v(6,k)&angle1>0&angle2>0);

        index2=ones(1,length(index));
        if ~isempty(k11)
            dist_line11=abs(line_dist_h(3:5,k11)'*[center_list_scale(:,index);ones(1,length(index))]);
            index2(dist_line11<line_dist_h(6,k11)*distance_scale_for_corner_removal)=0;
        end
        if ~isempty(k12)
            dist_line12=abs(line_dist_h(3:5,k12)'*[center_list_scale(:,index);ones(1,length(index))]);
            index2(dist_line12<line_dist_h(6,k12)*distance_scale_for_corner_removal)=0;
        end
        if ~isempty(k21)
            dist_line21=abs(line_dist_h(3:5,k21)'*[center_list_scale(:,index);ones(1,length(index))]);
            index2(dist_line21<line_dist_h(6,k21)*distance_scale_for_corner_removal)=0;
        end
        if ~isempty(k22)
            dist_line22=abs(line_dist_h(3:5,k22)'*[center_list_scale(:,index);ones(1,length(index))]);
            index2(dist_line22<line_dist_h(6,k22)*distance_scale_for_corner_removal)=0;
        end
        index(index2==0)=[];
        world_v(:,index)=corner(1:2,k1)*ones(1,length(index));
        line_idx_v(index)=k*ones(1,length(index));
    end

    index=find(world_h(1,:)>-10000);
    center_h=center_list(:,index);
    world_h=world_h(:,index);
    slope_init_h=line_dist_h(3:4,line_idx_h(index));
    
    index=find(world_v(1,:)>-10000);
    center_v=center_list(:,index);
    world_v=world_v(:,index);
    slope_init_v=line_dist_v(3:4,line_idx_v(index));

    fprintf(' CenterList');
    
    num_h=length(center_h(1,:));
    line_h=zeros(3,num_h);
    for i=1:num_h
        % fitting without initial : coarse search for slope and distance
        % (requires long time)
        % temp=LineFitting(img_double,center_h(:,i),radius,[],Template,TemplateSlope,TemplateDist,TemplateWeight);

        % fitting with slope initial : coarse search for distance
        temp=LineFitting(img_double,center_h(:,i),radius,slope_init_h(:,i),Template,TemplateSlope,TemplateDist,TemplateWeight);

        % fitting with line initial : fine search for slope and distance
        line_h(:,i)=LineFitting(img_double,center_h(:,i),radius,temp,Template,TemplateSlope,TemplateDist,TemplateWeight);
    end
    index=find(abs(line_h(3,:))>feature_distance_max_for_line_fitting);
    line_h(:,index)=[];
    center_h(:,index)=[];
    world_h(:,index)=[];

    num_v=length(center_v(1,:));
    line_v=zeros(3,num_v);
    for i=1:num_v
        % fitting without initial : coarse search for slope and distance
        % (requires long time)
        % temp=LineFitting(img_double,center_v(:,i),radius,[],Template,TemplateSlope,TemplateDist,TemplateWeight);

        % fitting with slope initial : coarse search for distance
        temp=LineFitting(img_double,center_v(:,i),radius,slope_init_v(:,i),Template,TemplateSlope,TemplateDist,TemplateWeight);

        % fitting with line initial : fine search for slope and distance
        line_v(:,i)=LineFitting(img_double,center_v(:,i),radius,temp,Template,TemplateSlope,TemplateDist,TemplateWeight);
    end
    index=find(abs(line_v(3,:))>feature_distance_max_for_line_fitting);
    line_v(:,index)=[];
    center_v(:,index)=[];
    world_v(:,index)=[];

    save([path1,'L_',file1{n}(1:end-4),'.mat'],'world_h','world_v','center_h','center_v','line_h','line_v');

    fprintf(' LineFeature\n');
end

