function [xd,yd]=AddDistortionIteration(xu,yu,k1,k2,iter)

x=xu;
y=yu;
for n=1:iter
    r=x.^2+y.^2;
    f1=1+k1*r+k2*r.^2;
    f2=k1+2*k2*r;
    fx=f1.*x-xu;
    fy=f1.*y-yu;
    fxdx=f1+f2*2.*x.^2;
    fxdy=f2*2.*x.*y;
    fydx=f2*2.*x.*y;
    fydy=f1+f2*2.*y.^2;
    det=fxdx.*fydy-fxdy.*fydx;
    x=x-(fydy.*fx-fxdy.*fy)./det;
    y=y-(-fydx.*fx+fxdx.*fy)./det;
end
xd=x;
yd=y;

end