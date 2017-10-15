function weight=InterpolationTriangleWeight(target,source)

line1=cross([source(:,1);1],[target;1]);
line2=cross([source(:,2);1],[source(:,3);1]);
c=cross(line1,line2);
c=c(1:2)/c(3);
v23=source(:,3)-source(:,2); v23=v23/norm(v23);
l2=v23'*(c-source(:,2));
l3=-v23'*(c-source(:,3));
vc1=c-source(:,1); vc1=vc1/norm(vc1);
l1=vc1'*(target-source(:,1));
l0=-vc1'*(target-c);
weight=[l0/(l0+l1),l3/(l2+l3)*l1/(l0+l1),l2/(l2+l3)*l1/(l0+l1)];

end