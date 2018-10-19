# --- Clear all
wipe
# --- Load usefull scrip
source DefineSoilModel_2D.tcl
# --- Constant parameters
# DefineSoilModel_2D { width {layerDepth {1.0 }} enumX {Edata { S 1.0 }} {startNodeTag 1} {startCoord {0.0 0.0}} }
set soilNodeInfo [DefineSoilModel_2D 100 {5 } 1 {1.0}]
