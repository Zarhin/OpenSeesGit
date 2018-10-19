#!/usr/bin/python3
# -*- coding: UTF-8 -*-

import numpy as np 
from scipy.interpolate import interp1d

x = np.linspace(0, 10, num=11, endpoint=True)
y = np.cos(-x**2/9.0)
f = interp1d(x,y)
f2 = interp1d(x, y, kind='cubic')
print x,y,f(x)




# 创建待插值的数据
# x = np.linspace(0, 10, 11)
# y = x

# print (x,y)
# a
# # 分别用linear和quadratic插值
# fl = interp1d(x, y, kind='linear')
# fq = interp1d(x, y, kind='quadratic')

# #设置x的最大值和最小值以防止插值数据越界
# xint = np.linspace(x.min(), x.max(), 1000)
# yintl = fl(xint)
# yintq = fq(xint)

# import pylab as pl
# pl.plot(xint,fl(xint), color="green", label = "Linear")
# pl.plot(xint,fq(xint), color="yellow", label ="Quadratic")
# pl.legend(loc = "best")
# pl.show()


