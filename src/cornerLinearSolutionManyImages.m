% Obtain the linear solution based on corners (without the micro-lenses
% classified) but from many images of the same type.

use_type = input('Which type do you want??\n');


if ( (use_type == 1) || (use_type == 2) || (use_type == 3) )
    file_name = sprintf('corr*Type%d*.mat', use_type);

else
    file_name = 'corr*All*.mat';
end


disp('Select the corners in the light-field image')
[file1,path1]=uigetfile(file_name ,'Correnspondence files','MultiSelect','on');

if length(path1)<2
    return;
end
if ~iscell(file1)
    file1=cellstr(file1);
end

% get the number of images
ImageNum = length(file1);

singularvector=zeros(12,ImageNum*12);
singularvalue=zeros(12,ImageNum);

% load pattern size and image center
pattern_size = load([path1 'pattern_size.txt']);
ImageCenterInitial = load([path1 'image_center.txt']);

% first loop to get the singular vectors

corr_all = [];
num_cor = [];


for n = 1:ImageNum
    
    load([path1 file1{n}]);
    matr_idx = 1;
    
    num_cor(n) = size(correspondences,2);
    corr_all = [corr_all correspondences];
    
    A = zeros(size(correspondences, 2)*2, 12);

    for i = 1:size(correspondences, 2)
        
        Xw = [correspondences(5:6, i)'*pattern_size 1];
        
        % normalize uc, vc by substracting the center of the light-field image,
        % seems to work far better.
        uc = correspondences(3, i) - ImageCenterInitial(1);
        vc = correspondences(4, i) - ImageCenterInitial(2);
        
        
        %     reprojection is far better without substracting the image center.
        %     uc = correspondences(3, i);
        %     vc = correspondences(4, i);
        
        
        %     uc = correspondences_scaled(1, rand_ind(i));
        %     vc = correspondences_scaled(2, rand_ind(i));
        
        du = correspondences(1, i) - correspondences(3, i);
        dv = correspondences(2, i) - correspondences(4, i);
        
        A(matr_idx, :) = [-Xw zeros(1,3) Xw*uc Xw*du];
        A(matr_idx + 1, :) = [zeros(1,3) -Xw Xw*vc Xw*dv];
        
        matr_idx = matr_idx + 2;
        

    end
    
    
    [U,S,V] = svd(A);
    
    singularvector(:,n*12-11:n*12)=V;
    
end

f_ = zeros(1,ImageNum);
for n = 1:ImageNum
    
    %equation (16) in ICCV paper.
    v = singularvector(:,n*12);
    f_(n) = sqrt(-(v(1)*v(2)+v(4)*v(5))/(v(7)*v(8)));
end

f=median(f_(imag(f_)==0));

lambda_ = zeros(1,ImageNum);
K1_ = zeros(1,ImageNum);
K2_ = zeros(1,ImageNum);
RT = zeros(1,ImageNum*6);

for n=1:ImageNum
    v=singularvector(:,n*12);
    
    % equations (17)-(23) in ICCV paper.
    r1=[v(1)/f;v(4)/f;v(7)];
    lambda_(n)=norm(r1);
    r1=r1/lambda_(n);
    r2=[v(2)/f;v(5)/f;v(8)];
    r3=cross(r1,r2);
    r3=r3/norm(r3);
    r2=cross(r3,r1);
    R=[r1,r2,r3];
    T=[v(3)/f;v(6)/f;v(9)]/lambda_(n);

    K1_(n)=(v(10)+v(11))/(R(3,1)+R(3,2))/lambda_(n);
    K2_(n)=v(12)/lambda_(n)-K1_(n)*T(3);
    
    if T(3)<0
        v=-v;
        R=[-R(:,1),-R(:,2),R(:,3)];
        T=-T;
        K1_(n)=-K1_(n);
        K2_(n)=-K2_(n);
    end
    
    RT(n*6-5:n*6)=GetAxis([R,T;0,0,0,1]);
end

K1=median(K1_);
K2=median(K2_);


IntParamLF = [K1, K2 ,f ,f ,ImageCenterInitial];

save_file = sprintf('IntParamLFSVDType%d.mat', use_type);

save([path1 save_file], 'IntParamLF')


% save the extrinsics after SVD.
for n = 1:ImageNum

    ExtParamLF = SetAxis(RT(n*6 - 5:n*6));
    save([path1 'ExtParamSVD' file1{n}(numel('correspondences') + 1:end)], 'ExtParamLF')   
end



%% perform non-linear optimisation for all images
option=optimset('Display','off','TolFun',1e-10,'TolX',1e-10,'MaxFunEvals',100000,'MaxIter',10000);

param_init=[IntParamLF 0 0 RT];

param = lsqnonlin(@(x) plenopticReprojectionErrorMultipleImages(x, corr_all, num_cor, pattern_size),param_init,[],[],option);

mean(plenopticReprojectionErrorMultipleImages(param, corr_all, num_cor, pattern_size))

disp_str = sprintf('Images Used:%d', ImageNum);
disp(disp_str)

IntParamLF=param(1:8);

save_file = sprintf('IntParamLFManyType%d.mat', use_type);
save([path1 save_file], 'IntParamLF')

ext_params = param(9:end);

for n=1:ImageNum
    
    ExtParamLF=SetAxis(ext_params(n*6 - 5: n*6 ));
    
    save([path1 'ExtParamMany' file1{n}(numel('correspondences') + 1:end)], 'ExtParamLF')
end






