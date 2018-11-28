#!/usr/bin/python3
# -*- coding: UTF-8 -*-


def lineMesh(xlist,ylist,numlist,Nnum,Enum,nodeFile,eleFile,SFlist):

	def lineCoord(x1,x2,num,SF):

		import math
		import numpy as np

		if SF==1.0:
			x=np.linspace(x1,x2,n+1)
			# array transform to list
			x=x.tolist()
		else:
			# the length of first line segment
			a1=(x2-x1)*(1-SF)/(1.0-SF**num)
			# the first item of line coordinate
			x=[x1]
			# the count vary
			nn=1
			while nn<=num:
				# the coordinate of x
				san=a1*(1-SF**nn)/(1-SF)
				x.append(x1+san)
				nn=nn+1
		return x

	def nodeCoord(xlist,ylist,numlist,Nnum,SFlist):


		# coordinate
		x=xlist
		y=ylist

		# mesh parameters
		nx=numlist[0]
		ny=numlist[1]
		x=lineCoord(x[0],x[1],numlist[0],SFlist[0])
		y=lineCoord(y[0],y[1],numlist[1],SFlist[1])
		nn=[Nnum ]
		coord=[]
		for yy in y:
			for xx in x:
				nn.append(nn[-1])
				nn[-1]+=1
				coord.append([xx,yy])
		coord=dict(zip(nn,coord))
		return coord


	def RecEleData(nodeData,numlist,Enum):
		# get the node tag data from nodeData dict
		nodeTag=nodeData.keys()
		# sorted the node tag
		nodeTag=sorted(nodeTag)
		# element count in x and y direction
		elex=numlist[0]
		eley=numlist[1]
		ny=1;
		eleTag=[]
		elelist=[]
		ii=0
		while ny<=eley:
			nx=1
			while nx<=elex:
				eleTag.append(Enum+ii)
				jj=(elex+1)*(ny-1)+nx-1
				iNode=nodeTag[jj]
				jNode=nodeTag[jj+1]
				kNode=nodeTag[jj+elex+2]
				lNode=nodeTag[jj+elex+1]
				elelist.append([iNode,jNode,kNode,lNode])
				ii+=1
				nx+=1
			# 1 2 3 4 5
			# 6 7 8 9 10
			ny+=1
		# element data
		ele=dict(zip(eleTag,elelist))
		# print ele
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
	eleData=RecEleData(nodeData,numlist,Enum)

	write2file(nodeData,nodeFile)
	write2file(eleData,eleFile)

	return [sorted(nodeData.keys())[-1],sorted(eleData.keys())[-1]]

xlist=[0,10]
ylist=[0,10]
numlist=[10,20]
nodeFile='E:/Desktop/node.txt'
eleFile='E:/Desktop/ele.txt'

a=lineMesh(xlist,ylist,numlist,1,1,nodeFile,eleFile,[2,5])
print(a)
