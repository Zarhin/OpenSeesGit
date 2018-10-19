# 说明：
# cu：不排水抗剪强度（kPa）
# D： 桩直径（m）
# r： 有效重度（kN/m^3)
# J： 无量纲经验系数（软粘土0.5；中等粘土0.25）
# z： 深度（m）
# effeLength: 节点有效长度(m)
proc get_pyParam_clay {cu D r nodeNum e50 J effeLength} \
{
  set pi [expr asin(1)*2];
  # Deep
  set z [expr {0.0-[nodeCoord $nodeNum 2]}]
  # Define ultimate capacity of the p-y material per unit area (Pa)
  set pu(1) [expr {(3.0+$r*$z/$cu+$J*$z/$D)*$cu*$D}]
  set pu(2) [expr 9.0*$cu*$D]
  # pu is the minimal item of pu(1) and pu(2)
  if {$pu(1)<$pu(2)} {
    set puu $pu(1)
  } else {
    set puu $pu(2)
  }
  # Define ultimate capacity of the p-y material (N)
  set pult [expr $puu*$effeLength*$D]
  # compute y50 (m)
  set y50 [expr 2.5*$e50*$D]
  set outResult [concat $pult $y50]
}
##########################################################
#                                                         #
# Procedure to compute ultimate lateral resistance, p_u,  #
#  and displacement at 50% of lateral capacity, y50, for  #
#  p-y springs representing cohesionless soil.            #
#                                                         #
#   Created by:   Hyung-suk Shin                          #
#                 University of Washington                #
#   Modified by:  Chris McGann                            #
#                 Pedro Arduino                           #
#                 Peter Mackenzie-Helnwein                #
#                 University of Washington                #
#                                                         #
###########################################################

# references
#  American Petroleum Institute (API) (1987). Recommended Practice for Planning, Designing and
#   Constructing Fixed Offshore Platforms. API Recommended Practice 2A(RP-2A), Washington D.C,
#   17th edition.
#
# Brinch Hansen, J. (1961). 鈥淭he ultimate resistance of rigid piles against transversal forces.鈥?#  Bulletin No. 12, Geoteknisk Institute, Copenhagen, 59.
#
#  Boulanger, R. W., Kutter, B. L., Brandenberg, S. J., Singh, P., and Chang, D. (2003). Pile 
#   Foundations in liquefied and laterally spreading ground during earthquakes: Centrifuge experiments
#   and analyses. Center for Geotechnical Modeling, University of California at Davis, Davis, CA.
#   Rep. UCD/CGM-03/01.
#
#  Reese, L.C. and Van Impe, W.F. (2001), Single Piles and Pile Groups Under Lateral Loading.
#    A.A. Balkema, Rotterdam, Netherlands.

