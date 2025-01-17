close all
clear all
clc
%{
load flow_map_gridint_v2
fxv=fx;
fyv=fy;
load flow_map_gridint
sum(sum(sum(isnan(fx))))
sum(sum(sum(isnan(fxv))))
sum(sum(sum(isnan(fy))))
sum(sum(sum(isnan(fyv))))
%
for i =1:length(time)
    fig=figure
    subplot(221)
    surface(xx,yy,fx(:,:,i),'edgecolor','none')
    title('fx')
    axis('tight')
    subplot(222)
    surface(xx,yy,fxv(:,:,i),'edgecolor','none')
    title('fxv')
    axis('tight')
    subplot(223)
    surface(xx,yy,fy(:,:,i),'edgecolor','none')
    title('fy')
    axis('tight')
    subplot(224)
    surface(xx,yy,fyv(:,:,i),'edgecolor','none')
    title('fyv')
    axis('tight')
    saveas(fig,sprintf('fm_%03d.png',i))
    close all
end

%}
load flow_map_gridint_v2
load FTLE_wrf
for i =1:length(T)
    fig=figure
    surface(xx,yy,sigma(:,:,i),'edgecolor','none')
    colorbar
    title('sigma')
    axis('tight')
    saveas(fig,sprintf('fm_%03d.png',i))
    close all
end