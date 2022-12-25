# TCL File Generated by Component Editor 21.1
# Sun Dec 25 18:01:53 CET 2022
# DO NOT MODIFY


# 
# lcd_component "lcd_component" v1.0
#  2022.12.25.18:01:53
# 
# 

# 
# request TCL package from ACDS 16.1
# 
package require -exact qsys 16.1


# 
# module lcd_component
# 
set_module_property DESCRIPTION ""
set_module_property NAME lcd_component
set_module_property VERSION 1.0
set_module_property INTERNAL false
set_module_property OPAQUE_ADDRESS_MAP true
set_module_property AUTHOR ""
set_module_property DISPLAY_NAME lcd_component
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE true
set_module_property REPORT_TO_TALKBACK false
set_module_property ALLOW_GREYBOX_GENERATION false
set_module_property REPORT_HIERARCHY false


# 
# file sets
# 
add_fileset QUARTUS_SYNTH QUARTUS_SYNTH "" ""
set_fileset_property QUARTUS_SYNTH TOP_LEVEL top
set_fileset_property QUARTUS_SYNTH ENABLE_RELATIVE_INCLUDE_PATHS false
set_fileset_property QUARTUS_SYNTH ENABLE_FILE_OVERWRITE_MODE false
add_fileset_file top.vhd VHDL PATH ../hdl/top.vhd
add_fileset_file lcd_pkg.vhd VHDL PATH ../hdl/lcd_pkg.vhd


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

add_interface_port clock clk clk Input 1


# 
# connection point conduit_end
# 
add_interface conduit_end conduit end
set_interface_property conduit_end associatedClock clock
set_interface_property conduit_end associatedReset reset_sink
set_interface_property conduit_end ENABLED true
set_interface_property conduit_end EXPORT_OF ""
set_interface_property conduit_end PORT_NAME_MAP ""
set_interface_property conduit_end CMSIS_SVD_VARIABLES ""
set_interface_property conduit_end SVD_ADDRESS_GROUP ""

add_interface_port conduit_end CSX new_signal Output 1
add_interface_port conduit_end D new_signal_1 Output 16
add_interface_port conduit_end DCX new_signal_2 Output 1
add_interface_port conduit_end RESX new_signal_3 Output 1
add_interface_port conduit_end WRX new_signal_4 Output 1


# 
# connection point reset_sink
# 
add_interface reset_sink reset end
set_interface_property reset_sink associatedClock clock
set_interface_property reset_sink synchronousEdges DEASSERT
set_interface_property reset_sink ENABLED true
set_interface_property reset_sink EXPORT_OF ""
set_interface_property reset_sink PORT_NAME_MAP ""
set_interface_property reset_sink CMSIS_SVD_VARIABLES ""
set_interface_property reset_sink SVD_ADDRESS_GROUP ""

add_interface_port reset_sink nReset reset_n Input 1


# 
# connection point AS
# 
add_interface AS avalon end
set_interface_property AS addressUnits WORDS
set_interface_property AS associatedClock clock
set_interface_property AS associatedReset reset_sink
set_interface_property AS bitsPerSymbol 8
set_interface_property AS burstOnBurstBoundariesOnly false
set_interface_property AS burstcountUnits WORDS
set_interface_property AS explicitAddressSpan 0
set_interface_property AS holdTime 0
set_interface_property AS linewrapBursts false
set_interface_property AS maximumPendingReadTransactions 0
set_interface_property AS maximumPendingWriteTransactions 0
set_interface_property AS readLatency 0
set_interface_property AS readWaitTime 1
set_interface_property AS setupTime 0
set_interface_property AS timingUnits Cycles
set_interface_property AS writeWaitTime 0
set_interface_property AS ENABLED true
set_interface_property AS EXPORT_OF ""
set_interface_property AS PORT_NAME_MAP ""
set_interface_property AS CMSIS_SVD_VARIABLES ""
set_interface_property AS SVD_ADDRESS_GROUP ""

add_interface_port AS AS_Address address Input 1
add_interface_port AS AS_Write write Input 1
add_interface_port AS AS_Read read Input 1
add_interface_port AS AS_CS chipselect Input 1
add_interface_port AS AS_DataRead readdata Output 32
add_interface_port AS AS_DataWrite writedata Input 32
add_interface_port AS tmp_imagedone address Input 1
set_interface_assignment AS embeddedsw.configuration.isFlash 0
set_interface_assignment AS embeddedsw.configuration.isMemoryDevice 0
set_interface_assignment AS embeddedsw.configuration.isNonVolatileStorage 0
set_interface_assignment AS embeddedsw.configuration.isPrintableDevice 0


# 
# connection point AM
# 
add_interface AM avalon start
set_interface_property AM addressUnits SYMBOLS
set_interface_property AM associatedClock clock
set_interface_property AM associatedReset reset_sink
set_interface_property AM bitsPerSymbol 8
set_interface_property AM burstOnBurstBoundariesOnly false
set_interface_property AM burstcountUnits WORDS
set_interface_property AM doStreamReads false
set_interface_property AM doStreamWrites false
set_interface_property AM holdTime 0
set_interface_property AM linewrapBursts false
set_interface_property AM maximumPendingReadTransactions 0
set_interface_property AM maximumPendingWriteTransactions 0
set_interface_property AM readLatency 0
set_interface_property AM readWaitTime 1
set_interface_property AM setupTime 0
set_interface_property AM timingUnits Cycles
set_interface_property AM writeWaitTime 0
set_interface_property AM ENABLED true
set_interface_property AM EXPORT_OF ""
set_interface_property AM PORT_NAME_MAP ""
set_interface_property AM CMSIS_SVD_VARIABLES ""
set_interface_property AM SVD_ADDRESS_GROUP ""

add_interface_port AM AM_Address address Output 32
add_interface_port AM AM_ByteEnable byteenable Output 1
add_interface_port AM AM_Read read Output 1
add_interface_port AM AM_ReadData readdata Input 8
add_interface_port AM AM_ReadDataValid readdatavalid Input 1
add_interface_port AM AM_WaitRequest waitrequest Input 1

