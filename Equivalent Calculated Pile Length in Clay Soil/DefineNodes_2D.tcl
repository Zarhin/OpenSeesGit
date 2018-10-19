# Define only one node in the soil layer interface
# Return soil interface nodes and last node
# Write node coordinate and effective length to "NodeName.txt"


proc DefineNodes_2D { Esize Length  startNodeTag  NodeName  {Y 0.0} { LayerDeep { }}}\
{

	puts "====> Start Define $NodeName node..."
	# Define Original node tag and coordinate
	set nodeTag [expr $startNodeTag-1]
	set coorY [expr $Y]
	set coorX 0.0
	# define temp file for temporary files
	set fileFolder "tempFiles"
	if {[file exists $fileFolder]==0} {
		file mkdir $fileFolder
	}
	# write the node data to file: nodetag nodeCoordinate effectiveLength
	set fileID "tempFiles/$NodeName.txt"
	set fileN [open $fileID "w"]

	# Create a empty list for node information
	set nodeInfo {}

	# Define node coordinate
	while {$coorY>=[expr -$Length]} {
		# set node tag
		set nodeTag [expr $nodeTag+1]

		# Define node coordinat
		node $nodeTag $coorX $coorY

		# Out put node Info in the window
		# puts "node $nodeTag $coorX $coorY"

		set effeLength $Esize
		# define effective length
		if {$coorY==$Y || $coorY==-$Length} {
			set effeLength [expr $Esize/2.0]
		}
		
		# Determine whether the node is on the interface 
		if {$coorY in $LayerDeep } {
			# lappend interface node to list
			lappend nodeInfo $nodeTag
			# The effective length corresponding to the node on the interface is halved
			set effeLength [expr $Esize/2.0]
			# write the node data to file
			puts $fileN "node $nodeTag $coorX $coorY $effeLength"

		} else {
			puts $fileN "node $nodeTag $coorX $coorY $effeLength"
		}

		set coorY [expr $coorY-$Esize]
		set coorY [format "%0.2f" $coorY]

	}
	close $fileN 
	set endNodeTag [expr $nodeTag]
	set nodeNum [expr {$endNodeTag-$startNodeTag+1}]
	puts "====> Finished define $NodeName nodes."
	puts "====> The $NodeName Nodetag is from $startNodeTag to $endNodeTag, \
		and there are $nodeNum $NodeName nodes...\n\n" 
	lappend nodeInfo $nodeTag
	return $nodeInfo
}