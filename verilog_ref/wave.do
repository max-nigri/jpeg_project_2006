onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -format Logic /var_fifo/clk
add wave -noupdate -format Logic /var_fifo/rst_b
add wave -noupdate -format Literal -radix unsigned /var_fifo/wr_addr
add wave -noupdate -format Literal -radix unsigned /var_fifo/rd_addr
add wave -noupdate -format Literal -radix unsigned /var_fifo/len
add wave -noupdate -color orange -format Analog-Step -radix unsigned -scale 0.25 /var_fifo/len
add wave -noupdate -format Literal -radix unsigned /var_fifo/wr_len
add wave -noupdate -format Literal -radix unsigned /var_fifo/rd_len
add wave -noupdate -format Logic /var_fifo/empty
add wave -noupdate -format Logic /var_fifo/full
add wave -noupdate -format Literal -radix hexadecimal /var_fifo/fifo_data
add wave -noupdate -format Logic /var_fifo/wr
add wave -noupdate -format Logic /var_fifo/rd
add wave -noupdate -format Logic /var_fifo/rd_req
add wave -noupdate -format Logic /var_fifo/wr_req
add wave -noupdate -format Literal /var_fifo/wr_data_aligned
add wave -noupdate -format Literal /var_fifo/wr_data_pre
add wave -noupdate -format Logic /var_fifo/wr_toggle
add wave -noupdate -format Literal /var_fifo/wr_data
add wave -noupdate -format Literal /var_fifo/wr_mask_pre
add wave -noupdate -format Literal /var_fifo/wr_en_pre
add wave -noupdate -format Literal /var_fifo/wr_en
add wave -noupdate -format Literal /var_fifo/rd_data_pre
add wave -noupdate -format Literal /var_fifo/rd_mask_pre
add wave -noupdate -format Literal /var_fifo/rd_data
add wave -noupdate -format Literal /var_fifo/i
add wave -noupdate -format Literal /var_fifo/sr
add wave -noupdate -format Literal /var_fifo/sw
add wave -noupdate -format Literal /var_fifo/read_len
add wave -noupdate -format Literal /var_fifo/write_len
add wave -noupdate -format Literal /var_fifo/read_idle
add wave -noupdate -format Literal /var_fifo/write_idle
add wave -noupdate -format Literal /var_fifo/write_i
add wave -noupdate -format Logic /var_fifo/rd_for_monitor
add wave -noupdate -format Logic /var_fifo/rd_int
add wave -noupdate -format Literal /var_fifo/ram_di
add wave -noupdate -format Literal /var_fifo/ram_do
add wave -noupdate -format Literal /var_fifo/ram_rd_addr
add wave -noupdate -format Literal /var_fifo/ram_wr_addr
add wave -noupdate -format Literal /var_fifo/write_data
add wave -noupdate -format Literal /var_fifo/read_data
add wave -noupdate -format Literal /var_fifo/exp_read_data
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {2816 ns} 0}
WaveRestoreZoom {0 ns} {6300 ns}
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
