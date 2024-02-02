// SPDX-License-Identifier: Apache-2.0
// Copyright 2019 Western Digital Corporation or its affiliates.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//********************************************************************************
// $Id$
//
// Function: Verilog testbench for SweRVolf
// Comments:
//
//********************************************************************************

`default_nettype none
module rvfpgasim
  #(parameter bootrom_file  = "")
`ifdef VERILATOR
  (input wire clk,
   input wire  rst,
   input wire  i_jtag_tck,
   input wire  i_jtag_tms,
   input wire  i_jtag_tdi,
   input wire  i_jtag_trst_n,
   output wire o_jtag_tdo,
   output wire o_uart_tx,
   output wire o_gpio,
   //-------------------------------------
   //Agregar puerto nuevo para botones.
   //Paso11: Agregar entrada de satos i_bttns
   input wire i_bttns
   //-------------------------------------
`endif
  );

   localparam RAM_SIZE     = 32'h10000;

`ifndef VERILATOR
   reg 	 clk = 1'b0;
   reg 	 rst = 1'b1;

   always #10 clk <= !clk;
   initial #100 rst <= 1'b0;

   wire  o_gpio;
   wire i_jtag_tck = 1'b0;
   wire i_jtag_tms = 1'b0;
   wire i_jtag_tdi = 1'b0;
   wire i_jtag_trst_n = 1'b0;
   wire o_jtag_tdo;
   wire o_uart_tx;

//   uart_decoder #(115200) uart_decoder (o_uart_tx);

`endif

   reg [1023:0] ram_init_file;
   initial begin
      if (|$test$plusargs("jtag_vpi_enable"))
	$display("JTAG VPI enabled. Not loading RAM");
      else if ($value$plusargs("ram_init_file=%s", ram_init_file)) begin
	 $display("Loading RAM contents from %0s", ram_init_file);
	 $readmemh(ram_init_file, ram.ram.mem);
      end
   end

   reg [1023:0] rom_init_file;
   initial begin
      if ($value$plusargs("rom_init_file=%s", rom_init_file)) begin
	 $display("Loading ROM contents from %0s", rom_init_file);
	 $readmemh(rom_init_file, swervolf.bootrom.ram.mem);
      end else if (!(|bootrom_file))
	//Jump to address 0 if no bootloader is selected
	swervolf.bootrom.ram.mem[0] = 64'h0000000000000067;
   end

   wire [15:0]    i_sw;
   assign  i_sw = 16'hFE34;
   //------------------------------------------
   //Paso 12: Agregar el nuevo cable para pruebas de i_bttns llamado io_bttns
   wire [31:0]    io_bttns=({30'b0,i_bttns});
   //------------------------------------------

   wire [5:0]  ram_awid;
   wire [31:0] ram_awaddr;
   wire [7:0]  ram_awlen;
   wire [2:0]  ram_awsize;
   wire [1:0]  ram_awburst;
   wire        ram_awlock;
   wire [3:0]  ram_awcache;
   wire [2:0]  ram_awprot;
   wire [3:0]  ram_awregion;
   wire [3:0]  ram_awqos;
   wire        ram_awvalid;
   wire        ram_awready;
   wire [5:0]  ram_arid;
   wire [31:0] ram_araddr;
   wire [7:0]  ram_arlen;
   wire [2:0]  ram_arsize;
   wire [1:0]  ram_arburst;
   wire        ram_arlock;
   wire [3:0]  ram_arcache;
   wire [2:0]  ram_arprot;
   wire [3:0]  ram_arregion;
   wire [3:0]  ram_arqos;
   wire        ram_arvalid;
   wire        ram_arready;
   wire [63:0] ram_wdata;
   wire [7:0]  ram_wstrb;
   wire        ram_wlast;
   wire        ram_wvalid;
   wire        ram_wready;
   wire [5:0]  ram_bid;
   wire [1:0]  ram_bresp;
   wire        ram_bvalid;
   wire        ram_bready;
   wire [5:0]  ram_rid;
   wire [63:0] ram_rdata;
   wire [1:0]  ram_rresp;
   wire        ram_rlast;
   wire        ram_rvalid;
   wire        ram_rready;

   wire        dmi_reg_en;
   wire [6:0]  dmi_reg_addr;
   wire        dmi_reg_wr_en;
   wire [31:0] dmi_reg_wdata;
   wire [31:0] dmi_reg_rdata;
   wire        dmi_hard_reset;
   //---------------------------
   reg [5:0]  cache_ram_awid;
   reg [31:0] cache_ram_awaddr;
   reg [7:0]  cache_ram_awlen;
   reg [2:0]  cache_ram_awsize;
   reg [1:0]  cache_ram_awburst;
   wire        cache_ram_awlock;
   reg [3:0]  cache_ram_awcache;
   reg [2:0]  cache_ram_awprot;
   reg [3:0]  cache_ram_awregion;
   reg [3:0]  cache_ram_awqos;
   wire        cache_ram_awvalid;
   wire        cache_ram_awready;

   reg [5:0]  cache_ram_arid;
   reg [31:0] cache_ram_araddr;
   reg [7:0]  cache_ram_arlen;
   reg [2:0]  cache_ram_arsize;
   reg [1:0]  cache_ram_arburst;
   wire        cache_ram_arlock;
   reg [3:0]  cache_ram_arcache;
   reg [2:0]  cache_ram_arprot;
   reg [3:0]  cache_ram_arregion;
   reg [3:0]  cache_ram_arqos;
   wire        cache_ram_arvalid;
   wire        cache_ram_arready;

   reg [63:0] cache_ram_wdata;
   reg [7:0]  cache_ram_wstrb;
   wire        cache_ram_wlast;
   wire        cache_ram_wvalid;
   wire        cache_ram_wready;

   reg [5:0]  cache_ram_bid;
   reg [1:0]  cache_ram_bresp;
   wire        cache_ram_bvalid;
   wire        cache_ram_bready;

   reg [5:0]  cache_ram_rid;
   reg [63:0] cache_ram_rdata;
   reg [1:0]  cache_ram_rresp;
   wire        cache_ram_rlast;
   wire        cache_ram_rvalid;
   wire        cache_ram_rready;
   
   // -------------------------------------------
    cache_64 cache_0_SIM(
      .clk            (clk),
      .rst            (rst),

      .icpu_aw_id     (cache_ram_awid),
      .icpu_aw_addr   (cache_ram_awaddr),
      .icpu_aw_len    (cache_ram_awlen),
      .icpu_aw_size   (cache_ram_awsize),
      .icpu_aw_burst  (cache_ram_awburst),
      .icpu_aw_lock   (cache_ram_awlock),
      .icpu_aw_cache  (cache_ram_awcache),
      .icpu_aw_prot  (cache_ram_awprot),
      .icpu_aw_region (cache_ram_awregion),
      .icpu_aw_qos    (cache_ram_awqos),
      .icpu_aw_valid  (cache_ram_awvalid),
      .ocpu_aw_ready  (cache_ram_awready),
      // ----
      .icpu_ar_id     (cache_ram_arid),
      .icpu_ar_addr   (cache_ram_araddr),
      .icpu_ar_len    (cache_ram_arlen),
      .icpu_ar_size   (cache_ram_arsize),
      .icpu_ar_burst  (cache_ram_arburst),
      .icpu_ar_lock   (cache_ram_arlock),
      .icpu_ar_cache  (cache_ram_arcache),
      .icpu_ar_prot   (cache_ram_arprot),
      .icpu_ar_region (cache_ram_arregion),
      .icpu_ar_qos    (cache_ram_arqos),
      .icpu_ar_valid  (cache_ram_arvalid),
      .ocpu_ar_ready  (cache_ram_arready),
      // ----
      .icpu_w_data    (cache_ram_wdata),
      .icpu_w_strb    (cache_ram_wstrb),
      .icpu_w_last    (cache_ram_wlast),
      .icpu_w_valid   (cache_ram_wvalid),
      .ocpu_w_ready   (cache_ram_wready),
      // ----
      .ocpu_b_id      (cache_ram_bid),
      .ocpu_b_resp    (cache_ram_bresp),
      .ocpu_b_valid   (cache_ram_bvalid),
      .icpu_b_ready   (cache_ram_bready),
      // ----
      .ocpu_r_id      (cache_ram_rid),
      .ocpu_r_data    (cache_ram_rdata),
      .ocpu_r_resp    (cache_ram_rresp),
      .ocpu_r_last    (cache_ram_rlast),
      .ocpu_r_valid   (cache_ram_rvalid),
      .icpu_r_ready   (cache_ram_rready),
      // ==============================
      .o_aw_id        (ram_awid),
      .o_aw_addr      (ram_awaddr),
      .o_aw_len       (ram_awlen),
      .o_aw_size      (ram_awsize),
      .o_aw_burst     (ram_awburst),
      .o_aw_lock      (ram_awlock),
      .o_aw_cache     (ram_awcache),
      .o_aw_prot     (ram_awprot),
      .o_aw_region    (ram_awregion),
      .o_aw_qos       (ram_awqos),
      .o_aw_valid     (ram_awvalid),
      .i_aw_ready     (ram_awready),
      // ----
      .o_ar_id        (ram_arid),
      .o_ar_addr      (ram_araddr),
      .o_ar_len       (ram_arlen),
      .o_ar_size      (ram_arsize),
      .o_ar_burst     (ram_arburst),
      .o_ar_lock      (ram_arlock),
      .o_ar_cache     (ram_arcache),
      .o_ar_prot      (ram_arprot),
      .o_ar_region    (ram_arregion),
      .o_ar_qos       (ram_arqos),
      .o_ar_valid     (ram_arvalid),
      .i_ar_ready     (ram_arready),
      // ----
      .o_w_data       (ram_wdata),
      .o_w_strb       (ram_wstrb),
      .o_w_last       (ram_wlast),
      .o_w_valid      (ram_wvalid),
      .i_w_ready      (ram_wready),
      // ----
      .i_b_id         (ram_bid),
      .i_b_resp       (ram_bresp),
      .i_b_valid      (ram_bvalid),
      .o_b_ready      (ram_bready),
      // ----
      .i_r_id         (ram_rid),
      .i_r_data       (ram_rdata),
      .i_r_resp       (ram_rresp),
      .i_r_last       (ram_rlast),
      .i_r_valid      (ram_rvalid),
      .o_r_ready      (ram_rready)
    );
   // -------------------------------------------

   axi_mem_wrapper
     #(.ID_WIDTH  (`RV_LSU_BUS_TAG+2),
       .MEM_SIZE  (RAM_SIZE),
       .INIT_FILE (""))
   ram
     (.clk       (clk),
      .rst_n     (!rst),

      .i_awid    (ram_awid),
      .i_awaddr  (ram_awaddr),
      .i_awlen   (ram_awlen),
      .i_awsize  (ram_awsize),
      .i_awburst (ram_awburst),
      .i_awvalid (ram_awvalid),
      .o_awready (ram_awready),

      .i_arid    (ram_arid),
      .i_araddr  (ram_araddr),
      .i_arlen   (ram_arlen),
      .i_arsize  (ram_arsize),
      .i_arburst (ram_arburst),
      .i_arvalid (ram_arvalid),
      .o_arready (ram_arready),

      .i_wdata  (ram_wdata),
      .i_wstrb  (ram_wstrb),
      .i_wlast  (ram_wlast),
      .i_wvalid (ram_wvalid),
      .o_wready (ram_wready),

      .o_bid    (ram_bid),
      .o_bresp  (ram_bresp),
      .o_bvalid (ram_bvalid),
      .i_bready (ram_bready),

      .o_rid    (ram_rid),
      .o_rdata  (ram_rdata),
      .o_rresp  (ram_rresp),
      .o_rlast  (ram_rlast),
      .o_rvalid (ram_rvalid),
      .i_rready (ram_rready));

   dmi_wrapper dmi_wrapper
     (.trst_n    (i_jtag_trst_n),
      .tck       (i_jtag_tck),
      .tms       (i_jtag_tms),
      .tdi       (i_jtag_tdi),
      .tdo       (o_jtag_tdo),
      .tdoEnable (),
      // Processor Signals
      .scan_mode      (1'b0),
      .core_rst_n     (!rst),
      .core_clk       (clk),
      .jtag_id        (31'd0),
      .rd_data        (dmi_reg_rdata),
      .reg_wr_data    (dmi_reg_wdata),
      .reg_wr_addr    (dmi_reg_addr),
      .reg_en         (dmi_reg_en),
      .reg_wr_en      (dmi_reg_wr_en),
      .dmi_hard_reset (dmi_hard_reset)); 

   swervolf_core
     #(.bootrom_file (bootrom_file))
   swervolf
     (.clk  (clk),
      .rstn (!rst),
      .dmi_reg_rdata       (dmi_reg_rdata),
      .dmi_reg_wdata       (dmi_reg_wdata),
      .dmi_reg_addr        (dmi_reg_addr),
      .dmi_reg_en          (dmi_reg_en),
      .dmi_reg_wr_en       (dmi_reg_wr_en),
      .dmi_hard_reset      (dmi_hard_reset),
      .o_flash_sclk        (),
      .o_flash_cs_n        (),
      .o_flash_mosi        (),
      .i_flash_miso        (1'b0),
      .i_uart_rx           (1'b1),
      .o_uart_tx           (o_uart_tx),

      .o_ram_awid          (cache_ram_awid),
      .o_ram_awaddr        (cache_ram_awaddr),
      .o_ram_awlen         (cache_ram_awlen),
      .o_ram_awsize        (cache_ram_awsize),
      .o_ram_awburst       (cache_ram_awburst),
      .o_ram_awlock        (cache_ram_awlock),
      .o_ram_awcache       (cache_ram_awcache),
      .o_ram_awprot        (cache_ram_awprot),
      .o_ram_awregion      (cache_ram_awregion),
      .o_ram_awqos         (cache_ram_awqos),
      .o_ram_awvalid       (cache_ram_awvalid),
      .i_ram_awready       (cache_ram_awready),

      .o_ram_arid          (cache_ram_arid),
      .o_ram_araddr        (cache_ram_araddr),
      .o_ram_arlen         (cache_ram_arlen),
      .o_ram_arsize        (cache_ram_arsize),
      .o_ram_arburst       (cache_ram_arburst),
      .o_ram_arlock        (cache_ram_arlock),
      .o_ram_arcache       (cache_ram_arcache),
      .o_ram_arprot        (cache_ram_arprot),
      .o_ram_arregion      (cache_ram_arregion),
      .o_ram_arqos         (cache_ram_arqos),
      .o_ram_arvalid       (cache_ram_arvalid),
      .i_ram_arready       (cache_ram_arready),

      .o_ram_wdata         (cache_ram_wdata),
      .o_ram_wstrb         (cache_ram_wstrb),
      .o_ram_wlast         (cache_ram_wlast),
      .o_ram_wvalid        (cache_ram_wvalid),
      .i_ram_wready        (cache_ram_wready),

      .i_ram_bid           (cache_ram_bid),
      .i_ram_bresp         (cache_ram_bresp),
      .i_ram_bvalid        (cache_ram_bvalid),
      .o_ram_bready        (cache_ram_bready),

      .i_ram_rid           (cache_ram_rid),
      .i_ram_rdata         (cache_ram_rdata),
      .i_ram_rresp         (cache_ram_rresp),
      .i_ram_rlast         (cache_ram_rlast),
      .i_ram_rvalid        (cache_ram_rvalid),
      .o_ram_rready        (cache_ram_rready),

      .i_ram_init_done     (1'b1),
      .i_ram_init_error    (1'b0),
      .io_data             ({i_sw,16'bz}),
     //-----------------------------------
     //Paso 13: Nuevo puerto en instancia swervolf de SIM.
      .io_bttns            ({io_bttns})
     //-----------------------------------
      );

endmodule
