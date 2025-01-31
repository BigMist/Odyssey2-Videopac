// FPGA Videopac
//-----------------------------------------------------------------------------
//
// Copyright (c) 2007, Arnim Laeuger (arnim.laeuger@gmx.net)
//
// All rights reserved
//
// Redistribution and use in source and synthezised forms, with or without
// modification, are permitted provided that the following conditions are met:
//
// Redistributions of source code must retain the above copyright notice,
// this list of conditions and the following disclaimer.
//
// Redistributions in synthesized form must reproduce the above copyright
// notice, this list of conditions and the following disclaimer in the
// documentation and/or other materials provided with the distribution.
//
// Neither the name of the author nor the names of other contributors may
// be used to endorse or promote products derived from this software without
// specific prior written permission.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
// THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
// PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE
// LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
// CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
// SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
// INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
// CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
// ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
// POSSIBILITY OF SUCH DAMAGE.
//
// Please report bugs to the author, but before you do so, please
// make sure that this is not a derivative work and that
// you have the latest version of this file.
//
// Based off MiST port by wsoltys in 2014.
//
// Adapted for MiSTer by Kitrinx in 2018
// Bug fixes and new features added by The spanish videopac team in 2021
`default_nettype none

module guest_top
(
	input         CLOCK_27,
`ifdef USE_CLOCK_50
	input         CLOCK_50,
`endif

	output        LED,
	output [VGA_BITS-1:0] VGA_R,
	output [VGA_BITS-1:0] VGA_G,
	output [VGA_BITS-1:0] VGA_B,
	output        VGA_HS,
	output        VGA_VS,

`ifdef USE_HDMI
	output        HDMI_RST,
	output  [7:0] HDMI_R,
	output  [7:0] HDMI_G,
	output  [7:0] HDMI_B,
	output        HDMI_HS,
	output        HDMI_VS,
	output        HDMI_PCLK,
	output        HDMI_DE,
	inout         HDMI_SDA,
	inout         HDMI_SCL,
	input         HDMI_INT,
`endif

	input         SPI_SCK,
	inout         SPI_DO,
	input         SPI_DI,
	input         SPI_SS2,    // data_io
	input         SPI_SS3,    // OSD
	input         CONF_DATA0, // SPI_SS for user_io

`ifdef USE_QSPI
	input         QSCK,
	input         QCSn,
	inout   [3:0] QDAT,
`endif
`ifndef NO_DIRECT_UPLOAD
	input         SPI_SS4,
`endif

	output [12:0] SDRAM_A,
	inout  [15:0] SDRAM_DQ,
	output        SDRAM_DQML,
	output        SDRAM_DQMH,
	output        SDRAM_nWE,
	output        SDRAM_nCAS,
	output        SDRAM_nRAS,
	output        SDRAM_nCS,
	output  [1:0] SDRAM_BA,
	output        SDRAM_CLK,
	output        SDRAM_CKE,

`ifdef DUAL_SDRAM
	output [12:0] SDRAM2_A,
	inout  [15:0] SDRAM2_DQ,
	output        SDRAM2_DQML,
	output        SDRAM2_DQMH,
	output        SDRAM2_nWE,
	output        SDRAM2_nCAS,
	output        SDRAM2_nRAS,
	output        SDRAM2_nCS,
	output  [1:0] SDRAM2_BA,
	output        SDRAM2_CLK,
	output        SDRAM2_CKE,
`endif

	output        AUDIO_L,
	output        AUDIO_R,
`ifdef I2S_AUDIO
	output        I2S_BCK,
	output        I2S_LRCK,
	output        I2S_DATA,
`endif
`ifdef I2S_AUDIO_HDMI
	output        HDMI_MCLK,
	output        HDMI_BCK,
	output        HDMI_LRCK,
	output        HDMI_SDATA,
`endif
`ifdef SPDIF_AUDIO
	output        SPDIF,
`endif
`ifdef USE_AUDIO_IN
	input         AUDIO_IN,
