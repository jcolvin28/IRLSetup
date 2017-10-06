# coding: utf-8

# In[1]:

## DEFINE THE FUNCTION

import matplotlib.pyplot as plt
import numpy as np


# In[2]:

# maximum wind speed
wspd_max = 25
wspd_bins = wspd_max + 1

# array size for wind dir and spd
u1 = np.zeros((360,wspd_bins)) * 1.0
u2 = np.zeros((360,wspd_bins)) * 1.0
windind = np.indices((360,wspd_bins))
winddir = np.indices((360,wspd_bins))
windspd = np.indices((360,wspd_bins))
winddir = windind[0][:][:]/1.0
windspd = windind[1][:][:]/1.0
u1 = np.cos(np.deg2rad(winddir+10))*windspd
u2 = np.cos(np.deg2rad(winddir+25))*windspd


# In[3]:

ur = np.zeros((360,wspd_bins)) * 1.0
setup = np.zeros((360,wspd_bins)) * 1.0
sign = np.zeros((360,wspd_bins)) * 1.0
ur = 1.0 * (u1 * 28 + u2 * 70) / (28 + 70)
sign = np.sign(ur)
setup = 1.637 * sign * abs(ur)**1.5



# In[4]:

azimuths = np.radians(np.linspace(0, 360, 360))
zeniths = np.arange(0, wspd_bins, 1)

r, theta = np.meshgrid(zeniths, azimuths)
#values = 90.0+5.0*np.random.random((len(azimuths), len(zeniths)))

#theta.shape

fig, ax = plt.subplots(subplot_kw=dict(projection='polar'))
#ax.set_theta_zero_location("W")
ax.set_theta_zero_location('N')
ax.set_theta_direction(-1)
pp = plt.contourf(theta, r, setup, 30, label='tmp',cmap='RdBu_r')

cbar = plt.colorbar(pp, orientation='vertical')
cbar.ax.set_ylabel('setup (cm)')
pp = plt.contour(theta, r, setup,30,colors='k')

plt.show()


# In[ ]:
