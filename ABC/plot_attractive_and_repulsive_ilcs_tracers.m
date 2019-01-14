
clear all
close all
clc
load OECS_DATA
%{
filename='attracting_ilcs.avi'
v = VideoWriter(filename,'Uncompressed AVI');
v.FrameRate=10;
opengl('software')
open(v)
%}
xp=x;
yp=y;
zp=z;
d3ballsize=151
radius = 0.25
xorg= 3.7
zorg= 6.1
yorg= 3.1
zorg2= 5.6
xorg2=4.3
yorg2= 2.6
%{
[x,y,z]=sphere(d3ballsize);
x=radius*x;
y=radius*y;
z=radius*z;
x1 = reshape(x,[],1) + xorg;
y1 = reshape(y,[],1) + yorg2;
z1 = reshape(z,[],1) + zorg;

x2 = reshape(x,[],1) + xorg2;
y2 = reshape(y,[],1) + yorg2;
z2 = reshape(z,[],1) + zorg2;

n=25;
tend=2*pi
twant = linspace(0,tend,n);
for i = 1:length(x1)
    y01=[x1(i),y1(i),z1(i)];
    y02=[x2(i),y2(i),z2(i)];
    [t1,yout1] = ode45(@abc_int,[0,tend],y01);
    [t2,yout2] = ode45(@abc_int,[0,tend],y02);
    xx1(:,i) = interp1(t1,yout1(:,1),twant);
    yy1(:,i) = interp1(t1,yout1(:,2),twant);
    zz1(:,i) = interp1(t1,yout1(:,3),twant);
    xx2(:,i) = interp1(t2,yout2(:,1),twant);
    yy2(:,i) = interp1(t2,yout2(:,2),twant);
    zz2(:,i) = interp1(t2,yout2(:,3),twant);
end
%}
%
for i=1:3
    dirdiv1 = smooth3(dirdiv1);
    concav1 = smooth3(concav1);
    s1 = smooth3(s1);
end
%}
dirdiv1(s1>0)=NaN;
dirdiv1(concav1<=0)=NaN;
dirdiv1(abs(dirdiv1)>0.2)=NaN;
dirdivn(sn<0)=NaN;
dirdivn(concavn>=0)=NaN;
dirdivn(abs(dirdivn)>0.2)=NaN;
FV1=isosurface(xp,yp,zp,dirdiv1,0);
FVn=isosurface(xp,yp,zp,dirdivn,0);