`endif
	input         UART_RX,
	output        UART_TX

);

`ifndef NO_DIRECT_UPLOAD
localparam bit DIRECT_UPLOAD = 0;
wire SPI_SS4 = 1;
`else
localparam bit DIRECT_UPLOAD = 1;
`endif

`ifdef USE_QSPI
localparam bit QSPI = 1;
assign QDAT = 4'hZ;
`else
localparam bit QSPI = 0;
`endif

`ifdef VGA_8BIT
localparam VGA_BITS = 8;
`elsif VGA_4BIT
localparam VGA_BITS = 4;
`else
localparam VGA_BITS = 6;
`endif

`ifdef USE_HDMI
localparam bit HDMI = 1;
assign HDMI_RST = 1'b1;
`else
localparam bit HDMI = 0;
`endif

`ifdef BIG_OSD
localparam bit BIG_OSD = 1;
`define SEP "-;",
`else
localparam bit BIG_OSD = 0;
`define SEP
`endif

`ifdef USE_AUDIO_IN
localparam bit USE_AUDIO_IN = 1;
wire TAPE_SOUND=AUDIO_IN;
`else
localparam bit USE_AUDIO_IN = 0;
wire TAPE_SOUND=UART_RX;
`endif


// remove this if the 2nd chip is actually used
`ifdef DUAL_SDRAM
assign SDRAM2_A = 13'hZZZZ;
assign SDRAM2_BA = 0;
assign SDRAM2_DQML = 0;
assign SDRAM2_DQMH = 0;
assign SDRAM2_CKE = 0;
assign SDRAM2_CLK = 0;
assign SDRAM2_nCS = 1;
assign SDRAM2_DQ = 16'hZZZZ;
assign SDRAM2_nCAS = 1;
assign SDRAM2_nRAS = 1;
assign SDRAM2_nWE = 1;
`endif

///////// Default values for ports not used in this core /////////




assign LED = !ioctl_download;



////////////////////////////  HPS I/O  //////////////////////////////////

// Status Bit Map:
// 0         1         2         3          4         5         6
// 01234567890123456789012345678901 23456789012345678901234567890123
// 0123456789ABCDEFGHIJKLMNOPQRSTUV 0123456789ABCDEFGHIJKLMNOPQRSTUV
// XXXX   X XXXXXXX  XX

`include "build_id.v"
parameter CONF_STR = {
	"ODYSSEY2;;",
	`SEP
	"F1,BIN,Load catridge;",
	"F2,ROM,Load XROM;",
   `SEP
	"F3,CHR,Change VDC font;",
	`SEP
   "OF,System,Odyssey2,Videopac;",
   "OCE,G7200,Off,Contrast 1,Contrast 2,Contrast 3,Contrast 4,Contrast 5,Contrast 6,Contrast 7;",
	"O9B,Scandoubler Fx,None,HQ2x,CRT 25%,CRT 50%,CRT 75%;",
	"O1,The Voice,Off,On;",
	"O2,Audio,voice(R)/Console(L),Center mixed;",
	`SEP
	"O7,Swap Joysticks,No,Yes;",
	`SEP
	"T0,Reset;",
	"V,v",`BUILD_DATE
};

wire  [1:0] buttons;
wire [31:0] status;
wire        ioctl_download;
wire [24:0] ioctl_addr;
wire [7:0]  ioctl_dout;
wire        ioctl_wait;
wire        ioctl_wr;
wire  [7:0] ioctl_index;

wire [15:0] joystick_0,joystick_1;

wire scandoubler_disable;
wire ypbpr;
wire no_csync;
wire        key_pressed;
wire [7:0]  key_code;
wire        key_strobe;
wire        key_extended;

wire  [1:0] switches;
wire [10:0] ps2_key ={key_strobe,key_pressed,key_extended,key_code};

`ifdef USE_HDMI

