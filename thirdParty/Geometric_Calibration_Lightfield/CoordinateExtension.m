function world_coordinate=CoordinateExtension(Origin,InitX,InitY,CornerList,CornerCorrelation,BoundaryDifference)

world_coordinate=inf*CornerList(1:2,:);
world_coordinate(:,Origin)=[0;0];
if InitX>0
    world_coordinate(:,InitX)=[1;0];
else
    world_coordinate(:,-InitX)=[-1;0];
end
if InitY>0
    world_coordinate(:,InitY)=[0;1];
else
    world_coordinate(:,-InitY)=[0;-1];
end
change=[Origin,abs(InitX),abs(InitY)];
change_num=3;
while change_num>0
    change_prev=change;
    change_prev_num=change_num;
    change=zeros(1,1000);
    change_num=0;
    for n=1:change_prev_num
        idx22=change_prev(n);
        I=world_coordinate(1,idx22);
        J=world_coordinate(2,idx22);
        idx=zeros(3,3);
        for j=-1:1
            for i=-1:1
                temp=find(world_coordinate(1,:)==I+i&world_coordinate(2,:)==J+j);
                if length(temp)==1
                    idx(j+2,i+2)=temp;
                else
                    world_coordinate(:,temp)=nan;
                end
            end
        end
        if idx(2,2)<=0
            continue;
        end
        % x+
        idx1=[idx(1,3),idx(1,2),idx(2,2),idx(3,2),idx(3,3)];
        idx2=[idx(1,2),idx(1,1),idx(2,1),idx(3,1),idx(3,2)];
        k=find(idx1>0&idx2>0);
        if ~isempty(k)
            InitDiff=mean(CornerList(1:2,idx1(k))-CornerList(1:2,idx2(k)),2);
            t=ClosestPoint(idx(2,2),InitDiff,CornerList,CornerCorrelation(idx(2,2),:),BoundaryDifference(idx(2,2),:));
            if t>0
                s=ClosestPoint(t,-InitDiff,CornerList,CornerCorrelation(t,:),BoundaryDifference(t,:));
                if s==idx(2,2)
                    if isinf(world_coordinate(1,t))
                        world_coordinate(:,t)=[I+1;J];
                        change_num=change_num+1;
                        change(change_num)=t;
                    elseif world_coordinate(1,t)~=I+1 || world_coordinate(2,t)~=J
                        world_coordinate(:,t)=nan;
                    end
                end
            end
        end
        % x-
        idx1=[idx(1,1),idx(1,2),idx(2,2),idx(3,2),idx(3,1)];
        idx2=[idx(1,2),idx(1,3),idx(2,3),idx(3,3),idx(3,2)];
        k=find(idx1>0&idx2>0);
        if ~isempty(k)
            InitDiff=mean(CornerList(1:2,idx1(k))-CornerList(1:2,idx2(k)),2);
            t=ClosestPoint(idx(2,2),InitDiff,CornerList,CornerCorrelation(idx(2,2),:),BoundaryDifference(idx(2,2),:));
            if t>0
                s=ClosestPoint(t,-InitDiff,CornerList,CornerCorrelation(t,:),BoundaryDifference(t,:));
                if s==idx(2,2)
                    if isinf(world_coordinate(1,t))
                        world_coordinate(:,t)=[I-1;J];
                        change_num=change_num+1;
                        change(change_num)=t;
                    elseif world_coordinate(1,t)~=I-1 || world_coordinate(2,t)~=J
                        world_coordinate(:,t)=nan;
                    end
                end
            end
        end
        % y+
        idx1=[idx(3,1),idx(2,1),idx(2,2),idx(2,3),idx(3,3)];
        idx2=[idx(2,1),idx(1,1),idx(1,2),idx(1,3),idx(2,3)];
        k=find(idx1>0&idx2>0);
        if ~isempty(k)
            InitDiff=mean(CornerList(1:2,idx1(k))-CornerList(1:2,idx2(k)),2);
            t=ClosestPoint(idx(2,2),InitDiff,CornerList,CornerCorrelation(idx(2,2),:),BoundaryDifference(idx(2,2),:));
            if t>0
                s=ClosestPoint(t,-InitDiff,CornerList,CornerCorrelation(t,:),BoundaryDifference(t,:));
                if s==idx(2,2)
                    if isinf(world_coordinate(1,t))
                        world_coordinate(:,t)=[I;J+1];
                        change_num=change_num+1;
                        change(change_num)=t;
                    elseif world_coordinate(1,t)~=I || world_coordinate(2,t)~=J+1
                        world_coordinate(:,t)=nan;
                    end
                end
            end
        end
        % y-
        idx1=[idx(1,1),idx(2,1),idx(2,2),idx(2,3),idx(1,3)];
        idx2=[idx(2,1),idx(3,1),idx(3,2),idx(3,3),idx(2,3)];
        k=find(idx1>0&idx2>0);
        if ~isempty(k)
            InitDiff=mean(CornerList(1:2,idx1(k))-CornerList(1:2,idx2(k)),2);
            t=ClosestPoint(idx(2,2),InitDiff,CornerList,CornerCorrelation(idx(2,2),:),BoundaryDifference(idx(2,2),:));
            if t>0
                s=ClosestPoint(t,-InitDiff,CornerList,CornerCorrelation(t,:),BoundaryDifference(t,:));
                if s==idx(2,2)
                    if isinf(world_coordinate(1,t))
                        world_coordinate(:,t)=[I;J-1];
                        change_num=change_num+1;
                        change(change_num)=t;
                    elseif world_coordinate(1,t)~=I || world_coordinate(2,t)~=J-1
                        world_coordinate(:,t)=nan;
                    end
                end
            end
        end
    end
end

end
