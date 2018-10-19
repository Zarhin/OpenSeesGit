# Use Spring Damping
# Define output file 
# Use pile nodes as master nodes
# dt 0.01s



# Clear all 
wipe

#---Constant Parameters
# PI
set pi [expr {asin(1)*2.0}]
# Ground Acceleration
set g [expr 9.81]

# load tcl source
source DefineNodes_2D.tcl
source DefineSoilNode_2D.tcl
source main.tcl

# Define modal analysis output file 
set output "Result/siteResponse"
if {[file exists $output]==0} {
	file mkdir $output
}

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
puts "$pi $g"