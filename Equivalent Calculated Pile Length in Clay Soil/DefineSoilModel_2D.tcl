# ******************************************************
# ********        FINCTIONAL DISCRIPTION     ***********
# ******************************************************
# 
# 
# -----(0,0)----------------------(width,0)----Ground
#      ↑    |     → → → →        |
#      |    |     ↓              |
#      |    |     ↓              |
# depth|    |     ↓              |
#      |    |     ↓              |
#      |    |                    |
#     _↓_   |____________________|
#           |←------------------→|
#                     width
# 
# 
# ---- Description
# -- 1. Modeled from up to down, left to right
# -- 2. Input :
# 		width:     	The width of soil layers;
#       layerDepth: It's a list @of depth for every soil layers;
#       enumX:		The element number in the horizon direction;
#       Edata:		It's a list of element data in the vertical direction for every soil layers;
#       			It must start with "S" for element size or "N" for element number;
#       startNodeTag: 	The start node tag, the default is 1;
#       starCoord: 	The star node coordinate, the default is (0.0,0.0)
# -- 3. Output:
#       (1) soil nodes data in the file of soilNode.txt in the path of ModelData/
#       (2) soil elements data in the file of soilEle.txt in the path of ModelData/
# -- 4. Return: {$nnumX $startNodeTag {nodeTag1 nodeTag2 ...} {eleTag1 eleTag2 ...}}
#       nnumX :		The node number of every soil layer;
#       startNodeTag: The start node Tag;
# 		nodeTag1: 	The node tag in depth of the first layer
# 		nodeTag2: 	The node tag in depth of the second layer
#       eleTag1:	The element tag in the depth of first layer            
#       eleTag2:	The element tag in the depth of second layer            
# 
# 
# 
proc DefineSoilModel_2D { width {layerDepth {1.0 }} enumX {Edata { S 1.0 }} {startNodeTag 1} {startCoord {0.0 0.0}} }\
{
	# ----Validity Check
	set type [lindex $Edata 0]
	if {([string equal $type S]==0 && [string equal $type N]==0)} {
		puts "Erro: Data type identifier of element data isn\'t \'S(string)\' or \'N(number)\' in the vertical direction, please Check your input data!!!"
		return
	}
	# ----Soil Geometry Parameters
	# --Vertical direction
	# depth
	set depth {}
	set deep 0.0
	foreach var $layerDepth {
		set deep [expr $deep+$var]
		lappend depth $deep
	}
	# esize enum
	set esize {}
	set enum  {}
	set num1 [llength $layerDepth]
	set num2 [expr [llength $Edata]-1]
	
	if {[string equal $type S]} {
		# when the input data is element size
		for {set i 1} {$i <= $num1} {incr i} {
			# deep
			set deep [lindex $layerDepth [expr $i-1]]
			# enum and esize
			if {$i<$num2} {
				set size [lindex $Edata $i]
			} else {
				set size [lindex $Edata end]
			}
			set enumber [expr $deep*1.0/$size]
			# check if enumber is an integer
			if {$enumber>[expr int($enumber)]} {
				set enumber [expr int($enumber+1)]
				set size [expr $deep*1.0/$enumber]
			} else {
				set enumber [expr int($enumber)]
				set size [expr $size]
			}	
			lappend esize $size
			lappend enum $enumber
		}
		
	} else {
		# when the input data is element number
		for {set i 1} {$i <= $num1} {incr i} {
			# deep
			set deep [lindex $layerDepth [expr $i-1]]
			# enum and esize
			if {$i<$num2} {
				set enumber [expr int([lindex $Edata $i])]
			} else {
				set enumber [expr int([lindex $Edata end])]
			}
			set size [expr $deep*1.0/$enumber]
			lappend esize $size
			lappend enum $enumber

			
		}
	}
	puts "===> The layer depth is $layerDepth \n \
	    \t The element size of soil layers is $esize \n \
		\t The element number of soil layers is $enum\n"
	
	# --Horizonal direction
	set enumX [expr int($enumX)]
	set esizeX [expr $width*1.0/$enumX]
	puts "===> The element number in the horizon direction is $enumX\n\
			\t The element size in the horizon direciton is $esizeX\n"


	# ----Out Put Node Data To file
	# -- Out Put file folder
	set fileFolder "ModelData"
	if {[file exists $fileFolder]==0} {
		file mkdir $fileFolder
	}

	# -- Open file
	set fileID "ModelData/soilNode.txt"
	set fileN [open $fileID "w"]
	# -- Out put soil node data
	# return list
	set nodeInfo [list  [expr $enumX+1] $startNodeTag ]
	# start node tag
	set nodeTag [expr $startNodeTag]
	# initial coordinary
	set ScoorX [lindex $startCoord 0]
	set ScoorY [lindex $startCoord 1]
	set coorY [expr $ScoorY+[lindex $esize 0]]
	# soil nodes
	puts "===> Start define soil nodes..."
	# element number in the vertical direction
	foreach deep  $depth esizeY $esize {
		# loop in the vertical direciton
		while {$coorY > [expr $ScoorY-$deep]} {
			# initial coordinary
			set coorX $ScoorX
			set coorY [format "%0.2f" [expr $coorY-$esizeY]]
			# add interface node to return list
			if {$coorY==[expr $ScoorY-$deep]} {
				lappend nodeInfo $nodeTag
			}
			# loop in the horizon direction
			for {set i 1} {$i <= [expr 1+$enumX]} {incr i} {
				# node data
				# puts "$nodeTag $coorX $coorY"
				puts $fileN "$nodeTag $coorX $coorY"
				# x coordinaty
				set coorX [format "%0.2f" [expr $coorX+$esizeX]]
				incr nodeTag
			}
		}
	}
	# --Close file
	close $fileN 
	puts "===> Finished output soil nodes data...\n \
			\t There are [expr $nodeTag-$startNodeTag] soil nodes.\n"

	# ---- Define Soil Elements Data
	# ---Soil Elements file
	set fileID "ModelData/soilEle.txt"
	set fileN [open $fileID "w"]
	puts "===> Start output soil elements data..."
	# initial element tag
	set eleTag 1
	set num [llength $enum]
	lappend nodeInfo 1
	# loop soil layers
	foreach enumY $enum var [lrange $nodeInfo 1 $num] {
		# loop in the vertical direction
		for {set i 1} {$i <= $enumY} {incr i} {
			# loop in the horizon direction
			for {set j 1} {$j <= $enumX} {incr j} {
				# element node tag
				set iNode [expr $var+($i-1)*($enumX+1)+$j-1]
				set jNode [expr $iNode+$enumX+1]
				set kNode [expr $iNode+$enumX+2]
				set lNode [expr $iNode+1]
				# output elements data to file
				# puts "$eleTag $iNode $jNode $kNode $lNode "
				puts $fileN "$eleTag $iNode $jNode $kNode $lNode "
				incr eleTag 
			}
		
		}
		lappend nodeInfo [expr $eleTag-1]
	}
	close $fileN

	puts "===> Finished output soil elements data....\n \
			\t There are [expr $eleTag-1] soil elements.\n"
	return $nodeInfo
}