%{
%FV = smoothpatch(FV)
%
splitpatch = splitFV(FV);
index = 1;
len = length(splitpatch(1).faces)
for i=2:length(splitpatch)
    if length(splitpatch(i).faces)>len
        index = i
        len = length(splitpatch(i).faces)
    end
end
FV=splitpatch(index)

%
points = FV.vertices;
n=25;
tend=2*pi
twant = linspace(0,tend,n);
for i = 1:length(points)
    y0=[points(i,1),points(i,2),points(i,3)];
    [t,yout] = ode45(@abc_int,[0,tend],y0);
    xvert(:,i) = interp1(t,yout(:,1),twant);
    yvert(:,i) = interp1(t,yout(:,2),twant);
    zvert(:,i) = interp1(t,yout(:,3),twant);
end
verts = cat(3,xvert,yvert,zvert);
%
fig=figure
for i =1:n
    clf
    hold on
    FV.vertices=squeeze(verts(i,:,:));
    patch(FV,'facecolor','blue','edgecolor','none');
    %scatter3(xx(i,:),yy(i,:),zz(i,:),'r.');
    dt1 = delaunayTriangulation(xx1(i,:)',yy1(i,:)',zz1(i,:)');
    triboundary1 = convexHull(dt1);
    trisurf(triboundary1,xx1(i,:)',yy1(i,:)',zz1(i,:)','FaceColor', 'green','edgecolor','none','FaceAlpha',1.0)
    dt2 = delaunayTriangulation(xx2(i,:)',yy2(i,:)',zz2(i,:)');
    triboundary2 = convexHull(dt2);
    trisurf(triboundary2,xx2(i,:)',yy2(i,:)',zz2(i,:)','FaceColor', 'green','edgecolor','none','FaceAlpha',1.0)

    xlabel('x')
    ylabel('y')
    zlabel('z')
    title(sprintf('time = %f',twant(i)))
    camlight
    lighting gouraud
    %axis([-15,5,-10,15,-5,15])
    axis equal tight
    %view(3)
    view(-124,32)
    %view(20,20)
    pause(0.25)
    g=getframe(fig);
    writeVideo(v,g)
end
close(v)


%}

az2 = 28%47
el2 = 29%35
az =-190%-25
el =10% 21
alpT = 1.0
alpS = 1.0
font = 'cmr'
fig=figure('units','inch','position',[0,0,6,6],'DefaultTextFontName', font, 'DefaultAxesFontName', font);
i = 1
hold on
%FV.vertices=squeeze(verts(i,:,:));
patch(FV1,'facecolor','blue','edgecolor','none','FaceAlpha',alpS);
patch(FVn,'facecolor','red','edgecolor','none','FaceAlpha',alpS);
xlabel('x')
ylabel('y')
zlabel('z')
%set(gca, 'XTick',[3,4])
%set(gca, 'YTick',[3,4])
%title(sprintf('time = %1.3f',twant(i)))
camlight
lighting gouraud
%axis([-15,5,-10,15,-5,15])
axis equal tight
%view(3)
%view(-124,32)
view(az,el)
%view(20,20)
%{
fig=figure('units','inch','position',[0,0,6,6],'DefaultTextFontName', font, 'DefaultAxesFontName', font);
i = 1
subplot(2,2,1)
hold on
FV.vertices=squeeze(verts(i,:,:));
patch(FV,'facecolor','blue','edgecolor','none','FaceAlpha',alpS);
dt1 = delaunayTriangulation(xx1(i,:)',yy1(i,:)',zz1(i,:)');
triboundary1 = convexHull(dt1);
trisurf(triboundary1,xx1(i,:)',yy1(i,:)',zz1(i,:)','FaceColor', 'green','edgecolor','none','FaceAlpha',1.0)
dt2 = delaunayTriangulation(xx2(i,:)',yy2(i,:)',zz2(i,:)');
triboundary2 = convexHull(dt2);
trisurf(triboundary2,xx2(i,:)',yy2(i,:)',zz2(i,:)','FaceColor', 'green','edgecolor','none','FaceAlpha',1.0)
xlabel('x')
ylabel('y')
zlabel('z')
set(gca, 'XTick',[3,4])
set(gca, 'YTick',[3,4])
%title(sprintf('time = %1.3f',twant(i)))
camlight
lighting gouraud
%axis([-15,5,-10,15,-5,15])
axis equal tight
%view(3)
%view(-124,32)
view(az,el)
%view(20,20)

subplot(2,2,2)
hold on
FV.vertices=squeeze(verts(i,:,:));
patch(FV,'facecolor','blue','edgecolor','none','FaceAlpha',alpS);
dt1 = delaunayTriangulation(xx1(i,:)',yy1(i,:)',zz1(i,:)');
triboundary1 = convexHull(dt1);
trisurf(triboundary1,xx1(i,:)',yy1(i,:)',zz1(i,:)','FaceColor', 'green','edgecolor','none','FaceAlpha',1.0)
dt2 = delaunayTriangulation(xx2(i,:)',yy2(i,:)',zz2(i,:)');
triboundary2 = convexHull(dt2);
trisurf(triboundary2,xx2(i,:)',yy2(i,:)',zz2(i,:)','FaceColor', 'green','edgecolor','none','FaceAlpha',1.0)
xlabel('x')
ylabel('y')
zlabel('z')
set(gca, 'XTick',[3,4])
set(gca, 'YTick',[3,4])
%title(sprintf('time = %1.3f',twant(i)))
camlight
lighting gouraud
%axis([-15,5,-10,15,-5,15])
axis equal tight
%view(3)
%view(-124,32)
view(az2,el2)
%view(20,20)
%
i = 6
subplot(2,2,3)
hold on
FV.vertices=squeeze(verts(i,:,:));
patch(FV,'facecolor','blue','edgecolor','none','FaceAlpha',alpS);
dt1 = delaunayTriangulation(xx1(i,:)',yy1(i,:)',zz1(i,:)');
triboundary1 = convexHull(dt1);
trisurf(triboundary1,xx1(i,:)',yy1(i,:)',zz1(i,:)','FaceColor', 'green','edgecolor','none','FaceAlpha',1.0)
dt2 = delaunayTriangulation(xx2(i,:)',yy2(i,:)',zz2(i,:)');
triboundary2 = convexHull(dt2);
trisurf(triboundary2,xx2(i,:)',yy2(i,:)',zz2(i,:)','FaceColor', 'green','edgecolor','none','FaceAlpha',1.0)
xlabel('x')
ylabel('y')
zlabel('z')
%title(sprintf('time = %1.3f',twant(i)))%,'FontName','Stencil')
camlight
lighting gouraud
%axis([-15,5,-10,15,-5,15])
axis equal tight
%view(3)
%view(-124,32)
view(az,el)
%view(20,20)

subplot(2,2,4)
hold on
FV.vertices=squeeze(verts(i,:,:));
patch(FV,'facecolor','blue','edgecolor','none','FaceAlpha',alpS);
dt1 = delaunayTriangulation(xx1(i,:)',yy1(i,:)',zz1(i,:)');
triboundary1 = convexHull(dt1);
trisurf(triboundary1,xx1(i,:)',yy1(i,:)',zz1(i,:)','FaceColor', 'green','edgecolor','none','FaceAlpha',1.0)
dt2 = delaunayTriangulation(xx2(i,:)',yy2(i,:)',zz2(i,:)');
triboundary2 = convexHull(dt2);
trisurf(triboundary2,xx2(i,:)',yy2(i,:)',zz2(i,:)','FaceColor', 'green','edgecolor','none','FaceAlpha',1.0)
xlabel('x')
ylabel('y')
zlabel('z')
%title(sprintf('time = %1.3f',twant(i)))
camlight
lighting gouraud
%axis([-15,5,-10,15,-5,15])
axis equal tight
%view(3)
%view(-124,32)
view(az2,el2)
%view(20,20)
%}
%saveas(fig,'attracting_ilcs_v3.eps','epsc')
%{
i = n
subplot(3,2,5)
hold on
FV.vertices=squeeze(verts(i,:,:));
patch(FV,'facecolor','blue','edgecolor','none');
dt = delaunayTriangulation(xx(i,:)',yy(i,:)',zz(i,:)');
triboundary = convexHull(dt);
trisurf(triboundary,xx(i,:)',yy(i,:)',zz(i,:)','FaceColor', 'green','edgecolor','none','FaceAlpha',0.7)
xlabel('x')
ylabel('y')
zlabel('z')
title(sprintf('time = %f',twant(i)))
camlight
lighting gouraud
%axis([-15,5,-10,15,-5,15])
axis equal tight
%view(3)
view(-124,32)
%view(20,20)

subplot(3,2,6)
dt = delaunayTriangulation(xx(i,:)',yy(i,:)',zz(i,:)');
triboundary = convexHull(dt);
trisurf(triboundary,xx(i,:)',yy(i,:)',zz(i,:)','FaceColor', 'green','edgecolor','none','FaceAlpha',0.7)
xlabel('x')
ylabel('y')
zlabel('z')
title(sprintf('time = %f',twant(i)))
camlight
lighting gouraud
%axis([-15,5,-10,15,-5,15])
axis equal tight
%view(3)
view(-124,32)
%view(20,20)


%}