wire        i2c_start;
wire        i2c_read;
wire  [6:0] i2c_addr;
wire  [7:0] i2c_subaddr;
wire  [7:0] i2c_dout;
wire  [7:0] i2c_din;
wire        i2c_ack;
wire        i2c_end;
`endif

user_io #(.STRLEN($size(CONF_STR)>>3), .PS2DIV(100),.SD_IMAGES(1), .FEATURES(32'h0 | (BIG_OSD << 13) | (HDMI << 14))) user_io
(
    .clk_sys(clk_sys),
    .clk_sd(clk_sys),
    .SPI_SS_IO(CONF_DATA0),
    .SPI_CLK(SPI_SCK),
    .SPI_MOSI(SPI_DI),
    .SPI_MISO(SPI_DO),

    .conf_str(CONF_STR),

    .status(status),
    .scandoubler_disable(scandoubler_disable),
    .ypbpr(ypbpr),
    .no_csync(no_csync),
    .buttons(buttons),
    .switches(switches),
    .joystick_0(joystick_0),
    .joystick_1(joystick_1),
    .key_strobe(key_strobe),
    .key_code(key_code),
    .key_pressed(key_pressed),
    .key_extended(key_extended),

`ifdef USE_HDMI
    .i2c_start      (i2c_start      ),
    .i2c_read       (i2c_read       ),
    .i2c_addr       (i2c_addr       ),
    .i2c_subaddr    (i2c_subaddr    ),
    .i2c_dout       (i2c_dout       ),
    .i2c_din        (i2c_din        ),
    .i2c_ack        (i2c_ack        ),
    .i2c_end        (i2c_end        )
`endif

);

data_io   data_io (
    // SPI interface
    .SPI_SCK        ( SPI_SCK ),
    .SPI_SS2        ( SPI_SS2 ),
    .SPI_DI         ( SPI_DI  ),
`ifdef USE_QSPI
	 .QSCK          ( QSCK         ),
	 .QCSn          ( QCSn         ),
	 .QDAT          ( QDAT         ),
`endif
`ifdef NO_DIRECT_UPLOAD
	 .SPI_SS4       ( 1'b1         ),
`else
	 .SPI_SS4       ( SPI_SS4      ),
`endif
    // ram interface
    .clk_sys        ( clk_sys ),
    //.clkref_n       ( ~clk_ref  ),
    .ioctl_download ( ioctl_download ),
    .ioctl_index    ( ioctl_index ),
    .ioctl_wr       ( ioctl_wr ),
    .ioctl_addr     ( ioctl_addr ),
    .ioctl_dout     ( ioctl_dout )
);

wire       PAL = status[15];

`ifdef LOW_BRAM
wire       LOW_BRAM = 1'b1;
`else
wire       LOW_BRAM = 1'b0;
`endif

wire       joy_swap = status[7];

wire       VOICE = status[1];
wire       G7200    = (CONTRAST != 3'd0);
wire [2:0] CONTRAST = status[14:12];

wire [15:0] joya = joy_swap ? joystick_1 : joystick_0;
wire [15:0] joyb = joy_swap ? joystick_0 : joystick_1;


///////////////////////  CLOCK/RESET  ///////////////////////////////////


wire pll_locked;
wire clk_2m5;
wire clk_sys;


////////////The Voice /////////////////////////////////////////////////


wire clk_750k;  

 
pll_thevoice pll_thevoice
( 
`ifdef USE_CLOCK_50
  .inclk0  (CLOCK_50),
`else
  .inclk0  (CLOCK_27),
`endif
  .c0    (clk_750k),
  .c1    (clk_2m5)
);

////////////////////////////////////////////////////////////////////////



wire clk_pal, clk_ntsc;

