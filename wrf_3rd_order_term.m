%
close all
clear all
clc

dt=1 %hr
dx=3 %kms
dy=3 %kms
%{
dt=3600 %s
dx=12*1000 %m
dy=12*1000 %m
%}
ncfile='hosiendata_wind_velocity.nc';
ncid=netcdf.open(ncfile,'NC_NOWRITE');
time_U = netcdf.getVar(ncid,0);
u = netcdf.getVar(ncid,3); %m/s
u = permute(u,[2,1,3]);
u(u==999)=nan;
u=3.6*u; %km/hr
v = netcdf.getVar(ncid,4); %m/s
v = permute(v,[2,1,3]);
v(v==999)=nan;
v=3.6*v; %km/hr
[ydim,xdim,tdim]=size(u);
%
[dudx,dudy,dudt] = gradient(u,dx,dy,dt);
[dvdx,dvdy,dvdt] = gradient(v,dx,dy,dt);

Du = dudt+u.*dudx+v.*dudy;
Dv = dvdt+u.*dvdx+v.*dvdy;

[dDudx,dDudy,dDudt] = gradient(Du,dx,dy,dt);
[dDvdx,dDvdy,dDvdt] = gradient(Dv,dx,dy,dt);


[dudx,dudy,dudt] = gradient(u,dx,dy,dt);
[dvdx,dvdy,dvdt] = gradient(v,dx,dy,dt);
Du = dudt+u.*dudx+v.*dudy;
Dv = dvdt+u.*dvdx+v.*dvdy;
[dDudx,dDudy,dDudt] = gradient(Du,dx,dy,dt);
[dDvdx,dDvdy,dDvdt] = gradient(Dv,dx,dy,dt);

au = dudt;
av = dvdt;

[daudx,daudy,daudt] = gradient(au,dx,dy,dt);
[davdx,davdy,davdt] = gradient(av,dx,dy,dt);

Dau = daudt+u.*daudx+v.*daudy;
Dav = davdt+u.*davdx+v.*davdy;

[dDaudx,dDaudy,dDaudt] = gradient(Dau,dx,dy,dt);
[dDavdx,dDavdy,dDavdt] = gradient(Dav,dx,dy,dt);



