set_global_assignment -entity "system" -library "lib_system" -name IP_TOOL_NAME "Qsys"
set_global_assignment -entity "system" -library "lib_system" -name IP_TOOL_VERSION "21.1"
set_global_assignment -entity "system" -library "lib_system" -name IP_TOOL_ENV "Qsys"
set_global_assignment -library "lib_system" -name SPD_FILE [file join $::quartus(sip_path) "../system.spd"]
set_global_assignment -library "lib_system" -name MISC_FILE [file join $::quartus(sip_path) "../../system.qsys"]
