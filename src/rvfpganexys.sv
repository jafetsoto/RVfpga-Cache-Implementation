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
// Function: SweRVolf toplevel for Nexys A7 board
// Comments:
//
//********************************************************************************

`default_nettype none
module rvfpganexys
  #(parameter bootrom_file  = "boot_main.mem")
   (input wire 	       clk,
    input wire 	       rstn,
    output wire [12:0] ddram_a,
    output wire [2:0]  ddram_ba,
    output wire        ddram_ras_n,
    output wire        ddram_cas_n,
    output wire        ddram_we_n,
    output wire        ddram_cs_n,
    output wire [1:0]  ddram_dm,
    inout wire [15:0]  ddram_dq,
    inout wire [1:0]   ddram_dqs_p,
    inout wire [1:0]   ddram_dqs_n,
    output wire        ddram_clk_p,
    output wire        ddram_clk_n,
    output wire        ddram_cke,
    output wire        ddram_odt,
    output wire        o_flash_cs_n,
    output wire        o_flash_mosi,
    input wire 	       i_flash_miso,
    input wire 	       i_uart_rx,
    output wire        o_uart_tx,
    inout wire [15:0]  i_sw,
    output reg [15:0]  o_led,
    //-------------------------------------------
    //Paso 2: Expandir modulo rvfpganexys para tener conección con los nuevos pines.
    inout wire [4:0]   i_bttns,
    //-------------------------------------------
    output reg [7:0]   AN,
    output reg         CA, CB, CC, CD, CE, CF, CG,
    output wire        o_accel_cs_n,
    output wire        o_accel_mosi,
    input wire         i_accel_miso,
    output wire        accel_sclk);

   wire [15:0] 	       gpio_out;

   wire 	       cpu_tx,litedram_tx;

   wire 	       litedram_init_done;
   wire 	       litedram_init_error;

   localparam RAM_SIZE     = 32'h10000;

   wire 	 clk_core;
   wire 	 rst_core;
   wire 	 user_clk;
   wire 	 user_rst;

   clk_gen_nexys clk_gen
     (.i_clk (user_clk),
      .i_rst (user_rst),
      .o_clk_core (clk_core),
      .o_rst_core (rst_core));

   // Bus AXI para memoria y para cpu:
   // Conexion de la mem con el cpu por AXI.
   // 32 bits de datos
   // 64 bits de dirección
   
   AXI_BUS #(32, 64, 6, 1) mem();
   AXI_BUS #(32, 64, 6, 1) cpu();

   assign cpu.aw_atop = 6'd0;
   assign cpu.aw_user = 1'b0;
   assign cpu.ar_user = 1'b0;
   assign cpu.w_user = 1'b0;
   assign cpu.b_user = 1'b0;
   assign cpu.r_user = 1'b0;
   
   assign mem.b_user = 1'b0;
   assign mem.r_user = 1'b0;

   axi_cdc_intf
     #(.AXI_USER_WIDTH (1),
       .AXI_ADDR_WIDTH (32),
       .AXI_DATA_WIDTH (64),
       .AXI_ID_WIDTH   (6))
   // Cross Domain Crossing
    cdc 
     (
      .src_clk_i  (clk_core),
      .src_rst_ni (~rst_core),
      .src        (cpu),

      .dst_clk_i  (user_clk),
      .dst_rst_ni (~user_rst),
      .dst        (mem));
    // ------------------------------------------------
   litedram_top
     #(.ID_WIDTH (6))
   ddr2
     (.serial_tx   (litedram_tx),
      .serial_rx   (i_uart_rx),
      .clk100      (clk),
      .rst_n       (rstn),
      .pll_locked  (),
      .user_clk    (user_clk),
      .user_rst    (user_rst),
      .ddram_a     (ddram_a),
      .ddram_ba    (ddram_ba),
      .ddram_ras_n (ddram_ras_n),
      .ddram_cas_n (ddram_cas_n),
      .ddram_we_n  (ddram_we_n),
      .ddram_cs_n  (ddram_cs_n),
      .ddram_dm    (ddram_dm   ),
      .ddram_dq    (ddram_dq   ),
      .ddram_dqs_p (ddram_dqs_p),
      .ddram_dqs_n (ddram_dqs_n),
      .ddram_clk_p (ddram_clk_p),
      .ddram_clk_n (ddram_clk_n),
      .ddram_cke   (ddram_cke  ),
      .ddram_odt   (ddram_odt  ),
      .init_done  (litedram_init_done),
      .init_error (litedram_init_error),

      .i_awid    (mem.aw_id   ),
      .i_awaddr  (mem.aw_addr[26:0] ),
      .i_awlen   (mem.aw_len  ),
      .i_awsize  ({1'b0,mem.aw_size} ),
      .i_awburst (mem.aw_burst),
      .i_awvalid (mem.aw_valid),
      .o_awready (mem.aw_ready),

      .i_arid    (mem.ar_id   ),
      .i_araddr  (mem.ar_addr[26:0] ),
      .i_arlen   (mem.ar_len  ),
      .i_arsize  ({1'b0,mem.ar_size} ),
      .i_arburst (mem.ar_burst),
      .i_arvalid (mem.ar_valid),
      .o_arready (mem.ar_ready),

      .i_wdata   (mem.w_data  ),
      .i_wstrb   (mem.w_strb  ),
      .i_wlast   (mem.w_last  ),
      .i_wvalid  (mem.w_valid ),
      .o_wready  (mem.w_ready ),

      .o_bid     (mem.b_id    ),
      .o_bresp   (mem.b_resp  ),
      .o_bvalid  (mem.b_valid ),
      .i_bready  (mem.b_ready ),

      .o_rid     (mem.r_id    ),
      .o_rdata   (mem.r_data  ),
      .o_rresp   (mem.r_resp  ),
      .o_rlast   (mem.r_last  ),
      .o_rvalid  (mem.r_valid ),
      .i_rready  (mem.r_ready ));

   wire        dmi_reg_en;
   wire [6:0]  dmi_reg_addr;
   wire        dmi_reg_wr_en;
   wire [31:0] dmi_reg_wdata;
   wire [31:0] dmi_reg_rdata;
   wire        dmi_hard_reset;
   wire        flash_sclk;

   STARTUPE2 STARTUPE2
     (
      .CFGCLK    (),
      .CFGMCLK   (),
      .EOS       (),
      .PREQ      (),
      .CLK       (1'b0),
      .GSR       (1'b0),
      .GTS       (1'b0),
      .KEYCLEARB (1'b1),
      .PACK      (1'b0),
      .USRCCLKO  (flash_sclk),
      .USRCCLKTS (1'b0),
      .USRDONEO  (1'b1),
      .USRDONETS (1'b0));

   bscan_tap tap
     (.clk            (clk_core),
      .rst            (rst_core),
      .jtag_id        (31'd0),
      .dmi_reg_wdata  (dmi_reg_wdata),
      .dmi_reg_addr   (dmi_reg_addr),
      .dmi_reg_wr_en  (dmi_reg_wr_en),
      .dmi_reg_en     (dmi_reg_en),
      .dmi_reg_rdata  (dmi_reg_rdata),
      .dmi_hard_reset (dmi_hard_reset),
      .rd_status      (2'd0),
      .idle           (3'd0),
      .dmi_stat       (2'd0),
      .version        (4'd1));

   // =====================================================
   // La cache debe capturar los datos del cpu, realizar el proceso
   // de busqueda de datos y completar la comunicación con el CDC.
   cache_256 cache_0(
      .clk          (clk_core),
      .rst          (rst_core),

      .icpu_aw_id     (cache_aw_id),
      .icpu_aw_addr   (cache_aw_addr),
      .icpu_aw_len    (cache_aw_len),
      .icpu_aw_size   (cache_aw_size),
      .icpu_aw_burst  (cache_aw_burst),
      .icpu_aw_lock   (cache_aw_lock),
      .icpu_aw_cache  (cache_aw_cache),
      .icpu_aw_pront  (cache_aw_prot),
      .icpu_aw_region (cache_aw_region),
      .icpu_aw_qos    (cache_aw_qos),
      .icpu_aw_valid  (cache_aw_valid),
      .ocpu_aw_ready  (cache_aw_ready),
      // ----
      .icpu_ar_id     (cache_ar_id),
      .icpu_ar_addr   (cache_ar_addr),
      .icpu_ar_len    (cache_ar_len),
      .icpu_ar_size   (cache_ar_size),
      .icpu_ar_burst  (cache_ar_burst),
      .icpu_ar_lock   (cache_ar_lock),
      .icpu_ar_cache  (cache_ar_cache),
      .icpu_ar_prot   (cache_ar_prot),
      .icpu_ar_region (cache_ar_region),
      .icpu_ar_qos    (cache_ar_qos),
      .icpu_ar_valid  (cache_ar_valid),
      .ocpu_ar_ready  (cache_ar_ready),
      // ----
      .icpu_w_data    (cache_w_data),
      .icpu_w_strb    (cache_w_strb),
      .icpu_w_last    (cache_w_last),
      .icpu_w_valid   (cache_w_valid),
      .icpu_w_ready   (cache_w_ready),
      // ----
      .ocpu_b_id      (cache_b_id),
      .ocpu_b_resp    (cache_b_resp),
      .ocpu_b_valid   (cache_b_valid),
      .icpu_b_ready   (cache_b_ready),
      // ----
      .ocpu_r_id      (cache_r_id),
      .ocpu_r_data    (cache_r_data),
      .ocpu_r_resp    (cache_r_resp),
      .ocpu_r_last    (cache_r_last),
      .ocpu_r_valid   (cache_r_valid),
      .icpu_r_ready   (cache_r_ready),
      // =====
      .i_aw_id      (cpu.aw_id),
      .i_aw_addr    (cpu.aw_addr),
      .i_aw_len     (cpu.aw_len),
      .i_aw_size    (cpu.aw_size),
      .i_aw_awburst (cpu.aw_burst),
      .i_aw_lock    (cpu.aw_lock),
      .i_aw_cache   (cpu.aw_cache),
      .i_aw_pront   (cpu.aw_prot),
      .i_aw_region  (cpu.aw_region),
      .i_aw_qos     (cpu.aw_qos),
      .i_aw_valid   (cpu.aw_valid),
      .o_aw_ready   (cpu.aw_ready),
      // ----
      .i_ar_id     (cpu.ar_id),
      .i_ar_addr   (cpu.ar_addr),
      .i_ar_len    (cpu.ar_len),
      .i_ar_size   (cpu.ar_size),
      .i_ar_burst  (cpu.ar_burst),
      .i_ar_lock   (cpu.ar_lock),
      .i_ar_cache  (cpu.ar_cache),
      .i_ar_prot   (cpu.ar_prot),
      .i_ar_region (cpu.ar_region),
      .i_ar_qos    (cpu.ar_qos),
      .i_ar_valid  (cpu.ar_valid),
      .o_ar_ready  (cpu.ar_ready),
      // ----
      .i_w_data    (cpu.w_data),
      .i_w_strb    (cpu.w_strb),
      .i_w_last    (cpu.w_last),
      .i_w_valid   (cpu.w_valid),
      .i_w_ready   (cpu.w_ready),
      // ----
      .o_b_id      (cpu.b_id),
      .o_b_resp    (cpu.b_resp),
      .o_b_valid   (cpu.b_valid),
      .i_b_ready   (cpu.b_ready),
      // ----
      .o_r_id      (cpu.r_id),
      .o_r_data    (cpu.r_data),
      .o_r_resp    (cpu.r_resp),
      .o_r_last    (cpu.r_last),
      .o_r_valid   (cpu.r_valid),
      .i_r_ready   (cpu.r_ready)
   );



   swervolf_core
     #(.bootrom_file (bootrom_file),
       .clk_freq_hz  (32'd50_000_000))
   swervolf
     (.clk  (clk_core),
      .rstn (~rst_core),
      .dmi_reg_rdata  (dmi_reg_rdata),
      .dmi_reg_wdata  (dmi_reg_wdata),
      .dmi_reg_addr   (dmi_reg_addr ),
      .dmi_reg_en     (dmi_reg_en   ),
      .dmi_reg_wr_en  (dmi_reg_wr_en),
      .dmi_hard_reset (dmi_hard_reset),
      .o_flash_sclk   (flash_sclk),
      .o_flash_cs_n   (o_flash_cs_n),
      .o_flash_mosi   (o_flash_mosi),
      .i_flash_miso   (i_flash_miso),
      .i_uart_rx      (i_uart_rx),

      .o_uart_tx      (cpu_tx),

      .o_ram_awid     (cache_aw_id),
      .o_ram_awaddr   (cache_aw_addr),
      .o_ram_awlen    (cache_aw_len),
      .o_ram_awsize   (cache_aw_size),
      .o_ram_awburst  (cache_aw_burst),
      .o_ram_awlock   (cache_aw_lock),
      .o_ram_awcache  (cache_aw_cache),
      .o_ram_awprot   (cache_aw_prot),
      .o_ram_awregion (cache_aw_region),
      .o_ram_awqos    (cache_aw_qos),
      .o_ram_awvalid  (cache_aw_valid),
      .i_ram_awready  (cache_aw_ready),

      .o_ram_arid     (cache_ar_id),
      .o_ram_araddr   (cache_ar_addr),
      .o_ram_arlen    (cache_ar_len),
      .o_ram_arsize   (cache_ar_size),
      .o_ram_arburst  (cache_ar_burst),
      .o_ram_arlock   (cache_ar_lock),
      .o_ram_arcache  (cache_ar_cache),
      .o_ram_arprot   (cache_ar_prot),
      .o_ram_arregion (cache_ar_region),
      .o_ram_arqos    (cache_ar_qos),
      .o_ram_arvalid  (cache_ar_valid),
      .i_ram_arready  (cache_ar_ready),

      .o_ram_wdata    (cache_w_data),
      .o_ram_wstrb    (cache_w_strb),
      .o_ram_wlast    (cache_w_last),
      .o_ram_wvalid   (cache_w_valid),
      .i_ram_wready   (cache_w_ready),

      .i_ram_bid      (cache_b_id),
      .i_ram_bresp    (cache_b_resp),
      .i_ram_bvalid   (cache_b_valid),
      .o_ram_bready   (cache_b_ready),

      .i_ram_rid      (cache_r_id),
      .i_ram_rdata    (cache_r_data),
      .i_ram_rresp    (cache_r_resp),
      .i_ram_rlast    (cache_r_last),
      .i_ram_rvalid   (cache_r_valid),
      .o_ram_rready   (cache_r_ready),

      .i_ram_init_done  (litedram_init_done),
      .i_ram_init_error (litedram_init_error),

      .io_data        ({i_sw[15:0],gpio_out[15:0]}),
      //-------------------------------------------
      .io_bttns       ({27'b0,i_bttns[4],i_bttns[3],i_bttns[2],i_bttns[1],i_bttns[0]}),
      //-------------------------------------------
      .AN (AN),
      .Digits_Bits ({CA,CB,CC,CD,CE,CF,CG}),
      .o_accel_sclk   (accel_sclk),
      .o_accel_cs_n   (o_accel_cs_n),
      .o_accel_mosi   (o_accel_mosi),
      .i_accel_miso   (i_accel_miso));

   always @(posedge clk_core) begin
      o_led[15:0] <= gpio_out[15:0];
   end

   assign o_uart_tx = 1'b0 ? litedram_tx : cpu_tx;

endmodule
