onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /jpeg_encoder/encoder_clk
add wave -noupdate /jpeg_encoder/imager_clk
add wave -noupdate /jpeg_encoder/rst
add wave -noupdate /jpeg_encoder/shoot_imgr
add wave -noupdate /jpeg_encoder/ready
add wave -noupdate -radix ascii /jpeg_encoder/hex_file_name
add wave -noupdate -radix ascii /jpeg_encoder/output_hex_file_name
add wave -noupdate /jpeg_encoder/vid_type
add wave -noupdate -radix ascii /jpeg_encoder/date_string
add wave -noupdate /jpeg_encoder/print_date
add wave -noupdate /jpeg_encoder/factor_sel
add wave -noupdate /jpeg_encoder/imager_dout
add wave -noupdate /jpeg_encoder/enc_dqual
add wave -noupdate /jpeg_encoder/enc_dout
add wave -noupdate /jpeg_encoder/d_qual
add wave -noupdate /jpeg_encoder/m_cmd
add wave -noupdate /jpeg_encoder/m_be
add wave -noupdate /jpeg_encoder/s_be
add wave -noupdate /jpeg_encoder/d_inout
add wave -noupdate /jpeg_encoder/flash_d_out
add wave -noupdate /jpeg_encoder/enc_d_out
add wave -noupdate /jpeg_encoder/hd
add wave -noupdate /jpeg_encoder/vd
add wave -noupdate /jpeg_encoder/pxq
add wave -noupdate /jpeg_encoder/s_halt
add wave -noupdate /jpeg_encoder/m_halt
add wave -noupdate /jpeg_encoder/m_eof
add wave -noupdate /jpeg_encoder/err
add wave -noupdate /jpeg_encoder/s_eof
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {1358535 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ns} {2524442 ns}
