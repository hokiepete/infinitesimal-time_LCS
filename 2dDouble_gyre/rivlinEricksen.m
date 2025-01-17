close all
clear all
clc

syms u(x,y,t) v(x,y,t) f(x,t)% e w A
%assume(A,'real')
%assume(e,'real')
%assume(w,'real')
assume(x,'real')
assume(y,'real')
assume(t,'real')

A=0.1;
w=0.2*pi;
e=0.25;

f(x,t) = (e.*sin(w.*t)).*x.^2+(1-2.*e.*sin(w.*t)).*x;
u(x,y,t) =-pi.*A.*sin(pi.*f).*cos(y.*pi);    
v(x,y,t) = pi.*A.*cos(pi.*f).*sin(y.*pi).*diff(f,x);
dudt = diff(u,t);
dudx = diff(u,x);
dudy = diff(u,y);

dvdt = diff(v,t);
dvdx = diff(v,x);
dvdy = diff(v,y);

%U = [u;v];
grad_v = [dudx,dudy;dvdx,dvdy];
S = 0.5*(grad_v+grad_v');
DSdt = diff(S,t)+u.*diff(S,x)+v.*diff(S,y);
B = DSdt - grad_v*S-S*grad_v';
DBdt = diff(B,t)+u.*diff(B,x)+v.*diff(B,y);
Q = DBdt - grad_v*B-B*grad_v';



%{
au = dudt + u*dudx + v*dudy;
av = dvdt + u*dvdx + v*dvdy;

daudt = diff(au,t);
daudx = diff(au,x);
daudy = diff(au,y);

davdt = diff(av,t);
davdx = diff(av,x);
davdy = diff(av,y);

ju = daudt+u.*daudx+v.*daudy;
jv = davdt+u.*davdx+v.*davdy;

djudt = diff(ju,t);
djudx = diff(ju,x);
djudy = diff(ju,y);

djvdt = diff(jv,t);
djvdx = diff(jv,x);
djvdy = diff(jv,y);

grad_v = [dudx,dudy;dvdx,dvdy];
grad_a = [daudx,daudy;davdx,davdy];
grad_j = [djudx,djudy;djvdx,djvdy];

%{
grad_v = [dudx,dvdx;dudy,dvdy];
grad_a = [daudx,davdx;daudy,davdy];
grad_j = [djudx,djvdx;djudy,djvdy];
%}


B = 0.5*(grad_a+grad_a')+grad_v'*grad_v;
Q = 0.5*(grad_j + grad_j')+(grad_v'*grad_a+grad_a'*grad_v);
%}
xdim = 31
ydim =15
xx = linspace(0,2,xdim);
yy = linspace(0,1,ydim);
[xx,yy]=meshgrid(xx,yy);
R = [0,-1;1,0];
tt = 0;
for i = 1:ydim
    for j = 1:xdim
        i,j
        SS = reshape(double(subs(S,[x,y,t],[xx(i,j),yy(i,j),tt])),2,2);
        BB = reshape(double(subs(B,[x,y,t],[xx(i,j),yy(i,j),tt])),2,2);
        QQ = reshape(double(subs(Q,[x,y,t],[xx(i,j),yy(i,j),tt])),2,2);
        [V D] = eig(SS);
        if ~issorted(diag(D))
            [D,I] = sort(diag(D));
            V = V(:, I);
        end
        lambda_0(i,j) = D(1,1);
        X0 = V(:,1);
        lambda_1(i,j) = X0'*BB*X0;
        
        %First lambda_2 method calculating Xi_1
        X1 = -((BB - lambda_1(i,j)*eye(size(BB)))*X0) \ (SS - lambda_0(i,j)*eye(size(SS)));
        if sum(X1)~=0
            X1=X1'/norm(X1);
        else
            X1=X1';
        end
        %lambda_2_first(i,j) = X0'*QQ*X0 + X0'*BB*X1 - X0'*SS*X1;
        lambda_2_first(i,j) = X0'*QQ*X0 + X0'*BB*X1 - lambda_1(i,j).*X0'*X1;
        check(i,j) = X0'*QQ*X0;
        heck(i,j) = X0'*BB*X1;
        eck(i,j) = lambda_1(i,j).*X0'*X1;
        ck(i,j) = X0'*SS*X1;
        
        %Second lambda_2 method bypassing Xi_1
        mu = X0'*R'*(SS-lambda_0(i,j)*eye(size(SS)))*R*X0;
        d = X0'*R'*BB*X0;
        if mu~=0
            lambda_2_second(i,j) = X0'*QQ*X0 - d.^2./mu;
        else
            lambda_2_second(i,j)=nan;
        end
    end
end
figure
subplot(221)
surface(xx,yy,lambda_0,'edgecolor','none')
colorbar
subplot(222)
surface(xx,yy,lambda_1,'edgecolor','none')
colorbar
subplot(223)
surface(xx,yy,lambda_2_first,'edgecolor','none')
colorbar
subplot(224)
surface(xx,yy,lambda_2_second,'edgecolor','none')
colorbar

save er_analytic_lambda_terms xx yy lambda_0 lambda_1 lambda_2_first lambda_2_second


figure
subplot(221)
surface(xx,yy,check,'edgecolor','none')
colorbar
subplot(222)
surface(xx,yy,heck,'edgecolor','none')
colorbar
subplot(223)
surface(xx,yy,eck,'edgecolor','none')
colorbar
subplot(224)
surface(xx,yy,ck,'edgecolor','none')
colorbar

figure
subplot(121)
surface(s1,'edgecolor','none')
colorbar

subplot(122)
surface(lambda_0,'edgecolor','none')
colorbar


figure
subplot(121)
surface(l1,'edgecolor','none')
colorbar

subplot(122)
surface(lambda_1,'edgecolor','none')
colorbar


figure
subplot(121)
surface(a1,'edgecolor','none')
colorbar

subplot(122)
surface(lambda_2_first,'edgecolor','none')
colorbar

figure
subplot(121)
surface(a2,'edgecolor','none')
colorbar

subplot(122)
surface(lambda_2_second,'edgecolor','none')
colorbar

%}
%}
%}