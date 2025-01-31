// megafunction wizard: %ALTCLKCTRL%
// GENERATION: STANDARD
// VERSION: WM1.0
// MODULE: altclkctrl 

// ============================================================
// File Name: vidclkcntrl.v
// Megafunction Name(s):
// 			altclkctrl
//
// Simulation Library Files(s):
// 			cycloneive
// ============================================================
// ************************************************************
// THIS IS A WIZARD-GENERATED FILE. DO NOT EDIT THIS FILE!
//
// 22.1std.1 Build 917 02/14/2023 SC Lite Edition
// ************************************************************


//Copyright (C) 2023  Intel Corporation. All rights reserved.
//Your use of Intel Corporation's design tools, logic functions 
//and other software and tools, and any partner logic 
//functions, and any output files from any of the foregoing 
//(including device programming or simulation files), and any 
//associated documentation or information are expressly subject 
//to the terms and conditions of the Intel Program License 
//Subscription Agreement, the Intel Quartus Prime License Agreement,
//the Intel FPGA IP License Agreement, or other applicable license
//agreement, including, without limitation, that your use is for
//the sole purpose of programming logic devices manufactured by
//Intel and sold by Intel or its authorized distributors.  Please
//refer to the applicable agreement for further details, at
//https://fpgasoftware.intel.com/eula.


//altclkctrl CBX_AUTO_BLACKBOX="ALL" CLOCK_TYPE="Global Clock" DEVICE_FAMILY="Cyclone IV E" ENA_REGISTER_MODE="falling edge" USE_GLITCH_FREE_SWITCH_OVER_IMPLEMENTATION="OFF" clkselect ena inclk outclk
//VERSION_BEGIN 22.1 cbx_altclkbuf 2023:02:14:18:02:23:SC cbx_cycloneii 2023:02:14:18:02:23:SC cbx_lpm_add_sub 2023:02:14:18:02:23:SC cbx_lpm_compare 2023:02:14:18:02:23:SC cbx_lpm_decode 2023:02:14:18:02:23:SC cbx_lpm_mux 2023:02:14:18:02:23:SC cbx_mgl 2023:02:14:18:15:38:SC cbx_nadder 2023:02:14:18:02:23:SC cbx_stratix 2023:02:14:18:02:23:SC cbx_stratixii 2023:02:14:18:02:23:SC cbx_stratixiii 2023:02:14:18:02:23:SC cbx_stratixv 2023:02:14:18:02:23:SC  VERSION_END
// synthesis VERILOG_INPUT_VERSION VERILOG_2001
// altera message_off 10463


//synthesis_resources = clkctrl 1 
//synopsys translate_off
`timescale 1 ps / 1 ps
//synopsys translate_on
module  vidclkcntrl_altclkctrl_7ji
	( 
	clkselect,
	ena,
	inclk,
	outclk) ;
	input   [1:0]  clkselect;
	input   ena;
	input   [3:0]  inclk;
	output   outclk;
`ifndef ALTERA_RESERVED_QIS
// synopsys translate_off
`endif
	tri0   [1:0]  clkselect;
	tri1   ena;
	tri0   [3:0]  inclk;
`ifndef ALTERA_RESERVED_QIS
// synopsys translate_on
`endif

	wire  wire_clkctrl1_outclk;
	wire  [1:0]  clkselect_wire;
	wire  [3:0]  inclk_wire;

	cycloneive_clkctrl   clkctrl1
	( 
	.clkselect(clkselect_wire),
	.ena(ena),
	.inclk(inclk_wire),
	.outclk(wire_clkctrl1_outclk)
	// synopsys translate_off
	,
	.devclrn(1'b1),
	.devpor(1'b1)
	// synopsys translate_on
	);
	defparam
		clkctrl1.clock_type = "Global Clock",
		clkctrl1.ena_register_mode = "falling edge",
		clkctrl1.lpm_type = "cycloneive_clkctrl";
	assign
		clkselect_wire = {clkselect},
		inclk_wire = {inclk},
		outclk = wire_clkctrl1_outclk;
endmodule //vidclkcntrl_altclkctrl_7ji
//VALID FILE


// synopsys translate_off
`timescale 1 ps / 1 ps
// synopsys translate_on
module vidclkcntrl (
	clkselect,
	inclk0x,
	inclk1x,
	outclk);

	input	  clkselect;
	input	  inclk0x;
	input	  inclk1x;
	output	  outclk;