proc get_pyParam_sand { nodeNum gamma phiDegree b effeLength puSwitch kSwitch gwtSwitch } {

################################################
#### pyDepth   : 当前节点到桩底的深度(m)     ####
#### gamma     : 土单位重度(kN/m^3)         ####
#### phiDegree : 土内摩擦角(degrees)        ####
#### b         : 直径(m)                    ####
#### pElelength: 单元长度(m)                ####
#### puSwitch  : py曲线依据参数             ####
#### kSwitch   :                           ####
#### gwtSwitch :                           ####
###############################################

#----------------------------------------------------------
#  define ultimate lateral resistance, pult 
#----------------------------------------------------------

# pult is defined per API recommendations (Reese and Van Impe, 2001 or API, 1987) for puSwitch = 1
#  OR per the method of Brinch Hansen (1961) for puSwitch = 2

set pi [expr asin(1)*2.0]
set phi  [expr $phiDegree*($pi/180)]
# Define the ratio of depth and diameter
set z [nodeCoord $nodeNum 2]
set z [expr 0.0-$z]
set zbRatio [expr $z/$b]   ; # 高深比
#-------API recommended method-------
if {$puSwitch == 1} {

  # obtain loading-type coefficient A for given depth-to-diameter ratio zb
  #  ---> values are obtained from a figure and are therefore approximate
    set zb(1)     0
    set zb(2)     0.1250
    set zb(3)     0.2500
    set zb(4)     0.3750
    set zb(5)     0.5000
    set zb(6)     0.6250
    set zb(7)     0.7500
    set zb(8)     0.8750
    set zb(9)     1.0000
    set zb(10)    1.1250
    set zb(11)    1.2500
    set zb(12)    1.3750
    set zb(13)    1.5000
    set zb(14)    1.6250
    set zb(15)    1.7500
    set zb(16)    1.8750
    set zb(17)    2.0000
    set zb(18)    2.1250
    set zb(19)    2.2500
    set zb(20)    2.3750
    set zb(21)    2.5000
    set zb(22)    2.6250
    set zb(23)    2.7500
    set zb(24)    2.8750
    set zb(25)    3.0000
    set zb(26)    3.1250
    set zb(27)    3.2500
    set zb(28)    3.3750
    set zb(29)    3.5000
    set zb(30)    3.6250
    set zb(31)    3.7500
    set zb(32)    3.8750
    set zb(33)    4.0000
    set zb(34)    4.1250
    set zb(35)    4.2500
    set zb(36)    4.3750
    set zb(37)    4.5000
    set zb(38)    4.6250
    set zb(39)    4.7500
    set zb(40)    4.8750
    set zb(41)    5.0000
    
    set As(1)     2.8460
    set As(2)     2.7105
    set As(3)     2.6242
    set As(4)     2.5257
    set As(5)     2.4271
    set As(6)     2.3409
    set As(7)     2.2546
    set As(8)     2.1437
    set As(9)     2.0575
    set As(10)    1.9589
    set As(11)    1.8973
    set As(12)    1.8111
    set As(13)    1.7372
    set As(14)    1.6632
    set As(15)    1.5893
    set As(16)    1.5277
    set As(17)    1.4415
    set As(18)    1.3799
    set As(19)    1.3368
    set As(20)    1.2690
    set As(21)    1.2074
    set As(22)    1.1581
    set As(23)    1.1211
    set As(24)    1.0780
    set As(25)    1.0349
    set As(26)    1.0164
    set As(27)    0.9979
    set As(28)    0.9733
    set As(29)    0.9610
    set As(30)    0.9487
    set As(31)    0.9363
    set As(32)    0.9117
    set As(33)    0.8994
    set As(34)    0.8994
    set As(35)    0.8871
    set As(36)    0.8871
    set As(37)    0.8809
    set As(38)    0.8809
    set As(39)    0.8809
    set As(40)    0.8809
    set As(41)    0.8809
    
    set dataNum 41
    
  # linear interpolation to define A for intermediate values of depth:diameter ratio
    for {set i 1} {$i <= [expr $dataNum-1] } {incr i} {
        if { ($zb($i) <= $zbRatio)  && ($zbRatio <= $zb([expr $i+1])) } {
            set A  [expr {($As([expr $i+1])-$As($i))/($zb([expr $i+1])-$zb($i))*($zbRatio-$zb($i))+$As($i)}]
        } elseif { $zbRatio >= 5} {
            set A  0.88
        }
    }

  # define common terms
    set alpha [expr {$phi/2.0}]
    set beta  [expr {$pi/4.0 + $phi/2.0}]
    set K0    0.4
    set Ka    [expr {pow(tan([expr $pi/4.0 - $phi/2.0]),2)}]; 

  # terms for Equation (3.44), Reese and Van Impe (2001)
    set c1    [expr {$K0*tan($phi)*sin($beta)/(tan([expr $beta-$phi])*cos($alpha))}]
    set c2    [expr {tan($beta)/tan([expr $beta-$phi])*tan($beta)*tan($alpha)}]
    set c3    [expr {$K0*tan($beta)*(tan($phi)*sin($beta)-tan($alpha))}]
    set c4    [expr {tan($beta)/tan([expr $beta-$phi])-$Ka}]

  # terms for Equation (3.45), Reese and Van Impe (2001)
    set c5    [expr {$Ka*(pow(tan($beta),8)-1)}]
    set c6    [expr {$K0*tan($phi)*pow(tan($beta),4)}]

  # Equation (3.44), Reese and Van Impe (2001)
    set pst   [expr $gamma*$z*($z*($c1+$c2+$c3) + $b*$c4)]

  # Equation (3.45), Reese and Van Impe (2001)
    set psd   [expr $b*$gamma*$z*($c5+$c6)]

  # pult is the lesser of pst and psd. At surface, an arbitrary value is defined
    if {$pst <= $psd} {

        if { $z == 0} {set pu 0.01} else {set pu [expr $A*$pst] }

    } else {

        set pu [expr $A*$psd]
  }
  # PySimple1 material formulated with pult as a force, not force/length, multiply by trib. length
    set pult [expr $pu*$effeLength]

#-------Brinch Hansen method-------
} elseif { $puSwitch == 2} {

  # pressure at ground surface
    set Kqo [expr exp(($pi/2+$phi)*tan($phi))*cos($phi)*tan($pi/4+$phi/2)-exp(-($pi/2-$phi)*tan($phi))*cos($phi)*tan($pi/4-$phi/2)]
    set Kco [expr (1/tan($phi))*(exp(($pi/2 + $phi)*tan($phi))*cos($phi)*tan($pi/4 + $phi/2) - 1)]

  # pressure at great depth
    set dcinf [expr 1.58 + 4.09*(pow(tan($phi),4))]
    set Nc    [expr (1/tan($phi))*(exp($pi*tan($phi)))*(pow(tan($pi/4 + $phi/2),2) - 1)]
    set Ko    [expr 1 - sin($phi)]
    set Kcinf [expr $Nc*$dcinf]
    set Kqinf [expr $Kcinf*$Ko*tan($phi)]

  # pressure at an arbitrary depth
    set aq  [expr ($Kqo/($Kqinf - $Kqo))*($Ko*sin($phi)/sin($pi/4 + $phi/2))]
    set KqD [expr ($Kqo + $Kqinf*$aq*$zbRatio)/(1 + $aq*$zbRatio)]

  # ultimate lateral resistance
    if { $z == 0 } { 
        set pu  0.01
    } else {
        set pu  [expr $gamma*$z*$KqD*$b]
    }

  # PySimple1 material formulated with pult as a force, not force/length, multiply by trib. length
    set pult [expr $pu*$effeLength]
}

#----------------------------------------------------------
#  define displacement at 50% lateral capacity, y50
#----------------------------------------------------------

# values of y50 depend of the coefficent of subgrade reaction, k, which can be defined in several ways.
#  for gwtSwitch = 1, k reflects soil above the groundwater table
#  for gwtSwitch = 2, k reflects soil below the groundwater table
#  a linear variation of k with depth is defined for kSwitch = 1 after API (1987)
#  a parabolic variation of k with depth is defined for kSwitch = 2 after Boulanger et al. (2003)

# API (1987) recommended subgrade modulus for given friction angle, values obtained from figure (approximate)
set ph(1)   28.8  
set ph(2)   29.5  
set ph(3)   30.0   
set ph(4)   31.0   
set ph(5)   32.0    
set ph(6)   33.0    
set ph(7)   34.0 
set ph(8)   35.0   
set ph(9)   36.0   
set ph(10)    37.0   
set ph(11)    38.0   
set ph(12)    39.0  
set ph(13)    40.0

# subgrade modulus above the water table
if {$gwtSwitch == 1} {
   # units of k are lb/in^3
    set k(1)     10
    set k(2)     23
    set k(3)     45
    set k(4)     61
    set k(5)     80
    set k(6)     100
    set k(7)     120
    set k(8)     140
    set k(9)     160
    set k(10)    182
    set k(11)    215
    set k(12)    250
    set k(13)    275

# subgrade modulus below the water table
} else {
   # units of k are lb/in^3
    set k(1)     10
    set k(2)     20
    set k(3)     33
    set k(4)     42
    set k(5)     50
    set k(6)     60
    set k(7)     70
    set k(8)     85
    set k(9)     95
    set k(10)    107
    set k(11)    122
    set k(12)    141
    set k(13)    155
}

set dataNum 13

# linear interpolation for values of phi not represented above
for {set i 1} {$i <= [expr $dataNum-1] } {incr i} {

    if { ( $ph($i) <= $phiDegree )  && ($phiDegree <= $ph([expr $i+1])) } {

        set khat [expr {($k([expr $i+1])-$k($i))/($ph([expr $i+1])-$ph($i))*($phiDegree - $ph($i)) + $k($i)}]
    }
}

# change units from (lb/in^3) to (kN/m^3)
set k_SIunits [expr $khat*271.45]

# define parabolic distribution of k with depth if desired (i.e. lin_par switch == 2)
set sigV [expr $z*$gamma]

if { $sigV == 0} {
    set sigV 0.01
}

if { $kSwitch == 2 } {
   # Equation (5-16), Boulanger et al. (2003)
    set cSigma [expr {pow(50/$sigV,0.5)}]
   # Equation (5-15), Boulanger et al. (2003)
    set k_SIunits [expr {$cSigma*$k_SIunits}]
}

# define y50 based on pult and subgrade modulus k

# based on API (1987) recommendations, p-y curves are described using tanh functions.
#  tcl does not have the atanh function, so must define this specifically

#  i.e.  atanh(x) = 1/2*ln((1+x)/(1-x)), |x| < 1

# when half of full resistance has been mobilized, p(y50)/pult = 0.5
    set x 0.5
    set atanh_value [expr {0.5*log((1+$x)/(1-$x))}]

# need to be careful at ground surface (don't want to divide by zero)
if { $z == 0.0} {
    set z 0.01
}

# compute y50 (need to use pult in units of force/length, and also divide out the coeff. A)
set y50  [expr {0.5*($pu/$A)/($k_SIunits*$z)*$atanh_value} ]

# return pult and y50 parameters
set outResult [concat $pult $y50]

return $outResult

}
# 说明：
# cu ：土体不排水抗剪强度(kPa)
# D  ：桩体直径(m)
# sigV：有效的上覆压力（kPa）
# effeLength：桩单元长度（m）
proc get_tzParam_clay {cu D sigV effeLength } \
{
  # According to the API norm：f=ac
  set pi [expr asin(1)*2]
  # if z = 0 (ground surface) need to specify a small non-zero value of sigV
    if { $sigV == 0.0 } {
        set sigV 0.001
    }
    set psi [expr $cu/$sigV]
    # calculate the factor: alpha
    if {$psi<=1.0} {
      set alpha [expr {0.5*pow($psi,-0.5)}]     
    } else {
      set alpha [expr {0.5*pow($psi,-0.25)}] 
    }
  # constraint，alpha<1.0
  if {$alpha>1.0} {
    set alpha 1.0
  }
  # Calculate the frictional force per unit length (N/m)
  set tu [expr $alpha*$cu*$pi*$D]
  # Calculate the tult (N)
  set tult [expr $tu*$effeLength]
  # Calculate the Z50=0.0031*$D, According to API norm（m）
  set z50 [expr 0.0031*$D]
  # return values of tult and z50 for use in t-z material
  set outResult [concat $tult $z50]

  return $outResult
}
###########################################################
#                                                         #
# Procedure to compute ultimate resistance, tult, and     #
#  displacement at 50% mobilization of tult, z50, for     #
#  use in t-z curves for cohesionless soil.               #
#                                                         #
#   Created by:  Chris McGann                             #
#                University of Washington                 #
#                                                         #
###########################################################

