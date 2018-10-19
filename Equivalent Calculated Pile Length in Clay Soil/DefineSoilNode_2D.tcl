# Layer Deep: Use the format of "%0.2f"
# Return soil layer interface nodes tag and last node tag
# There are $NodeNum nodes for one sides

proc DefineSoilNode_2D { Deep Width  Esize startNodeTag {LayerDeep {}} {NodeNum 1000} }\
{
	# Define some pile parameters
	# set eleSize [expr int(ceil($L/$esize))]
	# set eleNum [expr int($eleNum)]	
	puts "====> Start Define soil node..."

	# Set Return List
	set nodeInfo { }
	# Define initial coordinate and node tag
	set nodeTag [expr $startNodeTag-1]
	set coorY 0.0
	set coorX 0.0
	# Write the node data to file: nodeTag nodeCoordinata
	# define temp file for temporary files
	set fileFolder "tempFiles"
	if {[file exists $fileFolder]==0} {
		file mkdir $fileFolder
	}
	set fileID "tempFiles/soilNode.txt"
	set fileN [open $fileID "w"]
	# Define soil nodes
	while {$coorY>=[expr -$Deep]} {
		# Define node tag
		set nodeTag [expr $nodeTag+1]
		# Define node coordinate
		node $nodeTag $coorX $coorY
		node [expr $nodeTag+$NodeNum] [expr $coorX+$Width] $coorY
		# get the node tag of soil layer interface
		if {[format "%0.2f" $coorY] in $LayerDeep} {
		 	lappend nodeInfo $nodeTag
		 } 
		puts $fileN "node    $nodeTag    $coorX    $coorY    node    [expr $nodeTag+$NodeNum]    [expr $coorX+$Width]    $coorY"
		# puts  "node    $nodeTag    $coorX    $coorY    node    [expr $nodeTag+$NodeNum]    [expr $coorX+$Width]    $coorY"
		# Increase Y coordiante
		set coorY [format "%0.5f" [expr $coorY-$Esize]]
	}
	close $fileN 
	set endNodeTag [expr $nodeTag]
	set nodeNum [expr {$endNodeTag-$startNodeTag+1}]
	puts "====> Finished define soil nodes."
	puts "====> There are [expr int(2.0*$nodeNum)] soil nodes...\n\n" 

	# lappend last node tag to node info
	lappend nodeInfo $nodeTag

	# Define output element data file
	puts "====> Start output soile element data..."
	set nodeTag0 [expr $startNodeTag]
	set elementFile "tempFiles/soilEle.txt"
	set openEle [open $elementFile w]
	for {set i 1} {$i < $nodeNum} {incr i} {
		set nodeTag1 [expr $nodeTag0]
		set nodeTag2 [expr $nodeTag0+1]
		set nodeTag3 [expr $nodeTag0+$NodeNum+1]
		set nodeTag4 [expr $nodeTag0+$NodeNum]
		puts $openEle "$i $nodeTag1 $nodeTag2 $nodeTag3 $nodeTag4"	
		set nodeTag0 [expr $nodeTag0+1]
	}
	close $openEle
	puts "====> Finished output soil element data....\n"
	return $nodeInfo
}