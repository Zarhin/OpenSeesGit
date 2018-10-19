
# Clear all 
wipe

# Use Spring Damping
# Define output file 
# Use pile nodes as master nodes
# dt 0.01s

set D 1.0
while {$D<=1.0} {
	# Define modal analysis output file 
	set periodFile "Result/Diameter/period"
	if {[file exists $periodFile]==0} {
		file mkdir $periodFile
	}
	# modal period file
	set periodF "$periodFile/period$D.txt"
	set openFile [open $periodF "w"]

	for {set pileLength 10.0} {$pileLength <= 10.0} {set pileLength [expr $pileLength+1.0]} {
		
		wipe
		set output "Result/Diameter/$D/$pileLength m"
		if {[file exists $output]==0} {
			file mkdir $output
		}

		# load tcl source
		source DefineNodes_2D.tcl
		source DefineSoilNode_2D.tcl
		source main.tcl


		#---Constant Parameters
		# PI
		set pi [expr {asin(1)*2.0}]
		# Ground Acceleration
		set g [expr 9.81]






		# --------------------------------------------------
		# 1. Define Soil Geometry
		# --------------------------------------------------

		# ----Soil material parameters for top layer
		# soil density for top layers
		set rho 1.5
		# layer thickness for layers
		set layerthick 1.0
		# soil depth for layers
		set depth 31.0
		# reference press
		set refPress 100.0
		# soil poisson's ratio 
		set nu 0.0
		# soil cohesion
		set cohesion 35.0
		# peak shear strain
		set peakShearStra 0.1
		# soil friciton angle
		set phi 0.0
		# phase transformation angle
		set phaseAng 27.0
		# pressure dependency coefficient
		set pressCoeff 0.0
		# contraction
		set contract 0.06
		# dilation coefficients
		set dilate1 0.5
		set dilate2 2.5
		# liquefaction coefficients
		set liq1 0.0
		set liq2 0.0
		set liq3 0.0

		# ---Soil elements material parameters for each layer
		set totalLayers 0
		# numbers for soil layers
		set totalLayers [expr int($depth/$layerthick)]


		# define soil shear wave velocity
		# set reference shear force modulus
		set refShearModulu 6.0e4 
		# set reference shear wave velocity
		set refVelocity [expr pow($refShearModulu/$rho,0.5)]
		# set layer shear wave velocity
		for {set i 1} {$i <= $totalLayers} {incr i} {
			# initial effective confinement
			set P [expr ($i-0.5)*$layerthick*$g*$rho]
			# shear wave velocity
			set Vs($i) [expr $refVelocity*pow(($P/$refPress),0.25)]
			puts "$Vs($i)"
		}

		# define soil material parameters for top layer
		for {set i 1} {$i <= $totalLayers} {incr i} {
			# shear modulus
			set G($i) [expr $rho*$Vs($i)*$Vs($i)]
			# elastic modulus
			set E($i)  [expr 2.0*$G($i)/(1+$nu)]
			# bulk modulus
			set B($i)  [expr $E($i)/(3.0*(1-2*$nu))]
		}


		# ----Wavelength parameters
		# cutoff frequency
		set fmax 50.0
		# minimal shear wave velocity
		set Vmin $Vs(1)
		# wavelength 
		set wave [expr $Vmin/$fmax]
		# number of element per one wavelength
		set nEle 8
		# bedrock shear wave velocity
		set rockVs 762.0
		# bedrock mass density 
		set rockDen 2.396

		# ---Define soil mesh geometry

		# vertical element size
		set soilEsize 0.25
		# element number for each layers
		set numEleY [expr $layerthick/$soilEsize]







		# --------------------------------------------------
		# 6. Define Pile and Soil Spring Nodes
		# --------------------------------------------------


		#---Builed spacial dimention of model and number of dim-of-freedom in pile node
		model BasicBuilder -ndm 2 -ndf 3

		# Define pile nodes
		# Define start pile node tag
		set startPNT 1
		# pile length
		# set pileLength 15.0
		# proc DefineNodes_2D { Esize Length startNodeTag  NodeName {Y 0.0} { LayerDeep {}}}
		set pileNodeInfo [DefineNodes_2D 0.5 $pileLength $startPNT "pileNode" 5 {0.00} ]
		set maxPNodeNum [lindex $pileNodeInfo end]
		# define pile node region
		eval "region 22 -nodeRange $startPNT $maxPNodeNum"


		# Build soil spring 
		model BasicBuilder -ndm 2 -ndf 2

		# ---Define soil spring node

		# Define soil spring node 
		# define first node tag for spring nodes which will combined with pile
		set startSPN 201
		# Define soil layer interface coordinate
		set soilLayerInterCoord {}
		# proc DefineNodes_2D { Esize Length  startNodeTag  NodeName {Y 0.0} { LayerDeep {}}}
		set springPileNodeInfo [DefineNodes_2D 0.5 $pileLength $startSPN "soilSpring" 0.0 $soilLayerInterCoord ]
		# max soil spring node tag
		set maxSPN [lindex $springPileNodeInfo end]

		# ---Define spring end nodes
		# define first node tag for spring nodes which will combined with soil
		set startSSN 401
		# define spring end nodes
		set springSoilNodeInfo [DefineNodes_2D 0.5 $pileLength $startSSN "springEnd" 0.0 $soilLayerInterCoord ]
		# max spring end node tag
		set maxSEN [lindex $springSoilNodeInfo end]
		# number of spring end nodes
		set numSEN [expr $maxSEN-$startSSN+1]


		# --------------------------------------------------
		# 7. Define Boundary Condition
		# --------------------------------------------------

		# --Fix pile end node
		# fix $maxPNodeNum 0 1 0
		fix $maxPNodeNum 0 1 0
		puts "fix $maxPNodeNum 0 1 0"
		puts "====>Finished fix pile boundary...\n"


		# Bound soil spring and pile nodes
		# Initial node tag
		set SNode [lindex $pileNodeInfo 0]
		for {set i $startSPN} {$i <= $maxSPN} {incr i} {
			equalDOF  $i $SNode 1 
			fix $i 0 1
			# puts "equalDOF $i $SNode  1 "
			set SNode [expr $SNode+1]
		}

		puts "====> Finished bound soil and pile nodes...\n"

		# Bound spring and soil nodes
		for {set i 1} {$i <= $numSEN} {incr i} {
			set SNode [expr $i+400]
			fix $SNode 1 1
		}

		# --------------------------------------------------
		# 8. Define Pile Elements and pile mass
		# --------------------------------------------------

		# Define spacial dimension of model and number of degree-of-freedom at nodes
		model BasicBuilder -ndm 2 -ndf 3

		#---Define pile mass
		mass $startPNT 30.0 30.0 0.0

		#---Define Pile Material Paramenters
		# Diameter
		# set D 1.0
		# Radius
		set R [expr $D/2.0]
		# Cross Area
		set A [expr $pi*$R*$R]
		# Second Moment of Area About the Local z-Axis
		set Iz [expr $pi*pow($D,4)/64.0]
		# Young's Modulu
		set EP 3.0e7
		# Density of Pile
		set pileDensity 2.6
		# Element Mass Per Unit Length
		set massDens [expr $pi*$R*$R*$pileDensity]


		# Define geomTransf
		geomTransf PDelta 1


		#---Define Pile Element

		# Define a elastic section
		section Elastic 1 $EP $A $Iz

		# Create a empty list for pile element
		set pileEleList {}
		puts "====> Start define pile elements..."
		set eleTag 0
		set startEleTag [expr $eleTag+1]
		for {set i $startPNT} {$i < $maxPNodeNum} {incr i} {
			set eleTag [expr $eleTag+1]
			set iNode [expr $i]
			set jNode [expr $i+1]
			# element dispBeamColumn $eleTag $iNode $jNode $numIntgrPts $secTag $transfTag <-mass $massDens>
			element dispBeamColumn $eleTag $iNode $jNode 5 1 1 -mass $massDens  
			# element elasticBeamColumn $eleTag $iNode $jNode $A $E $Iz 1 -mass $massDens
			# puts "element dispBeamColumn $eleTag $iNode $jNode 5 1 1 -mass $massDens"
			# lappend pile element tag into pileEleList
			lappend pileEleList $eleTag
		}
		set endEleTag [expr $eleTag]
		puts "====> Finished define pile elements."
		puts "====> The pileElement tag is from $startEleTag to $endEleTag,\
			 and there are [expr $endEleTag-$startEleTag+1] pile elements...\n\n"

		# define pile elements region
		eval "region 21 -ele $pileEleList"

		# --------------------------------------------------
		# 9. Define Soil Spring Materials
		# --------------------------------------------------

		# element size
		set Esize 0.5

		# Define spacial dimention of model and number of degree-of-freedom at nodes

		model BasicBuilder -ndm 2 -ndf 2

		# ---Define soil spring material 

		# --Define node tag range for layer 1
		# start node tag
		set startNT $startSPN
		# end node tag
		set endNT [lindex $springPileNodeInfo 0]

		# undrained shear strength \
		 in the undrained condition the strength equaled to cohesion
		set cu $cohesion
		# effective unit weight of soil
		set r1 [expr $rho*$g]

		puts "====> Define layer 1 pyspring materials..."
		set soilType 1; 	
		set Cd 0.3;
		set matTag 1000;
		set startMatTag [expr $matTag+1]
		set e50 0.02;  		# strain which occurs at one-half the maximum
		set J 0.5; 		# demensionless empirical constant with

		set num 0

		for {set i $startNT} {$i <=$endNT} {incr i} {
			set nodeTag $i
			# set the effective length of node
			set effeLength $Esize
			# Effective length is halved in the start and end node tag
			if {$i==$startNT || $i==$endNT} {
				set effeLength [expr $effeLength/2.0]
			}
			# material tag
			set matTag [expr $matTag+1]
			# p-y spring parameter
			set pyPara [get_pyParam_clay $cu $D $r1 $nodeTag $e50 $J $effeLength]
			set pult [lindex $pyPara 0]
			set Y50  [lindex $pyPara 1]
			set Cd   [expr $pi*$R*$effeLength*$cu/$pult]
			# define damping radio
			set c [expr 4.0*$D*$rho*$Vs([expr int($num/2.0)+1])*$effeLength]
			set num [expr $num+1]
			# create p-y spring material
			uniaxialMaterial PySimple1 $matTag $soilType [expr $pult] $Y50 $Cd $c
			# puts "uniaxialMaterial PySimple1 $matTag $soilType $pult $Y50 $Cd $c"
		}
		set endMatTag $matTag
		puts "====> Finished define layer 1 pyspring material."
		puts "====> The pyspring tag is from $startMatTag to $endMatTag, \
			 and there are [expr $endMatTag-$startMatTag+1] pyspring material...\n\n"

		# --------------------------------------------------
		# 10. Define Soil Spring Elements
		# --------------------------------------------------

		# Define p-y spring elements·
		puts "====> Define p-y spring Elements..."
		# create a empty list for spring elements
		set springEleList {}
		# initial element tag
		set eleTag 500
		set matTag 1000
		set startEleTag [expr $eleTag+1]
		for {set i $startSPN} {$i <=$maxSPN} {incr i} {
			set eleTag [expr $eleTag+1]
			set iNode [expr $i]
			set jNode [expr $i+200 ]
			set matTag [expr $matTag+1]
			# element zeroLength $eleTag $iNode $jNode -mat $matTag1  -dir 1 
			element zeroLength $eleTag $iNode $jNode -mat $matTag  -dir 1 
			# puts "	element zeroLength $eleTag $iNode $jNode -mat $matTag  -dir 1  "
			# Judge whether the node is in the interface 
			if {$i in [lrange $springPileNodeInfo 0 end-1]} {
				set eleTag [expr $eleTag+1]
				set matTag [expr $matTag+1]
				element zeroLength $eleTag $iNode $jNode -mat $matTag  -dir 1 
				# puts "	element zeroLength $eleTag $iNode $jNode -mat $matTag  -dir 1  "
			}
			# lappend spring element tag into springEleList
			lappend springEleList $eleTag
		}
		set endEleTag $eleTag
		puts "====> Finished define spring elements."
		puts "====> The spring element tag is from $startEleTag to $endEleTag, \
			 and there are [expr $endEleTag-$startEleTag+1] p-y spring element...\n\n"

		# define p-y element region
		eval "region 31 -eleOnly $springEleList"

		# record modal eigen
		recorder Node -file $output/eigen1.txt -region 22 -dof 1  "eigen 1" 
		recorder Node -file $output/eigen2.txt -region 22 -dof 1 "eigen 2" 
		recorder Node -file $output/eigen3.txt -region 22 -dof 1 "eigen 3" 
		recorder Node -file $output/eigen4.txt -region 22 -dof 1 "eigen 4" 
		recorder Node -file $output/eigen5.txt -region 22 -dof 1 "eigen 5" 

		puts "====> Finished creating eigen recorders...\n"


		#------------------------------------------------------
		#	Model Analysis
		#------------------------------------------------------
		puts "====> Start Model Analysis...."
		set numModes 5
		set lambda [eigen $numModes]
		# calculate period and out put to file
		for {set i 1} {$i <=$numModes} {incr i} {
			set omiga($i) [expr {pow([lindex $lambda [expr $i-1]],0.5)}]
			set period($i) [expr 2.0*$pi/$omiga($i)]
			set frequency($i) [expr 1.0/$period($i)]
			puts "$period($i)"
			append periods " " $period($i)
		}
		puts $openFile "-$pileLength $periods"
		set periods ""
		record 
		puts "====> Finished Model Analysis..."	

		if {$pileLength>=5.0} {		
			# remove constraint in end of soil spring nodes in x direction
			# Bound spring and soil nodes
			for {set i 1} {$i <= $numSEN} {incr i} {
				set SNode [expr $i+400]
				remove sp $SNode 1 
			}


			#-----------------------------------------------------------------------------------------------------------
			#  2. Define soil nodes
			#-----------------------------------------------------------------------------------------------------------

			# Build spacial dimension of model and numbers of degree-of-freedom in node
			model BasicBuilder -ndm 2 -ndf 2


			# Define soil layer interface coordinate for top layers
			set soilLayerInterCoord { }
			# Width
			set Width 1000.0
			# Define soil element nodes
			set startSNT 1001
			# DefineSoilNode_2D { Deep Width  soilEsize startNodeTag {LayerDeep {}}  }
			set soilNodeInfo [DefineSoilNode_2D $depth $Width $soilEsize $startSNT $soilLayerInterCoord]
			# set last soil node in the soil bottom
			set maxSNT [lindex $soilNodeInfo end]

			# set damping nodes
			node 3000 0.0 [expr -$depth]
			node 3001 0.0 [expr -$depth]

			puts "====>Finished creating all nodes...\n"

			# --------------------------------------------------
			# 3. Define Boundary Conditions
			# --------------------------------------------------


			# fix soil botton 
			fix $maxSNT 0 1
			fix [expr $maxSNT+1000] 0 1

			# fix damping node
			fix 3000 1 1
			fix 3001 0 1


			# equal damping node and soil node in the x direction
			equalDOF $maxSNT 3001 1

			# Set shear boundary
			equalDOF $maxSNT [expr $maxSNT+1000] 1

			for {set i $startSNT} {$i < $maxSNT} {incr i} {
				equalDOF $i [expr $i+1000] 1 2
				# puts "equalDOF $i [expr $i+1000] 1 2"
			}
			puts "====>Finished define soil boundary...\n"

			# Bound spring and soil nodes
			for {set i 1} {$i <= $numSEN} {incr i} {
				set MNode [expr ($i-1)*2+1001]
				set SNode [expr $i+400]
				equalDOF $MNode $SNode 1
				# puts "equalDOF $MNode $SNode 1"
			}
			puts "====> Finished creating all boundary of pile and spring...\n"


			# --------------------------------------------------
			# 4. Define Soil Element Material
			# --------------------------------------------------


			puts "====>Start define soil element material...\n"

			#  define soil materials
			for {set k 1} {$k <= $totalLayers} {incr k 1} {
				nDMaterial PressureIndependMultiYield $k 2 $rho $G($k) $B($k) $cohesion $peakShearStra \
			                                           $phi $refPress $pressCoeff -16\
			                                           1.00e-6 1.000  2.00e-6 1.000  5.00e-6 0.996 \
			                                           1.00e-5 0.984  2.00e-5 0.975  5.00e-5 0.922 \
			                                           1.00e-4 0.850  2.00e-4 0.734  5.00e-4 0.532 \
			                                           1.00e-3 0.367  2.00e-3 0.224  5.00e-3 0.139 \
			                                           1.00e-2 0.085  2.00e-2 0.051  5.00e-2 0.027 \
			                                           1.00e-1 0.021
			    # puts "nDMaterial PressureIndependMultiYield $k 2 $rho $G($k) $B($k) $cohesion $peakShearStra \
			                                           $phi $refPress $pressCoeff 20"                                      
			}

			puts "====>Finished creating all soil materials...\n"
			# 

			# ---Define damping coefficient
			# dashpot coefficient
			set mc [expr $rockVs*$rockDen*$Width]

			# material
			uniaxialMaterial Viscous 1000 $mc 1

			puts "====>Finished creating "

			# --------------------------------------------------
			# 5. Define elements
			# --------------------------------------------------

			# ---Define dashpot element
			# elements
			element zeroLength 5000 3000 3001 -mat 1000 -dir 1

			puts "====>Finished creating dashpot material and element...\n"


			puts "====>Start define soil elements...\n"
			# Read soil elements data from file
			set fileID "tempFiles/soilEle.txt"
			set fileN [open $fileID r]
			# set initial element tag
			set eleTag 100
			# Define element parameters
			set pressure 0.0
			set thick 1.0
			# Define a empty list for soil elements
			set soilEle {}
			# Define a empty list for soil nodes
			set soilNode {}
			# initial material tag
			set matTag 1
			# set count variable for layer elements
			set countVar 0
			# loop over elements
			foreach line [split [read -nonewline $fileN] \n] {
				# soil element tag
				set eleTag [expr $eleTag+1]
				# get node data
				set iNode [lindex $line 1]
				set jNode [lindex $line 2]
				set kNode [lindex $line 3]
				set lNode [lindex $line 4]
				# change count varible
				set countVar [expr $countVar+1]
				# Judge if need to change material tag
				if {$countVar>$numEleY} {
					set matTag [expr $matTag+1]
					# reset count variable
					set countVar 1
				}
				# Define body force for y direction
				set b2 [expr -$g*$rho]
				# element quad $eleTag $iNode $jNode $kNode $lNode $thick $type $matTag <$pressure $rho(1) $b1 $b2>
				element quad $eleTag $iNode $jNode $kNode $lNode $thick "PlaneStrain" $matTag \
						$pressure 0.0 0.0 $b2
				# puts "	element quad $eleTag $iNode $jNode $kNode $lNode $thick PlaneStrain $matTag \
						$pressure 0.0 0.0 $b2"
				# add elements tag to list
				lappend soilEle $eleTag 
				# add nodes tag to list
				lappend soilNode $iNode
			}
			close $fileN
			puts "====>Finished define soile elements...\n"

			# add bottom node to soil node list
			lappend soilNode $maxSNT
			# define soil region
			region 11 -eleOnly $soilEle
			region 12 -nodeOnly $soilNode


			# --------------------------------------------------
			# 11. Apply Gravity load
			# --------------------------------------------------

			#---Rayleigh damping parameters

			# damping ratio
			set damp    0.02
			# lower frequency
			set omega1  [expr 2*$pi*$frequency(1)]
			# upper frequency
			set omega2  [expr 2*$pi*$frequency(2)]
			# damping coefficients
			set a0      [expr 2*$damp*$omega1*$omega2/($omega1 + $omega2)]
			set a1      [expr 2*$damp/($omega1 + $omega2)]

			# Define rayleith damping for soil elements
			# eval "region 11 -ele $soilEle -rayleigh $a0 $a1 0.0 0.0"



			# ---Gravity recorder
			recorder Node -file $output/Gdisp.txt -time -node $startSNT -dof  2  disp


			#---ANALYSIS PARAMETERS
			# Newmark parameters
			set gamma  0.5
			set beta   0.25

			puts "====>Start gravity analysis..."

			constraints Transformation
			test        NormDispIncr 1e-5 30 0
			algorithm   Newton
			numberer    RCM
			system      ProfileSPD
			integrator  Newmark $gamma $beta 
			analysis    Transient

			# constraints Penalty 1.e14 1.e14
			# test        NormDispIncr 1e-4 35 1
			# algorithm   KrylovNewton
			# numberer    RCM
			# system      ProfileSPD
			# integrator  Newmark $gamma $beta
			# rayleigh   $a0 $a1 0.0 0.0
			# analysis    Transient

			set startT  [clock seconds]
			analyze     10 5.0e2
			puts "====>Finished with elastic gravity analysis..."

			# update materials to consider plastic behavior
			for {set k 1} {$k <= $totalLayers} {incr k} {
			    updateMaterialStage -material $k -stage 1
			}

			# plastic gravity loading
			analyze     40 5.0e2
			puts "====>Finished with plastic gravity analysis..."

			# --------------------------------------------------
			# 8. Apply earthquake load
			# --------------------------------------------------

			# ---Creat post-gravity recorders
			# reset time and analysis
			setTime 0.0
			wipeAnalysis
			remove recorders

			# ---Creat recorders for earthquake load
			# record nodal displacment, acceleration
			recorder Node -file $output/displacement.txt -time  -node $maxSNT 1001 -dof 1  disp
			recorder Node -file $output/acceleration.txt -time -node $maxSNT 1001 -dof 1   accel
			recorder Node -file $output/pileAccel.txt -time -nodeRange $startPNT $maxPNodeNum -dof 1 2 accel
			recorder Node -file $output/pileDisp.txt -time  -nodeRange $startPNT $maxPNodeNum -dof 1 2 disp

			# 
			# record elemental stress and strain (files are names to reflect GiD gp numbering)
			recorder Element -file $output/pileEle.txt  -time  -region 21  force
			recorder Element -file $output/springEle.txt  -time  -ele $springEleList  force
			recorder Element -file $output/Sdeformation.txt  -time  -ele $springEleList  deformation


			puts "====>Finished creating all recorders..."

			puts "====> It is calculated Diameter=$D pileLength=$pileLength"
			#---Ground motion parameters
			# time step in ground motion record
			set motionDT     0.01
			# number of steps in ground motion record
			set motionSteps  5370

			# define constant factor for applied velocity
			set cFactor [expr $Width*$rockDen*$rockVs]
			# # define accelerate time history file
			# set fileN ElCentroVel.txt

			# define velocity time history file
			set fileN ElCentroVel.txt
			# set fileN velocityHistory.out

			set dT [expr $motionDT/2.0]
			set nSteps [expr int($motionSteps*2) ]

			# ---Loading object
			# timeseries object for force history
			set mSeries "Path -dt $motionDT -filePath $fileN -factor $cFactor"
			# loading object
			pattern Plain 10 $mSeries {
			   load $maxSNT 1.0 0.0 
			}
			puts "====>Dynamic loading created..."

			# analysis objects
			# constraints Penalty 1.e12 1.e12
			# test        NormDispIncr 1.0e-3 35 1
			# algorithm   KrylovNewton
			# numberer    RCM
			# system      ProfileSPD
			# integrator  Newmark $gamma $beta
			# rayleigh    $a0 $a1 0.0 0.0
			# analysis    Transient

			# analysis objects
			constraints Transformation
			test        NormDispIncr 1e-3 35 0
			algorithm   Newton
			numberer    RCM
			system      ProfileSPD
			integrator  Newmark $gamma $beta 
			rayleigh    $a0 $a1 0.0 0.0
			analysis    Transient


			# perform analysis with timestep reduction loop
			set ok [analyze $nSteps  $dT]

			# if analysis fails, reduce timestep and continue with analysis
			if {$ok != 0} {
			    puts "did not converge, reducing time step"
			    set curTime  [getTime]
			    set mTime $curTime
			    puts "curTime: $curTime"
			    set curStep  [expr $curTime/$dT]
			    puts "curStep: $curStep"
			    set rStep  [expr ($nSteps-$curStep)*2.0]
			    set remStep  [expr int(($nSteps-$curStep)*2.0)]
			    puts "remStep: $remStep"
			    set dT       [expr $dT/2.0]
			    puts "dT: $dT"

			    set ok [analyze  $remStep  $dT]

			    # if analysis fails again, reduce timestep and continue with analysis
			    if {$ok != 0} {
			        puts "did not converge, reducing time step"
			        set curTime  [getTime]
			        puts "curTime: $curTime"
			        set curStep  [expr ($curTime-$mTime)/$dT]
			        puts "curStep: $curStep"
			        set remStep  [expr int(($rStep-$curStep)*2.0)]
			        puts "remStep: $remStep"
			        set dT       [expr $dT/2.0]
			        puts "dT: $dT"

			        analyze  $remStep  $dT
			    }
			}

			set endT    [clock seconds]
			puts "====>Finished with dynamic analysis..."
			puts "====>Analysis execution time: [expr $endT-$startT] seconds"

			wipe
		}
	}
	close $openFile

	set D [expr $D+0.1]
	set D [format "%0.1f" $D]
}