proc get_tzParam_sand { phi b sigV pEleLength } \
{

# references
#  Mosher, R.L. (1984). “Load transfer criteria for numerical analysis of
#   axial loaded piles in sand.” U.S. Army Engineering and Waterways
#   Experimental Station, Automatic Data Processing Center, Vicksburg, Miss.
#
#  Kulhawy, F.H. (1991). "Drilled shaft foundations." Foundation engineering
#   handbook, 2nd Ed., Chap 14, H.-Y. Fang ed., Van Nostrand Reinhold, New York

    set pi [expr asin(1)*2.0]
    
  # Compute tult based on tult = Ko*sigV*pi*dia*tan(delta), where
  #   Ko    is coeff. of lateral earth pressure at rest, 
  #         taken as Ko = 0.4
  #   delta is interface friction between soil and pile,
  #         taken as delta = 0.8*phi to be representative of a 
  #         smooth precast concrete pile after Kulhawy (1991)
    set delta [expr {0.8*$phi*$pi/180}]

  # if z = 0 (ground surface) need to specify a small non-zero value of sigV
    if { $sigV == 0.0 } {
        set sigV 0.01
    }

    set tu   [expr {0.4*$sigV*$pi*$b*tan($delta)}]
    
  # TzSimple1 material formulated with tult as force, not stress, multiply by tributary length of pile
    set tult [expr $tu*$pEleLength]

  # Mosher (1984) provides recommended initial tangents based on friction angle
  # values are in units of psf/in
    set kf(1)    6000 
    set kf(2)    10000
    set kf(3)    10000
    set kf(4)    14000
    set kf(5)    14000
    set kf(6)    18000

    set fric(1)  28
    set fric(2)  31
    set fric(3)  32
    set fric(4)  34
    set fric(5)  35
    set fric(6)  38

    set dataNum  6

  # determine kf for input value of phi, linear interpolation for intermediate values
    if { $phi < $fric(1) } {
        set k $kf(1)
    } elseif { $phi > $fric(6) } {
        set k $kf(6)
    } else {
        for {set i 1} {$i <= [expr $dataNum-1] } {incr i} {
            if { ($fric($i) <= $phi) && ($phi <= $fric([expr $i+1])) } {
                set k [expr {($kf([expr $i+1]) - $kf($i))/($fric([expr $i+1]) - $fric($i))*($phi - $fric($i)) + $kf($i)}]
            } 
        }
    }

  # need to convert kf to units of kN/m^3
    set kSIunits [expr $k*1.885]

  # based on a t-z curve of the shape recommended by Mosher (1984), z50 = tult/kf
    set z50 [expr {$tult/$kSIunits}]

  # return values of tult and z50 for use in t-z material
    set outResult [concat $tult $z50]

    return $outResult
}
# 说明：
# cu：不排水抗剪强度(kPa)
# D： 直径(m)
proc get_qzParam_clay {cu D } \
{
  set pi [expr asin(1)*2]
  # unit end bearing capacity (kPa)
  set q [expr 9.0*$cu]
  # Ultimate capacity of the q-z material (N)
  set qult [expr $q*$pi*pow($D,2)/4.0]
  # calculate z50=0.013*D (m)
  set z50 [expr 0.013*$D]
  # return values of qult and z50
  set outResult [concat $qult $z50]

  return $outResult
}
###########################################################
#                                                         #
# Procedure to compute ultimate tip resistance, qult, and #
#  displacement at 50% mobilization of qult, z50, for     #
#  use in q-z curves for cohesionless soil.               #
#                                                         #
#   Created by:  Chris McGann                             #
#                Pedro Arduino                            #
#                University of Washington                 #
#                                                         #
###########################################################

