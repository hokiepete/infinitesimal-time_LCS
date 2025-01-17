import numpy as np
import pandas as pd
import scipy.io as sp

length = 9
t0 = 0
tf = 1

data = []
name = []
time = np.linspace(t0,tf,length)


#F = sp.loadmat('s1v2.mat')
F = sp.loadmat('s1_small.mat')
#F = sp.loadmat('s1_big.mat')
s1 = F['s1'].ravel()
del F
data.append(-s1.squeeze())
name.append('s1')

F = sp.loadmat('sigma_small.mat')
#F = sp.loadmat('sigma_big.mat')
ftle = F['sigma']
del F

for tt in range(1,length):#timelen):
    #if tt == 0length:
    #    continue
    
    #f = ftle[timelen-1-tt,:,:] - ftle[timelen-1-tt,:,:].min(axis=None)
    #f = ftle[-tt-1,:,:]# - ftle[-tt-1,:,:].min(axis=None)
    #f = f/f.max(axis=None)
    #f =  np.ma.filled(f,np.nan)
    data.append(ftle[tt,:,:,:].ravel())
    name.append('{0:1.3f}'.format(time[tt]))


#Alldata = pd.DataFrame(np.transpose([s1.ravel(),ftle_2hr.ravel(),ftle_4hr.ravel(),ftle_6hr.ravel()]),columns=['s1','2hr','4hr','6hr'])
Alldata = pd.DataFrame(np.transpose(data),columns=name)
Alldata.corr().to_csv('Correlation_and_stats_abc.csv',mode='w',float_format='%1.3f')
#B=Alldata.describe()
#B.to_csv('Correlation_and_stats_v2.csv',mode='a')


#"""