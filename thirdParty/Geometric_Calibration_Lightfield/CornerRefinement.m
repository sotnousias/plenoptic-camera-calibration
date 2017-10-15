function refined=CornerRefinement(initial,img,winsize)

winsize2=winsize*2+1;
winsize3=winsize2*winsize2;
[i,j]=meshgrid(-winsize:winsize,-winsize:winsize);
w=exp(-(i.*i+j.*j)/winsize^2);
width=size(img,2);
height=size(img,1);

refinedX=initial(1,:);
refinedY=initial(2,:);

iL=reshape(i,winsize3,1);
jL=reshape(j,winsize3,1);
wL=reshape(w,winsize3,1);

[Gx_ref,Gy_ref]=gradient(img);

for iter=1:30
    idx_in=(~isnan(refinedX)&refinedX>=winsize+1&refinedX<width-winsize-1&~isnan(refinedY)&refinedY>=winsize+1&refinedY<height-winsize-1);
    num_in=sum(idx_in);
    if num_in<=0
        break;
    end
    Xi=repmat(refinedX(idx_in),winsize3,1)+repmat(iL,1,num_in);
    Yj=repmat(refinedY(idx_in),winsize3,1)+repmat(jL,1,num_in);
    XiL=reshape(Xi,1,winsize3*num_in);
    YjL=reshape(Yj,1,winsize3*num_in);
    XiLint=floor(XiL);
    YjLint=floor(YjL);
    XiLdec=XiL-XiLint;
    YjLdec=YjL-YjLint;
    idx00=sub2ind([height,width],YjLint,XiLint);
    idx01=sub2ind([height,width],YjLint,XiLint+1);
    idx10=sub2ind([height,width],YjLint+1,XiLint);
    idx11=sub2ind([height,width],YjLint+1,XiLint+1);
    Gx00=Gx_ref(idx00);
    Gx01=Gx_ref(idx01);
    Gx10=Gx_ref(idx10);
    Gx11=Gx_ref(idx11);
    Gy00=Gy_ref(idx00);
    Gy01=Gy_ref(idx01);
    Gy10=Gy_ref(idx10);
    Gy11=Gy_ref(idx11);

    Gx=reshape(Gx00.*(1-XiLdec).*(1-YjLdec)+Gx01.*XiLdec.*(1-YjLdec)+Gx10.*(1-XiLdec).*YjLdec+Gx11.*XiLdec.*YjLdec,winsize3,num_in);
    Gy=reshape(Gy00.*(1-XiLdec).*(1-YjLdec)+Gy01.*XiLdec.*(1-YjLdec)+Gy10.*(1-XiLdec).*YjLdec+Gy11.*XiLdec.*YjLdec,winsize3,num_in);

    temp=repmat(iL,1,num_in).*Gx+repmat(jL,1,num_in).*Gy;
    sumX=wL'*(Gx.*temp);
    sumY=wL'*(Gy.*temp);
    Gxx=wL'*(Gx.*Gx);
    Gxy=wL'*(Gx.*Gy);
    Gyy=wL'*(Gy.*Gy);
    det=Gxx.*Gyy-Gxy.^2;
    refinedX(idx_in)=refinedX(idx_in)+(Gyy.*sumX-Gxy.*sumY)./det;
    refinedY(idx_in)=refinedY(idx_in)+(-Gxy.*sumX+Gxx.*sumY)./det;
end
refinedX(~idx_in)=nan;
refinedY(~idx_in)=nan;

refined=[refinedX;refinedY];

end