#!/usr/bin/python3
# -*- coding: UTF-8 -*-


def lineMesh(xlist,ylist,numlist,Nnum,Enum,nodeFile,eleFile,SFlist):

	def nodeData(xlist,ylist,num,Nnum,SF):
		import math
		import numpy as np 

		# coordinate
		x=xlist
		y=ylist

		# mesh parameters
		x1,x2=x[0],x[1]
		y1,y2=y[0],y[1]
		n=num
		x=[x1]
		y=[y1]

		if SF==1.0:
			x=np.linspace(x1,x2,n+1)
			y=np.linspace(y1,y2,n+1)
			# array transform to list
			x=x.tolist()
			y=y.tolist()
		else:
			a1=(x2-x1)*(1-SF)/(1.0-SF**n)
			b1=(y2-y1)*(1-SF)/(1.0-SF**n)
			nn=1
			while nn<=n:
				san=a1*(1-SF**nn)/(1-SF)
				sbn=b1*(1-SF**nn)/(1-SF)
				x.append(x1+san)
				y.append(y1+sbn)
				nn=nn+1
		nn=range(Nnum,Nnum+n+1)
		# combine x with y
		xy=zip(x,y)
		coord=dict(zip(nn,xy))
		return coord




	def nodeCoord(xlist,ylist,numlist,Nnum,SFlist):

		x1,x2=xlist[:-1],xlist[1:]
		y1,y2=ylist[:-1],ylist[1:]

		# zip the data to the shape of [xlist,ylist,num,Nnum,SF]
		xx,yy=zip(x1,x2),zip(y1,y2)
		xx=zip(xx,yy,numlist,SFlist)
		nodeCoord={}
		for x in xx:
			# nodeData(xlist,ylist,num,Nnum,SF)
			temp=nodeData(list(x[0]),list(x[1]),x[2],Nnum,x[3])
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



	nodeData=nodeCoord(xlist,ylist,numlist,Nnum,SFlist)
	# print nodeData
	eleData=eleData(nodeData,Enum)

	write2file(nodeData,nodeFile)
	write2file(eleData,eleFile)

	return [sorted(nodeData.keys())[-1],sorted(eleData.keys())[-1]]

xlist=[0,10,10]
ylist=[0,0,10]
numlist=[10,20]
nodeFile='/media/zarhin/Documents/WorkPath/OpenSeesGit/pythonLearning/node.txt'
eleFile='/media/zarhin/Documents/WorkPath/OpenSeesGit/pythonLearning/ele.txt'

a=lineMesh(xlist,ylist,numlist,100,10,nodeFile,eleFile,[1.5,1.2])
print a
