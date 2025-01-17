function int_vel_gridint_v2()
close all
clear all
clc
load wrf_vel_data
xwant = 31%405
ywant= 31%325
t0 = 24*3600;
tf = 0*3600;
tdim = 241;
t_want = linspace(tf,t0,tdim);
yy=linspace(0,972000,ywant);
xx=linspace(0,1212000,xwant);
P = [2,1,3];
u = permute(u,P);
v = permute(v,P);
x = permute(x,P);
y = permute(y,P);
t = permute(t,P);
U = griddedInterpolant(x,y,t,u,'spline','linear')
V = griddedInterpolant(x,y,t,v,'spline','linear')

[xx,yy]=meshgrid(xx,yy);
fx = NaN(ywant,xwant,tdim);
fy = NaN(ywant,xwant,tdim);
TSPAN = [t0,tf]; % Solve from t=1 to t=5
opts=odeset('event',@eventfun_gridint,'RelTol',1e-14)%,'AbsTol',1e-14);
for i =1:ywant
    for j=1:xwant
        sprintf('%03d, %03d',i,j)
        tic
        Y0=[xx(i,j),yy(i,j)];
        %[T Y] = ode45(@odefun_gridint, TSPAN, Y0, opts, U,V); % Solve ODE
        [T Y] = ode113(@odefun_gridint, TSPAN, Y0, opts, U,V); % Solve ODE
        fx(i,j,:) = interp1(T,squeeze(Y(:,1)),t_want,'spline',nan);
        fy(i,j,:) = interp1(T,squeeze(Y(:,2)),t_want,'spline',nan);
        toc
    end
end
time = t_want;
save flow_map_gridint_v2 fx fy xx yy time
end
%

function dydt = odefun_gridint(t,Y,U,V)
    Y,t
    dydt = zeros(2,1);
    dydt(1) = U(Y(1),Y(2),t);%interp3(x,y,time,u,Y(1),Y(2),t,'spline');
    dydt(2) = V(Y(1),Y(2),t);%interp3(x,y,time,v,Y(1),Y(2),t,'spline');
end

function [value,isterminal,direction]=eventfun_gridint(t,Y,U,V)
    value=[Y(1),Y(1)-1212000,Y(2),Y(2)-972000];
    isterminal=[1,1,1,1];
    direction=[0,0,0,0];
end
%}