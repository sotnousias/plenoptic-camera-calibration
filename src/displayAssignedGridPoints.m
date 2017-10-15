[file1,path1]=uigetfile('*.bmp','Image','MultiSelect','on');
if length(path1)<2
    return;
end
if ~iscell(file1)
    file1=cellstr(file1);
end

ImageNum=length(file1);
for n=1:ImageNum
    img=imread([path1,file1{n}]);
    load([path1,file1{n}(1:end-4),'.mat']);
    
    figure; imshow(img, 'InitialMagnification', 'fit');
    hold on;
    idx00=find(corner(1,:)==0&corner(2,:)==0);
    idx10=find(corner(1,:)==1&corner(2,:)==0);
    idx01=find(corner(1,:)==0&corner(2,:)==1);
    plot(corner(3,[idx00,idx10]),corner(4,[idx00,idx10]),'g-');
    plot(corner(3,[idx00,idx01]),corner(4,[idx00,idx01]),'b-');
    
    for i = 1 : size(corner, 2)
        
        plot(corner(3,i),corner(4,i),'r.');
        str = sprintf('(%d,%d)', corner(1,i), corner(2,i));
        text(corner(3,i), corner(4,i), str, 'FontSize', 10);
    end
    hold off;
end
