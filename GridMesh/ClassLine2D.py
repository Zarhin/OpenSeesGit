#!/usr/bin/python
# -*- coding: UTF-8 -*-

import math
import numpy as np 


class Line2D(object):
	"""
	对二维线构件进行网格划分，该类包含该线的基本信息：
	x1,y1 起点坐标; x2,y2 终点坐标
	num 划分段数
	x,y 为节点坐标信息
	n 为节点编号信息
	nStart 为节点起始编号
	"""
	def __init__(self,x1,x2,y1,y2,num,nStart):
		self.x=np.linspace(x1,x2,num+1).tolist()
		self.y=np.linspace(y1,y2,num+1).tolist()
		self.n=range(nStart,nStart+num+1)
	def coord(self):
		x,y,n=self.x,self.y,self.n
		xy=zip(x,y)
		self.coord=dict(zip(n,xy))
		return self.coord


# write data to file
def write2file(dictData,fileN):
	# sorted the key in dict
	key=sorted(dictData.keys())
	# write data to file by ergodic the dict
	with open(fileN,'w') as f:
		for k in key:
			f.write(str(k)+'\t')
			for x in dictData[k]:
				f.write(str(x)+'\t')
			f.write('\n')



a=Line2D(0,0,0,10,10,1)	
print a.coord()