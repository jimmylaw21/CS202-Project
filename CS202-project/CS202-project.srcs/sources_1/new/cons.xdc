## Clock Signal
## The input clock signal is connected to pin E3 on the FPGA
## The frequency is set to 100 MHz
set_property -dict { PACKAGE_PIN Y18 IOSTANDARD LVCMOS33 } [get_ports pclk]
set_property -dict { PACKAGE_PIN P4 IOSTANDARD LVCMOS33 } [get_ports reset]
set_property -dict { PACKAGE_PIN AA6 IOSTANDARD LVCMOS33 } [get_ports selectInput]
set_property -dict { PACKAGE_PIN P1 IOSTANDARD LVCMOS33 } [get_ports commucation_mode]
set_property -dict { PACKAGE_PIN R1 IOSTANDARD LVCMOS33 } [get_ports working_mode]


set_property -dict { PACKAGE_PIN W4 IOSTANDARD LVCMOS33 } [get_ports {ioread_data_switch[0]}]
set_property -dict { PACKAGE_PIN R4 IOSTANDARD LVCMOS33 } [get_ports {ioread_data_switch[1]}]
set_property -dict { PACKAGE_PIN T4 IOSTANDARD LVCMOS33 } [get_ports {ioread_data_switch[2]}]
set_property -dict { PACKAGE_PIN T5 IOSTANDARD LVCMOS33 } [get_ports {ioread_data_switch[3]}]
set_property -dict { PACKAGE_PIN U5 IOSTANDARD LVCMOS33 } [get_ports {ioread_data_switch[4]}]
set_property -dict { PACKAGE_PIN W6 IOSTANDARD LVCMOS33 } [get_ports {ioread_data_switch[5]}]
set_property -dict { PACKAGE_PIN W5 IOSTANDARD LVCMOS33 } [get_ports {ioread_data_switch[6]}]
set_property -dict { PACKAGE_PIN U6 IOSTANDARD LVCMOS33 } [get_ports {ioread_data_switch[7]}]
set_property -dict { PACKAGE_PIN V5 IOSTANDARD LVCMOS33 } [get_ports {ioread_data_switch[8]}]
set_property -dict { PACKAGE_PIN R6 IOSTANDARD LVCMOS33 } [get_ports {ioread_data_switch[9]}]
set_property -dict { PACKAGE_PIN T6 IOSTANDARD LVCMOS33 } [get_ports {ioread_data_switch[10]}]
set_property -dict { PACKAGE_PIN Y6 IOSTANDARD LVCMOS33 } [get_ports {ioread_data_switch[11]}]


set_property -dict { PACKAGE_PIN C19 IOSTANDARD LVCMOS33 } [get_ports {seg_enables[0]}]
set_property -dict { PACKAGE_PIN E19 IOSTANDARD LVCMOS33 } [get_ports {seg_enables[1]}]
set_property -dict { PACKAGE_PIN D19 IOSTANDARD LVCMOS33 } [get_ports {seg_enables[2]}]
set_property -dict { PACKAGE_PIN F18 IOSTANDARD LVCMOS33 } [get_ports {seg_enables[3]}]
set_property -dict { PACKAGE_PIN E18 IOSTANDARD LVCMOS33 } [get_ports {seg_enables[4]}]
set_property -dict { PACKAGE_PIN B20 IOSTANDARD LVCMOS33 } [get_ports {seg_enables[5]}]
set_property -dict { PACKAGE_PIN A20 IOSTANDARD LVCMOS33 } [get_ports {seg_enables[6]}]
set_property -dict { PACKAGE_PIN A18 IOSTANDARD LVCMOS33 } [get_ports {seg_enables[7]}]


## 7-segment Display
## The 7-segment display is connected to the FPGA pins D0-D6
set_property -dict { PACKAGE_PIN F15 IOSTANDARD LVCMOS33 } [get_ports {segs[0]}]
set_property -dict { PACKAGE_PIN F13 IOSTANDARD LVCMOS33 } [get_ports {segs[1]}]
set_property -dict { PACKAGE_PIN F14 IOSTANDARD LVCMOS33 } [get_ports {segs[2]}]
set_property -dict { PACKAGE_PIN F16 IOSTANDARD LVCMOS33 } [get_ports {segs[3]}]
set_property -dict { PACKAGE_PIN E17 IOSTANDARD LVCMOS33 } [get_ports {segs[4]}]
set_property -dict { PACKAGE_PIN C14 IOSTANDARD LVCMOS33 } [get_ports {segs[5]}]
set_property -dict { PACKAGE_PIN C15 IOSTANDARD LVCMOS33 } [get_ports {segs[6]}]

set_property -dict { PACKAGE_PIN A21 IOSTANDARD LVCMOS33 } [get_ports {leds[0]}]
set_property -dict { PACKAGE_PIN E22 IOSTANDARD LVCMOS33 } [get_ports {leds[1]}]
set_property -dict { PACKAGE_PIN D22 IOSTANDARD LVCMOS33 } [get_ports {leds[2]}]
set_property -dict { PACKAGE_PIN E21 IOSTANDARD LVCMOS33 } [get_ports {leds[3]}]
set_property -dict { PACKAGE_PIN D21 IOSTANDARD LVCMOS33 } [get_ports {leds[4]}]
set_property -dict { PACKAGE_PIN G21 IOSTANDARD LVCMOS33 } [get_ports {leds[5]}]
set_property -dict { PACKAGE_PIN C22 IOSTANDARD LVCMOS33 } [get_ports {leds[6]}]
set_property -dict { PACKAGE_PIN F21 IOSTANDARD LVCMOS33 } [get_ports {leds[7]}]
set_property -dict { PACKAGE_PIN J17 IOSTANDARD LVCMOS33 } [get_ports {leds[8]}]
set_property -dict { PACKAGE_PIN L14 IOSTANDARD LVCMOS33 } [get_ports {leds[9]}]
set_property -dict { PACKAGE_PIN L15 IOSTANDARD LVCMOS33 } [get_ports {leds[10]}]
set_property -dict { PACKAGE_PIN L16 IOSTANDARD LVCMOS33 } [get_ports {leds[11]}]

set_property -dict { PACKAGE_PIN KP1 IOSTANDARD LVCMOS33 } [get_ports {key_row[0]}]
set_property -dict { PACKAGE_PIN KP2 IOSTANDARD LVCMOS33 } [get_ports {key_row[1]}]
set_property -dict { PACKAGE_PIN KP3 IOSTANDARD LVCMOS33 } [get_ports {key_row[2]}]
set_property -dict { PACKAGE_PIN KP4 IOSTANDARD LVCMOS33 } [get_ports {key_row[3]}]

set_property -dict { PACKAGE_PIN KP5 IOSTANDARD LVCMOS33 } [get_ports {key_col[0]}]
set_property -dict { PACKAGE_PIN KP6 IOSTANDARD LVCMOS33 } [get_ports {key_col[1]}]
set_property -dict { PACKAGE_PIN KP7 IOSTANDARD LVCMOS33 } [get_ports {key_col[2]}]
set_property -dict { PACKAGE_PIN KP8 IOSTANDARD LVCMOS33 } [get_ports {key_col[3]}]