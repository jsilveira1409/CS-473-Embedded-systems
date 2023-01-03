# TCL File Generated by Component Editor 18.1
# Tue Jan 03 17:10:58 CET 2023
# DO NOT MODIFY


# 
# lcd "lcd" v1.0
#  2023.01.03.17:10:58
# 
# 

# 
# request TCL package from ACDS 16.1
# 
package require -exact qsys 16.1


# 
# module lcd
# 
set_module_property DESCRIPTION ""
set_module_property NAME lcd
set_module_property VERSION 1.0
set_module_property INTERNAL false
set_module_property OPAQUE_ADDRESS_MAP true
set_module_property AUTHOR ""
set_module_property DISPLAY_NAME lcd
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
add_fileset_file top.vhd VHDL PATH ../hdl/top.vhd TOP_LEVEL_FILE
add_fileset_file lcd_pkg.vhd VHDL PATH ../hdl/lcd_pkg.vhd
add_fileset_file Acquisition.vhd VHDL PATH ../hdl/Acquisition.vhd
add_fileset_file fifo.vhd VHDL PATH ../hdl/fifo.vhd
add_fileset_file lcd_controller.vhd VHDL PATH ../hdl/lcd_controller.vhd


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
# connection point as
# 
add_interface as avalon end
set_interface_property as addressUnits WORDS
set_interface_property as associatedClock clock
set_interface_property as associatedReset areset_sink
set_interface_property as bitsPerSymbol 8
set_interface_property as burstOnBurstBoundariesOnly false
set_interface_property as burstcountUnits WORDS
set_interface_property as explicitAddressSpan 0
set_interface_property as holdTime 0
set_interface_property as linewrapBursts false
set_interface_property as maximumPendingReadTransactions 0
set_interface_property as maximumPendingWriteTransactions 0
set_interface_property as readLatency 0
set_interface_property as readWaitTime 1
set_interface_property as setupTime 0
set_interface_property as timingUnits Cycles
set_interface_property as writeWaitTime 0
set_interface_property as ENABLED true
set_interface_property as EXPORT_OF ""
set_interface_property as PORT_NAME_MAP ""
set_interface_property as CMSIS_SVD_VARIABLES ""
set_interface_property as SVD_ADDRESS_GROUP ""

add_interface_port as AS_Address address Input 16
add_interface_port as AS_Write write Input 1
add_interface_port as AS_Read read Input 1
add_interface_port as AS_DataRead readdata Output 32
add_interface_port as AS_DataWrite writedata Input 32
set_interface_assignment as embeddedsw.configuration.isFlash 0
set_interface_assignment as embeddedsw.configuration.isMemoryDevice 0
set_interface_assignment as embeddedsw.configuration.isNonVolatileStorage 0
set_interface_assignment as embeddedsw.configuration.isPrintableDevice 0


# 
# connection point AM
# 
add_interface AM avalon start
set_interface_property AM addressUnits SYMBOLS
set_interface_property AM associatedClock clock
set_interface_property AM associatedReset areset_sink
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
add_interface_port AM AM_Read read Output 1
add_interface_port AM AM_ReadData readdata Input 16
add_interface_port AM AM_ReadDataValid readdatavalid Input 1
add_interface_port AM AM_WaitRequest waitrequest Input 1


# 
# connection point areset_sink
# 
add_interface areset_sink reset end
set_interface_property areset_sink associatedClock clock
set_interface_property areset_sink synchronousEdges DEASSERT
set_interface_property areset_sink ENABLED true
set_interface_property areset_sink EXPORT_OF ""
set_interface_property areset_sink PORT_NAME_MAP ""
set_interface_property areset_sink CMSIS_SVD_VARIABLES ""
set_interface_property areset_sink SVD_ADDRESS_GROUP ""

add_interface_port areset_sink nReset reset Input 1


# 
# connection point output
# 
add_interface output conduit end
set_interface_property output associatedClock clock
set_interface_property output associatedReset areset_sink
set_interface_property output ENABLED true
set_interface_property output EXPORT_OF ""
set_interface_property output PORT_NAME_MAP ""
set_interface_property output CMSIS_SVD_VARIABLES ""
set_interface_property output SVD_ADDRESS_GROUP ""

add_interface_port output CSX csx Output 1
add_interface_port output DCX dcx Output 1
add_interface_port output D d Output 16
add_interface_port output RESX resx Output 1
add_interface_port output WRX wrx Output 1
add_interface_port output debug debug Output 1