for t =1:length(time_U)
    t
    for i =1:ydim
        for j = 1:xdim
            if ~isnan(Du(i,j,t))&&~isnan(Dv(i,j,t))
                Grad_v = [dudx(i,j,t), dudy(i,j,t);dvdx(i,j,t), dvdy(i,j,t)];
                Grad_D = [dDudx(i,j,t), dDudy(i,j,t); dDvdx(i,j,t), dDvdy(i,j,t)];
                Grad_a = [dudx(i,j,t), dudy(i,j,t);dvdx(i,j,t), dvdy(i,j,t)];
                Grad_Da = [dDudx(i,j,t), dDudy(i,j,t); dDvdx(i,j,t), dDvdy(i,j,t)];
                S = 0.5*(Grad_v + Grad_v');
                B = 0.5*(Grad_D + Grad_D')+(Grad_v'*Grad_v);
                Q = 0.5*(Grad_Da + Grad_Da')+(Grad_v'*Grad_a+Grad_a'*Grad_v);
                [V,D] = eig(S);
                if ~issorted(diag(D))
                    [D,I] = sort(diag(D));
                    V = V(:, I);
                end
                s1_numerical(i,j,t) = D(1,1);
                X0 = V(:,1);
                l1_numerical(i,j,t) = X0'*B*X0;
                X1 = -((B-l1_numerical(i,j,t)*eye(size(B)))*X0)\(S-s1_numerical(i,j,t)*eye(size(B)));
                X1=X1';
                l2_numerical(i,j,t) = X0'*Q*X0 + X0'*B*X1 - X0'*S*X1;
              
                %X1 = V(:,1);
                %l1_numerical(i,j,t) = X1'*B*X1;
                %l2_numerical(i,j,t) = X1'*Q*X1;
                %cor_numerical(i,j,t) = -s1_numerical(i,j,t).^2+0.5*(X1'*B*X1);

            else
                s1_numerical(i,j,t) =nan;
                l1_numerical(i,j,t) = nan;
                l2_numerical(i,j,t) = nan;
                %cor_numerical(i,j,t)=nan;
            end
        end
    end
end

fig = figure


ncfile='ftle_80m.nc';
ncid=netcdf.open(ncfile,'NC_NOWRITE');

%{
Grab NC data
[ndims,nvars,ngatts,unlimdimid] = netcdf.inq(ncid);
%
%Loop through NC data infomation
for i = 1:nvars
    i-1
    [varname,xtype,dimids,natts] = netcdf.inqVar(ncid,i-1)
end
%}

time_ftle = netcdf.getVar(ncid,0); %days
%time_ftle=24*time_ftle(1:6:end); %hrs
time_ftle=24*time_ftle; %hrs
lon = netcdf.getVar(ncid,1,'double');
lat = netcdf.getVar(ncid,2,'double');
ftle = netcdf.getVar(ncid,5); %days^{-1}
%ftle=permute(squeeze(ftle(1,:,:,1:6:end)),[2,1,3]);
ftle=permute(squeeze(ftle(1,:,:,:)),[2,1,3]);
ftle(ftle==999999)=nan;
%ftle=1/(24*3.4)*ftle; %hrs^{-1}
ftle=1/(24)*ftle; %hrs^{-1}
[ydim,xdim,tdim]=size(ftle)
%
%ftle(s1_numerical==nan)=nan;
%ftle(cor_numerical==nan)=nan;
%}

%
%{
figure
surface(x,y,-s1_numerical(:,:,3)+1*cor_numerical(:,:,3),'edgecolor','none')
title('numerical')
colorbar()
%}
%}
s1 = s1_numerical(:,:,end);
%c1 = cor_numerical(:,:,end);
l1 = l1_numerical(:,:,end);
l2 = l2_numerical(:,:,end);
ftle(:,:,end)=-s1;
time = time_ftle;
n = length(time);
for i =1:n
    T=-time(i);
    ftle_t = squeeze(ftle(:,:,end+1-i));
    sig_true = reshape(ftle_t,[],1);
    sig_1st = reshape(-s1,[],1);
    sig_2nd = reshape(-s1-T*(-s1.^2+0.5*l1),[],1);
    sig_3rd = reshape(-s1-T*(-s1.^2+0.5*l1+T*(4/3*s1.^3-s1.*l1+1/4*l2)),[],1);
    
    ind = ~isnan(sig_true) & ~isnan(sig_1st) & ~isnan(sig_2nd) & ~isnan(sig_3rd) ;
    sig_true = sig_true(ind);
    sig_1st = sig_1st(ind);
    sig_2nd = sig_2nd(ind);
    sig_3rd = sig_3rd(ind);
    
    
    rmse_uncorrected(i) = sqrt(mean((sig_1st-sig_true).^2));
    rmse_2ncorrected(i) = sqrt(mean((sig_2nd-sig_true).^2));
    rmse_3rcorrected(i) = sqrt(mean((sig_3rd-sig_true).^2));
    sa_bar = mean(sig_1st);
    st_bar = mean(sig_true);
    n=length(sig_true);
    numerator = sum(sig_1st.*sig_true)-(n*sa_bar*st_bar);
    den1 = sqrt(sum(sig_1st.^2)-n*sa_bar.^2);
    den2 = sqrt(sum(sig_true.^2)-n*st_bar.^2);
    denominator = den1*den2;
    cor_uncorrected(i) = numerator./denominator;
    sa_bar = mean(sig_2nd);
    st_bar = mean(sig_true);
    numerator = sum(sig_2nd.*sig_true)-(n*sa_bar*st_bar);
    den1 = sqrt(sum(sig_2nd.^2)-n*sa_bar.^2);
    den2 = sqrt(sum(sig_true.^2)-n*st_bar.^2);
    denominator = den1*den2;
    cor_2ncorrected(i) = numerator./denominator;

    %cor(i) = corr(sig_2nd,sig_true);
end
%time=time(2:27)
start = 1;
stop = 14;
close all
%time = time*60;
time=time(start:stop);
rmse_uncorrected=rmse_uncorrected(start:stop);
rmse_2ncorrected=rmse_2ncorrected(start:stop);
rmse_3rcorrected=rmse_3rcorrected(start:stop);
cor_2ncorrected=cor_2ncorrected(start:stop);
cor_uncorrected=cor_uncorrected(start:stop);
size(time);
size(rmse_2ncorrected);
%subplot(121)
hold on
plot(time,rmse_uncorrected,'r.-')
plot(time,rmse_2ncorrected,'b.-')
plot(time,rmse_3rcorrected,'g.-')
legend('-s1','-s1-T*corr','-s1-T^{2}*corr','Location','southeast')
ylabel('RMSE hr^{-1}')
xlabel('|T| hr')
%{
subplot(122)
hold on
plot(time,cor_2ncorrected,'b')
plot(time,cor_uncorrected,'r')
ylabel('correlation')
xlabel('|T|')
legend('-s1-T*corr','-s1','Location','southwest')
%saveas(fig,sprintf('%1.1f.fig',Q))
%
weight(j) = Q
cor_min(j) = min(rmse_2ncorrected)
uncor_min(j) = min(rmse_uncorrected)
end
figure;hold on;plot(weight,cor_min,'b-');plot(weight,uncor_min,'r-')
%}