`ifndef ALTERA_RESERVED_QIS
// synopsys translate_off
`endif
	tri0	  clkselect;
`ifndef ALTERA_RESERVED_QIS
// synopsys translate_on
`endif

	wire  sub_wire0;
	wire [0:0] sub_wire3 = 1'h0;
	wire  sub_wire4 = 1'h1;
	wire [1:0] sub_wire8 = 2'h0;
	wire  sub_wire7 = inclk1x;
	wire  outclk = sub_wire0;
	wire  sub_wire1 = clkselect;
	wire [1:0] sub_wire2 = {sub_wire3, sub_wire1};
	wire  sub_wire5 = inclk0x;
	wire [3:0] sub_wire6 = {sub_wire8, sub_wire7, sub_wire5};

	vidclkcntrl_altclkctrl_7ji	vidclkcntrl_altclkctrl_7ji_component (
				.clkselect (sub_wire2),
				.ena (sub_wire4),
				.inclk (sub_wire6),
				.outclk (sub_wire0));

endmodule

// ============================================================
// CNX file retrieval info
// ============================================================
// Retrieval info: PRIVATE: INTENDED_DEVICE_FAMILY STRING "Cyclone IV E"
// Retrieval info: PRIVATE: SYNTH_WRAPPER_GEN_POSTFIX STRING "0"
// Retrieval info: PRIVATE: clock_inputs NUMERIC "2"
// Retrieval info: CONSTANT: ENA_REGISTER_MODE STRING "falling edge"
// Retrieval info: CONSTANT: INTENDED_DEVICE_FAMILY STRING "Cyclone IV E"
// Retrieval info: CONSTANT: USE_GLITCH_FREE_SWITCH_OVER_IMPLEMENTATION STRING "OFF"
// Retrieval info: CONSTANT: clock_type STRING "Global Clock"
// Retrieval info: USED_PORT: clkselect 0 0 0 0 INPUT GND "clkselect"
// Retrieval info: USED_PORT: inclk0x 0 0 0 0 INPUT NODEFVAL "inclk0x"
// Retrieval info: USED_PORT: inclk1x 0 0 0 0 INPUT NODEFVAL "inclk1x"
// Retrieval info: USED_PORT: outclk 0 0 0 0 OUTPUT NODEFVAL "outclk"
// Retrieval info: CONNECT: @clkselect 0 0 1 1 GND 0 0 0 0
// Retrieval info: CONNECT: @clkselect 0 0 1 0 clkselect 0 0 0 0
// Retrieval info: CONNECT: @ena 0 0 0 0 VCC 0 0 0 0
// Retrieval info: CONNECT: @inclk 0 0 2 2 GND 0 0 2 0
// Retrieval info: CONNECT: @inclk 0 0 1 0 inclk0x 0 0 0 0
// Retrieval info: CONNECT: @inclk 0 0 1 1 inclk1x 0 0 0 0
// Retrieval info: CONNECT: outclk 0 0 0 0 @outclk 0 0 0 0
// Retrieval info: GEN_FILE: TYPE_NORMAL vidclkcntrl.v TRUE
// Retrieval info: GEN_FILE: TYPE_NORMAL vidclkcntrl.inc FALSE
// Retrieval info: GEN_FILE: TYPE_NORMAL vidclkcntrl.cmp FALSE
// Retrieval info: GEN_FILE: TYPE_NORMAL vidclkcntrl.bsf FALSE
// Retrieval info: GEN_FILE: TYPE_NORMAL vidclkcntrl_inst.v FALSE
// Retrieval info: GEN_FILE: TYPE_NORMAL vidclkcntrl_bb.v FALSE
// Retrieval info: LIB_FILE: cycloneive
