#!/usr/bin/python3
# -*- coding: UTF-8 -*-

def log(func):
	def wrapper(*args, **kw):
		print('call %s():' % func.__name__)
		return func(*args, **kw)
	return wrapper

@log
def lineMesh(xlist,ylist,numlist,Nnum,Enum,nodeFile,eleFile):

	def nodeCoord(xlist,ylist,numlist,Nnum):

		
		def nodeData(xlist,ylist,num,Nnum):
			import math
			import numpy as np 

			# coordinate
			x=xlist
			y=ylist

			# mesh parameters
			x1,x2=x[0],x[1]
			y1,y2=y[0],y[1]
			n=num

			x=np.linspace(x1,x2,n+1)
			y=np.linspace(y1,y2,n+1)
			nn=range(Nnum,Nnum+n+1)
			# array transform to list
			x=x.tolist()
			y=y.tolist()
			# combine x with y
			xy=zip(x,y)
			coord=dict(zip(nn,xy))
			return coord

		x1,x2=xlist[:-1],xlist[1:]
		y1,y2=ylist[:-1],ylist[1:]

		xx,yy=zip(x1,x2),zip(y1,y2)
		xx=zip(xx,yy,numlist)
		nodeCoord={}
		for x in xx:
			temp=nodeData(list(x[0]),list(x[1]),x[2],Nnum)
			Nnum=sorted(temp.keys())[-1]
			nodeCoord=dict(nodeCoord,**temp)
		return nodeCoord

	def eleData(nodeData,Enum):
		# get the node tag data from nodeData dict
		nodeTag=nodeData.keys()
		# sorted the node tag
		nodeTag=sorted(nodeTag)
		# the two node of element
		iNode=nodeTag[:-1]
		jNode=nodeTag[1:]
		# element tag
		numE=len(nodeTag)-1
		eleTag=range(Enum,Enum+numE+1)
		# element data
		ele=dict(zip(eleTag,sorted(zip(iNode,jNode))))

		return ele

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



	nodeData=nodeCoord(xlist,ylist,numlist,Nnum)
	eleData=eleData(nodeData,Enum)

	write2file(nodeData,nodeFile)
	write2file(eleData,eleFile)

	return [sorted(nodeData.keys())[-1],sorted(eleData.keys())[-1]]

xlist=[0,10,30,20]
ylist=[0,0,10,10]
numlist=[10,20,50]
nodeFile='/media/zarhin/Documents/WorkPath/OpenSeesGit/pythonLearning/node.txt'
eleFile='/media/zarhin/Documents/WorkPath/OpenSeesGit/pythonLearning/ele.txt'

a=lineMesh(xlist,ylist,numlist,100,10,nodeFile,eleFile)
print a
