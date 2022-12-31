onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb_top/clk
add wave -noupdate /tb_top/nReset
add wave -noupdate /tb_top/AS_Address
add wave -noupdate /tb_top/AS_CS
add wave -noupdate /tb_top/AS_Write
add wave -noupdate /tb_top/AS_Read
add wave -noupdate /tb_top/AS_DataWrite
add wave -noupdate /tb_top/AS_DataRead
add wave -noupdate /tb_top/AM_Address
add wave -noupdate /tb_top/AM_ByteEnable
add wave -noupdate /tb_top/AM_Read
add wave -noupdate /tb_top/AM_ReadData
add wave -noupdate /tb_top/AM_ReadDataValid
add wave -noupdate /tb_top/AM_WaitRequest
add wave -noupdate /tb_top/D
add wave -noupdate /tb_top/DCX
add wave -noupdate /tb_top/WRX
add wave -noupdate /tb_top/RESX
add wave -noupdate /tb_top/CSX
add wave -noupdate /tb_top/debug_fifo_out
add wave -noupdate /tb_top/debug_lcd_state
add wave -noupdate /tb_top/debug_dma_state
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {9491477 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 151
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits us
update
WaveRestoreZoom {0 ps} {562379 ps}
