function cost=NCCw(template1,template2,weight)
t1=template1(:)-mean(template1(:));
t2=template2(:)-mean(template2(:));
w=weight(:)/sum(weight(:));
cost=sum(t1.*t2.*w)/sqrt(sum(t1.*t1.*w)*sum(t2.*t2.*w));
