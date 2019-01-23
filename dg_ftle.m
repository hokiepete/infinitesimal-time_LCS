clear all
close all
clc
lenx = 101
lenyz = 51
tlen = 101
t0 = 0
tf = -0.96
x = linspace(0,2,lenx);
dx=x(2)-x(1);
y = linspace(0,1,lenyz);
dy=y(2)-y(1);
twant = linspace(t0,tf,tlen);
[x,y] = meshgrid(x,y);
options = odeset('RelTol',1e-8,'AbsTol',1e-8);
for i = 1:lenyz
    i
    for j = 1:lenx
            y0=[x(i,j),y(i,j)];
            [t,yout] = ode45(@dg_int,[t0,tf],y0,options);
            fx(:,i,j) = interp1(t,yout(:,1),twant,'spline');
            fy(:,i,j) = interp1(t,yout(:,2),twant,'spline');
    end
end
sigma = zeros([tlen,lenyz,lenx]);
for t = 1:tlen
    t
    %need to skip t0 to avoid division by zero
    %set FTLE to zero instead
    if twant(t) == t0
        continue
    else
        [dfxdx,dfxdy] = gradient(squeeze(fx(t,:,:)),dx,dy);
        [dfydx,dfydy] = gradient(squeeze(fy(t,:,:)),dx,dy);
        for i = 1:lenyz
            for j = 1:lenx
                    gradF = [dfxdx(i,j),dfxdy(i,j);
                             dfydx(i,j),dfydy(i,j)];
                    C = gradF'*gradF;
                    lambda = max(eig(C));
                    sigma(t,i,j) = 1/(2*abs(twant(t)-t0))*log(lambda);
            end
        end
    end
end

save('sigma_big.mat', 'sigma');