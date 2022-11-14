# TCL File Generated by Component Editor 21.1
# Fri Nov 11 22:11:03 CET 2022
# DO NOT MODIFY


# 
# ClockDivider "ClockDivider" v1.0
#  2022.11.11.22:11:03
# 
# 

# 
# request TCL package from ACDS 16.1
# 
package require -exact qsys 16.1


# 
# module ClockDivider
# 
set_module_property DESCRIPTION ""
set_module_property NAME ClockDivider
set_module_property VERSION 1.0
set_module_property INTERNAL false
set_module_property OPAQUE_ADDRESS_MAP true
set_module_property AUTHOR ""
set_module_property DISPLAY_NAME ClockDivider
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE true
set_module_property REPORT_TO_TALKBACK false
set_module_property ALLOW_GREYBOX_GENERATION false
set_module_property REPORT_HIERARCHY false


# 
# file sets
# 
add_fileset QUARTUS_SYNTH QUARTUS_SYNTH "" ""
set_fileset_property QUARTUS_SYNTH TOP_LEVEL clockdiv_avalon_interface
set_fileset_property QUARTUS_SYNTH ENABLE_RELATIVE_INCLUDE_PATHS false
set_fileset_property QUARTUS_SYNTH ENABLE_FILE_OVERWRITE_MODE true
add_fileset_file clockdiv_avalon_interface.vhd VHDL PATH clockdiv_avalon_interface.vhd TOP_LEVEL_FILE
add_fileset_file clockdiv.vhd VHDL PATH clockdiv.vhd

add_fileset SIM_VERILOG SIM_VERILOG "" ""
set_fileset_property SIM_VERILOG TOP_LEVEL clockdiv_avalon_interface
set_fileset_property SIM_VERILOG ENABLE_RELATIVE_INCLUDE_PATHS false
set_fileset_property SIM_VERILOG ENABLE_FILE_OVERWRITE_MODE true
add_fileset_file clockdiv_avalon_interface.vhd VHDL PATH clockdiv_avalon_interface.vhd
add_fileset_file clockdiv.vhd VHDL PATH clockdiv.vhd


# 
# parameters
# 


# 
# display items
# 


# 
# connection point clock
# 
add_interface clock clock end
set_interface_property clock clockRate 0
set_interface_property clock ENABLED true
set_interface_property clock EXPORT_OF ""
set_interface_property clock PORT_NAME_MAP ""
set_interface_property clock CMSIS_SVD_VARIABLES ""
set_interface_property clock SVD_ADDRESS_GROUP ""

add_interface_port clock clock clk Input 1


# 
# connection point clock_source
# 
add_interface clock_source clock start
set_interface_property clock_source associatedDirectClock ""
set_interface_property clock_source clockRate 0
set_interface_property clock_source clockRateKnown false
set_interface_property clock_source ENABLED true
set_interface_property clock_source EXPORT_OF ""
set_interface_property clock_source PORT_NAME_MAP ""
set_interface_property clock_source CMSIS_SVD_VARIABLES ""
set_interface_property clock_source SVD_ADDRESS_GROUP ""

add_interface_port clock_source enable_out clk Output 1


# 
# connection point clock_reset
# 
add_interface clock_reset reset end
set_interface_property clock_reset associatedClock clock
set_interface_property clock_reset synchronousEdges DEASSERT
set_interface_property clock_reset ENABLED true
set_interface_property clock_reset EXPORT_OF ""
set_interface_property clock_reset PORT_NAME_MAP ""
set_interface_property clock_reset CMSIS_SVD_VARIABLES ""
set_interface_property clock_reset SVD_ADDRESS_GROUP ""

add_interface_port clock_reset resetn reset_n Input 1