# references
#  Meyerhof G.G. (1976). "Bearing capacity and settlement of pile foundations." 
#   J. Geotech. Eng. Div., ASCE, 102(3), 195-228.
#
#  Vijayvergiya, V.N. (1977). “Load-movement characteristics of piles.”
#   Proc., Ports 77 Conf., ASCE, New York.
#
#  Kulhawy, F.H. ad Mayne, P.W. (1990). Manual on Estimating Soil Properties for 
#   Foundation Design. Electrical Power Research Institute. EPRI EL-6800, 
#   Project 1493-6 Final Report.

proc get_qzParam_sand { phiDegree b sigV G } {

  # define required constants; pi, atmospheric pressure (kPa), pa, and coeff. of lat earth pressure, Ko
    set pi [expr asin(1)*2]
    set pa 101
    set phi [expr {$phiDegree*$pi/180}]
    set Ko [expr {1 - sin($phi)}]

  # ultimate tip pressure can be computed by qult = Nq*sigV after Meyerhof (1976)
  #  where Nq is a bearing capacity factor, phi is friction angle, and sigV is eff. overburden
  #  stress at the pile tip.

  # rigidity index
    set Ir  [expr {$G/($sigV*tan($phi))}]
  # bearing capacity factor
    set Nq  [expr {(1+2*$Ko)*(1/(3-sin($phi)))*exp($pi/2-$phi)*(pow(tan($pi/4+$phi/2),2))*(pow($Ir,(4*sin($phi))/(3*(1+sin($phi)))))}]
  # tip resistance
    set qu  [expr {$Nq*$sigV}]
  # QzSimple1 material formulated with qult as force, not stress, multiply by area of pile tip
    set qult [expr {$qu*$pi*pow($b,2)/4}]

  # the q-z curve of Vijayvergiya (1977) has the form, q(z) = qult*(z/zc)^(1/3)
  #  where zc is critical tip deflection given as ranging from 3-9% of the
  #  pile diameter at the tip.  

  # assume zc is 5% of pile diameter
    set zc [expr 0.05*$b]

  # based on Vijayvergiya (1977) curve, z50 = 0.125*zc
    set z50 [expr 0.125*$zc]

  # return values of qult and z50 for use in q-z material
    set outResult [concat $qult $z50]

    return $outResult
}