pll_pal pll_pal
(
`ifdef USE_CLOCK_50
	.inclk0  (CLOCK_50),
`else
	.inclk0  (CLOCK_27),
`endif
	.c0(clk_pal),
	.c1(clk_ntsc),
	.locked(pll_locked)
);


vidclkcntrl vidclkcntrl
(
	.inclk1x(clk_pal),
	.inclk0x(clk_ntsc),
	.clkselect(PAL),
	.outclk(clk_sys)
);




wire reset = buttons[1] | status[0] | ioctl_download;

// Original Clocks:
// Standard    NTSC           PAL
// Sys clock   42.95454       70.9379
// Main clock  21.47727 MHz   35.46895 MHz // ntsc/pal colour carrier times 3/4 respectively
// VDC divider 3              5
// VDC clock   7.159 MHz      7.094 MHz
// CPU divider 4              6
// CPU clock   5.369 MHz      5.911 MHz

reg clk_cpu_en;
reg clk_vdc_en;

reg [3:0] clk_cpu_en_ctr;
reg [3:0] clk_vdc_en_ctr;

// Generate pulse enables for cpu and vdc

always @(posedge clk_sys or posedge reset) begin
	if (reset) begin
		clk_cpu_en_ctr <= 4'd0;
		clk_vdc_en_ctr <= 4'd0;
	end else begin

		// CPU Counter
		if (clk_cpu_en_ctr >= (PAL ? 4'd11 : 4'd7)) begin
			clk_cpu_en_ctr <= 4'd0;
			clk_cpu_en <= 1;
		end else begin
			clk_cpu_en_ctr <= clk_cpu_en_ctr + 4'd1;
			clk_cpu_en <= 0;
		end

		// VDC Counter
		if (clk_vdc_en_ctr >= (PAL ? 4'd9 : 4'd5)) begin
			clk_vdc_en_ctr <= 4'd0;
			clk_vdc_en <= 1;
		end else begin
			clk_vdc_en_ctr <= clk_vdc_en_ctr + 4'd1;
			clk_vdc_en <= 0;
		end
	end
end


////////////////////////////  SYSTEM  ///////////////////////////////////

wire cart_cs;
wire cart_cs_n;

vp_console vp
(
	// System
	.is_pal_g       (PAL),
	.low_bram       (LOW_BRAM),
	.clk_i          (clk_sys),
	.clk_cpu_en_i   (clk_cpu_en),
	.clk_vdc_en_i   (clk_vdc_en),
	.clk_750k       (clk_750k),
	.clk_2m5        (clk_2m5),

	.res_n_i        (~reset & joy_reset), // low to reset

	// Cart Data
	.cart_cs_o      (cart_cs),
	.cart_cs_n_o    (cart_cs_n),
	.cart_wr_n_o    (cart_wr_n),   // Cart write
	.cart_a_o       (cart_addr),   // Cart Address
	.cart_d_i       (cart_do), // Cart Data
	.cart_d_o       (cart_di),     // Cart data out
	.cart_bs0_o     (cart_bank_0), // Bank switch 0
	.cart_bs1_o     (cart_bank_1), // Bank Switch 1
	.cart_psen_n_o  (cart_rd_n),   // Program Store Enable (read)
	.cart_t0_i      (),
	.cart_t0_o      (),
	.cart_t0_dir_o  (),
	// Char Rom data
	.char_d_i       (char_do), // Char Data
	.char_a_o       (char_addr),
	.char_en        (char_en),


	// Input
	.joy_up_n_i     (joy_up), //-- idx = 0 : left joystick -- idx = 1 : right joystick
	.joy_down_n_i   (joy_down),
	.joy_left_n_i   (joy_left),
	.joy_right_n_i  (joy_right),
	.joy_action_n_i (joy_action),

	.keyb_dec_o     (kb_dec),
	.keyb_enc_i     (kb_enc),

	// Video
	.r_o            (R),
	.g_o            (G),
	.b_o            (B),
	.l_o            (luma),
	.hsync_n_o      (HSync),
	.vsync_n_o      (VSync),
	.hbl_o          (HBlank),
	.vbl_o          (VBlank),

	// Sound
	.snd_o          (),
	.snd_vec_o      (snd),
	
	//The voice
	.voice_enable   (VOICE),
	.voice_a        (voice_a),
	.voice_d        (voice_d),
	.voice_rd       (voice_rd),
	.snd_voice_o    (voice_out)
); 

////////////////////////////////////////////////////////////////////////
rom  rom
(
	.clock(clk_sys),
	.address((ioctl_download && ioctl_index > 0 && ioctl_index < 3)? ioctl_addr[13:0] : rom_addr),
	.data(ioctl_dout),
	.wren(ioctl_wr && ioctl_index > 0 && ioctl_index <3),
	.rden(XROM ? rom_oe_n : ~cart_rd_n),
	.q(cart_do)
);

char_rom  char_rom
(
	.clock(clk_sys),
	.address((ioctl_download && ioctl_index == 3) ? ioctl_addr[8:0] : char_addr),
	.data(ioctl_dout),
	.wren(ioctl_wr && ioctl_index == 3),
	.rden(char_en),
	.q(char_do)
);

wire [15:0] voice_a;
wire [7:0] voice_d;
wire voice_rd;

sdram sdram
(
	.*,
	.init(~pll_locked),
	.clk(clk_sys),

   .wtbt(0),
   .addr(ioctl_download ? ioctl_addr : voice_a),
   .rd(voice_rd),
   .dout(voice_d),
   .din(ioctl_dout),
   .we(ioctl_index == 0 && ioctl_wr),
   .ready()
);

assign SDRAM_CLK = ~clk_sys;

wire [11:0] cart_addr;
wire [7:0]  cart_do;
wire [11:0] char_addr;
wire [7:0]  char_do;
wire cart_wr_n;
wire [7:0] cart_di;

wire char_en;
wire cart_bank_0;
wire cart_bank_1;
wire cart_rd_n;
reg [15:0]  cart_size;
wire XROM;
wire rom_oe_n = ~(cart_cs_n & cart_bank_0) & cart_rd_n ;
wire [13:0] rom_addr;

reg old_download = 0;


always @(posedge clk_sys) begin
	old_download <= ioctl_download;

	if (~old_download & ioctl_download)
	begin
		cart_size <= 16'd0;
		XROM <= (ioctl_index == 2);
	end
	else if (ioctl_download && ioctl_wr && ioctl_index > 0 )
		cart_size <= cart_size + 16'd1;
end


always @(*)
  begin
   if (XROM == 1'b1)
	   rom_addr <= {2'b0, cart_addr[11:0]};
	else
	case (cart_size)
	  16'h1000 : rom_addr <= {1'b0,cart_bank_0, cart_addr[11], cart_addr[9:0]};  //4k
	  16'h2000 : rom_addr <= {cart_bank_1,cart_bank_0, cart_addr[11], cart_addr[9:0]};   //8K
	  16'h4000 : rom_addr <= {cart_bank_1,cart_bank_0, cart_addr[11:0]}; //12K (16k banked)
	  default  : rom_addr <= {1'b0, cart_addr[11], cart_addr[9:0]};
	endcase
  end

////////////////////////////  SOUND  ////////////////////////////////////

wire signed[3:0] snd;
wire signed [15:0] voice_out; 

wire signed [15:0] sound_s = {2'b0,snd,snd,snd,2'b0};
wire signed [15:0] voice_s = VOICE ? {voice_out[15],voice_out[11:0],3'b0} : 16'b0;

wire signed [15:0] audiomix = sound_s+voice_s;
wire [15:0] audio_r,audio_l;
assign audio_l=status[2]? {~audiomix[15],audiomix[14:0]} : sound_s;
assign audio_r=status[2]? {~audiomix[15],audiomix[14:0]} : {~voice_s[15],voice_s[14:0]};


`ifdef I2S_AUDIO

wire [31:0] clk_rate =  PAL? 32'd42_954_500 : 32'd70_937_900;

i2s i2s (
        .reset(reset),
        .clk(clk_sys),
        .clk_rate(clk_rate),

        .sclk(I2S_BCK),
        .lrclk(I2S_LRCK),
        .sdata(I2S_DATA),

        .left_chan (audio_l),
        .right_chan(audio_r)
);

`ifdef I2S_AUDIO_HDMI
assign HDMI_MCLK = 0;
always @(posedge clk_sys) begin
	HDMI_BCK <= I2S_BCK;
	HDMI_LRCK <= I2S_LRCK;
	HDMI_SDATA <= I2S_DATA;
end
`endif
`endif

`ifdef SPDIF_AUDIO
spdif spdif (
	.clk_i(clk_sys),
	.rst_i(1'b0),
	.clk_rate_i(clk_rate),
	.spdif_o(SPDIF),
	.sample_i({audio_l,audio_r})
);
`endif

dac #(
   .c_bits	(16))
audiodac_l(
   .clk_i	(clk_sys	),
   .res_n_i	(1	),
   .dac_i	(sound_s),
   .dac_o	(AUDIO_L)
  );

dac #(
   .c_bits	(16))
audiodac_r(
   .clk_i	(clk_sys	),
   .res_n_i	(1	),
   .dac_i	(voice_s),
   .dac_o	(AUDIO_R)
  );

////////////////////////////  VIDEO  ////////////////////////////////////


wire R;
wire G;
wire B;
wire luma;

wire HSync;
wire VSync;
wire VBlank;
wire HBlank;

wire [7:0] Rx = color_lut_vp[{R, G, B, luma}][23:16];
wire [7:0] Gx = color_lut_vp[{R, G, B, luma}][15:8];
wire [7:0] Bx = color_lut_vp[{R, G, B, luma}][7:0];

always @(*) begin
        casex (CONTRAST)
                3'd1:    colors <= {{Rx[7:1],Bx[7]}  ,{Gx[7]  ,Rx[7:1]},{Rx[7:1],Bx[7]}  };
                3'd2:    colors <= {{Rx[7:2],Bx[7:6]},{Gx[7:6],Rx[7:2]},{Rx[7:2],Bx[7:6]}};
                3'd3:    colors <= {{Rx[7:4],Bx[7:4]},{Gx[7:4],Rx[7:4]},{Rx[7:4],Bx[7:4]}};
                3'd4:    colors <= {Rx,Gx,Bx};
                3'd5:    colors <= {{Bx[7:4],Rx[7:4]},{Gx[7:4],Bx[7:4]},{Bx[7:4],Rx[7:4]}};
                3'd6:    colors <= {{Bx[7:2],Rx[7:6]},{Gx[7:6],Bx[7:2]},{Bx[7:2],Rx[7:6]}};
                3'd7:    colors <= {{Bx[7:1],Rx[7]}  ,{Gx[7]  ,Bx[7:1]},{Bx[7:1],Rx[7]}  };
           default: colors <= {Rx,Gx,Bx};
        endcase
end


wire [23:0] colors;
wire [7:0] grayscale;

vga_to_greyscale vga_to_greyscale
(
        .r_in  (colors[23:16]),
        .g_in  (colors[15:8]),
        .b_in  (colors[7:0]),
        .y_out (grayscale)
);


mist_video #(.COLOR_DEPTH(8), .SD_HCNT_WIDTH(11), .OUT_COLOR_DEPTH(VGA_BITS), .BIG_OSD(BIG_OSD)) mist_video (
	
	.clk_sys      (clk_sys    ),
	.SPI_SCK      (SPI_SCK    ),
	.SPI_SS3      (SPI_SS3    ),
	.SPI_DI       (SPI_DI     ),
	.R            (G7200 ? grayscale : Rx ),
	.G            (G7200 ? grayscale : Gx ),
	.B            (G7200 ? grayscale : Bx),
	.HBlank(HBlank),
	.VBlank(VBlank),
	.HSync(~HSync),
	.VSync(~VSync),
	.VGA_R        (VGA_R      ),
	.VGA_G        (VGA_G      ),
	.VGA_B        (VGA_B      ),
	.VGA_VS       (VGA_VS     ),
	.VGA_HS       (VGA_HS     ),
	.ce_divider   (1'b0       ),
	.scandoubler_disable(scandoubler_disable	),
	.scanlines    (status[11:9]),
	.ypbpr        (ypbpr      )
	);

`ifdef USE_HDMI
i2c_master #(70_937_900) i2c_master (
	.CLK         (clk_ntsc),
	.I2C_START   (i2c_start),
	.I2C_READ    (i2c_read),
	.I2C_ADDR    (i2c_addr),
	.I2C_SUBADDR (i2c_subaddr),
	.I2C_WDATA   (i2c_dout),
	.I2C_RDATA   (i2c_din),
	.I2C_END     (i2c_end),
	.I2C_ACK     (i2c_ack),

	//I2C bus
	.I2C_SCL     (HDMI_SCL),
	.I2C_SDA     (HDMI_SDA)
);

mist_video #(.COLOR_DEPTH(8), .SD_HCNT_WIDTH(11), .OUT_COLOR_DEPTH(8), .USE_BLANKS(1), .BIG_OSD(BIG_OSD), .VIDEO_CLEANER(1)) hdmi_video (
	.*,
	.clk_sys     ( clk_ntsc   ),
	.scanlines(status[11:9]),
	.ce_divider  ( 3'd1       ),
	.scandoubler_disable (scandoubler_disable),
	.rotate      ( 2'b00      ),
	.blend       ( 1'b0       ),
	.R            (G7200 ? grayscale : Rx ),
	.G            (G7200 ? grayscale : Gx ),
	.B            (G7200 ? grayscale : Bx),
	.VGA_R       ( HDMI_R      ),
	.VGA_G       ( HDMI_G      ),
	.VGA_B       ( HDMI_B      ),
	.VGA_VS      ( HDMI_VS     ),
	.VGA_HS      ( HDMI_HS     ),
	.VGA_HB(),
	.VGA_VB(),
   .VGA_DE      ( HDMI_DE     )
);
assign HDMI_PCLK = clk_ntsc;

`endif
////////////////////////////  INPUT  ////////////////////////////////////

// [6-15] = Num Keys
// [5]    = Reset
// [4]    = Action
// [3]    = UP
// [2]    = DOWN
// [1]    = LEFT
// [0]    = RIGHT

wire [6:1] kb_dec;
wire [14:7] kb_enc;
wire kb_read_ack;

reg [7:0] ps2_ascii;
reg ps2_changed;
reg ps2_released;

reg [7:0] joy_ascii;
reg [9:0] joy_changed;
reg joy_released;

wire [9:0] joy_numpad = (joya[15:6] | joyb[15:6]);

// If the user tries hard enough with the gamepad they can get keys stuck
// until they press them again. This could stand to be improved in the future.

always @(posedge clk_sys) begin
	reg old_state;
	reg [9:0] old_joy;

	old_state <= ps2_key[10];
	old_joy <= joy_numpad;

	ps2_changed <= (old_state != ps2_key[10]);
	ps2_released <= ~ps2_key[9];

	joy_changed <= (joy_numpad ^ old_joy);
	joy_released <= (joy_numpad ? 1'b0 : 1'b1);

	if(old_state != ps2_key[10]) begin
		casex(ps2_key[8:0])
			'hX16: ps2_ascii <= "1"; // 1
			'hX1E: ps2_ascii <= "2"; // 2
			'hX26: ps2_ascii <= "3"; // 3
			'hX25: ps2_ascii <= "4"; // 4
			'hX2E: ps2_ascii <= "5"; // 5
			'hX36: ps2_ascii <= "6"; // 6
			'hX3D: ps2_ascii <= "7"; // 7
			'hX3E: ps2_ascii <= "8"; // 8
			'hX46: ps2_ascii <= "9"; // 9
			'hX45: ps2_ascii <= "0"; // 0

			'hX1C: ps2_ascii <= "a"; // a
			'hX32: ps2_ascii <= "b"; // b
			'hX21: ps2_ascii <= "c"; // c
			'hX23: ps2_ascii <= "d"; // d
			'hX24: ps2_ascii <= "e"; // e
			'hX2B: ps2_ascii <= "f"; // f
			'hX34: ps2_ascii <= "g"; // g
			'hX33: ps2_ascii <= "h"; // h
			'hX43: ps2_ascii <= "i"; // i
			'hX3B: ps2_ascii <= "j"; // j
			'hX42: ps2_ascii <= "k"; // k
			'hX4B: ps2_ascii <= "l"; // l
			'hX3A: ps2_ascii <= "m"; // m
			'hX31: ps2_ascii <= "n"; // n
			'hX44: ps2_ascii <= "o"; // o
			'hX4D: ps2_ascii <= "p"; // p
			'hX15: ps2_ascii <= "q"; // q
			'hX2D: ps2_ascii <= "r"; // r
			'hX1B: ps2_ascii <= "s"; // s
			'hX2C: ps2_ascii <= "t"; // t
			'hX3C: ps2_ascii <= "u"; // u
			'hX2A: ps2_ascii <= "v"; // v
			'hX1D: ps2_ascii <= "w"; // w
			'hX22: ps2_ascii <= "x"; // x
			'hX35: ps2_ascii <= "y"; // y
			'hX1A: ps2_ascii <= "z"; // z
			'hX29: ps2_ascii <= " "; // space

			'hX79: ps2_ascii <= "+"; // +
			'hX7B: ps2_ascii <= "-"; // -
			'hX7C: ps2_ascii <= "*"; // *
			'hX4A: ps2_ascii <= "/"; // /
			'hX55: ps2_ascii <= "="; // /
			'hX1F: ps2_ascii <= 8'h11; // gui l / yes
			'hX27: ps2_ascii <= 8'h12; // gui r / no
			'hX5A: ps2_ascii <= 8'd10; // enter
			'hX66: ps2_ascii <= 8'd8; // backspace
			default: ps2_ascii <= 8'h00;
		endcase
	end else if (joy_numpad) begin
		if (joy_numpad[0])
			joy_ascii <= "1";
		else if (joy_numpad[1])
			joy_ascii <= "2";
		else if (joy_numpad[2])
			joy_ascii <= "3";
		else if (joy_numpad[3])
			joy_ascii <= "4";
		else if (joy_numpad[4])
			joy_ascii <= "5";
		else if (joy_numpad[5])
			joy_ascii <= "6";
		else if (joy_numpad[6])
			joy_ascii <= "7";
		else if (joy_numpad[7])
			joy_ascii <= "8";
		else if (joy_numpad[8])
			joy_ascii <= "9";
		else if (joy_numpad[9])
			joy_ascii <= "0";
		else
			joy_ascii <= 8'h00;
	end
end

vp_keymap vp_keymap
(
	.clk_i(clk_sys),
	.res_n_i(~reset),
	.keyb_dec_i(kb_dec),
	.keyb_enc_o(kb_enc),

	.rx_data_ready_i(ps2_changed || joy_changed),
	.rx_ascii_i(ps2_changed ? ps2_ascii : joy_ascii),
	.rx_released_i(ps2_released && joy_released),
	.rx_read_o(kb_read_ack)
);

// Joystick wires are low when pressed
// Passed as a vector bit 1 = left bit 0 = right
// There is no definition as to which is player 1

wire [1:0] joy_up     = {~joya[3], ~joyb[3]};
wire [1:0] joy_down   = {~joya[2], ~joyb[2]};
wire [1:0] joy_left   = {~joya[1], ~joyb[1]};
wire [1:0] joy_right  = {~joya[0], ~joyb[0]};
wire [1:0] joy_action = {~joya[4], ~joyb[4]};
wire       joy_reset  = ~joya[5] & ~joyb[5];


////////////////////////////////////////////////////////////////////////////////////////////////////////////////

// LUT using calibrated palette
wire [23:0] color_lut_vp[16] = '{
	  24'h000000,    //BLACK
	  24'h676767,    //GREY
	  24'h1a37be,    //BLUE
	  24'h5c80f6,    //BLUE I
	  24'h006d07,    //GREEN
	  24'h56c469,    //GREEN I
	  24'h2aaabe,    //BLUE GREEN
	  24'h77e6eb,    //BLUE-GREEN I
	  24'h790000,    //RED
	  24'hc75151,    //RED I
	  24'h94309f,    //VIOLET
	  24'hdc84e8,    //VIOLET I
	  24'h77670b,    //KAHKI
	  24'hc6b86a,    //KAHKI I
	  24'hcecece,    //GREY I 
	  24'hffffff     //WHITE
};


endmodule