[file1,path1]=uigetfile('*.png','Raw Image','MultiSelect','on');
if length(path1)<2
    return;
end
if ~iscell(file1)
    file1=cellstr(file1);
end

for n=1:length(file1)
    load([path1,file1{n}(1:end-4),'.mat']);
    img=imread([path1,file1{n}]);
    figure; imshow(img); hold on;
    plot(SubCorner(3,:),SubCorner(4,:),'b.');
    plot(SubCorner(5,:),SubCorner(6,:),'r.');
    hold off;
    legend('Extracted','Projected');
end
fprintf('ProjectionError %f\n',sqrt(mean((SubCorner(3,:)-SubCorner(5,:)).^2+(SubCorner(4,:)-SubCorner(6,:)).^2)));
