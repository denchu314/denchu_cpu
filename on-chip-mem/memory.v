// memory.v

// Generated using ACDS version 16.1 196

`timescale 1 ps / 1 ps
module memory (
		input  wire        onchip_memory2_0_clk1_clk,         //   onchip_memory2_0_clk1.clk
		input  wire        onchip_memory2_0_clk2_clk,         //   onchip_memory2_0_clk2.clk
		input  wire        onchip_memory2_0_reset1_reset,     // onchip_memory2_0_reset1.reset
		input  wire        onchip_memory2_0_reset1_reset_req, //                        .reset_req
		input  wire        onchip_memory2_0_reset2_reset,     // onchip_memory2_0_reset2.reset
		input  wire        onchip_memory2_0_reset2_reset_req, //                        .reset_req
		input  wire [9:0]  onchip_memory2_0_s1_address,       //     onchip_memory2_0_s1.address
		input  wire        onchip_memory2_0_s1_clken,         //                        .clken
		input  wire        onchip_memory2_0_s1_chipselect,    //                        .chipselect
		input  wire        onchip_memory2_0_s1_write,         //                        .write
		output wire [31:0] onchip_memory2_0_s1_readdata,      //                        .readdata
		input  wire [31:0] onchip_memory2_0_s1_writedata,     //                        .writedata
		input  wire [3:0]  onchip_memory2_0_s1_byteenable,    //                        .byteenable
		input  wire [9:0]  onchip_memory2_0_s2_address,       //     onchip_memory2_0_s2.address
		input  wire        onchip_memory2_0_s2_chipselect,    //                        .chipselect
		input  wire        onchip_memory2_0_s2_clken,         //                        .clken
		input  wire        onchip_memory2_0_s2_write,         //                        .write
		output wire [31:0] onchip_memory2_0_s2_readdata,      //                        .readdata
		input  wire [31:0] onchip_memory2_0_s2_writedata,     //                        .writedata
		input  wire [3:0]  onchip_memory2_0_s2_byteenable     //                        .byteenable
	);

	memory_onchip_memory2_0 onchip_memory2_0 (
		.clk         (onchip_memory2_0_clk1_clk),         //   clk1.clk
		.address     (onchip_memory2_0_s1_address),       //     s1.address
		.clken       (onchip_memory2_0_s1_clken),         //       .clken
		.chipselect  (onchip_memory2_0_s1_chipselect),    //       .chipselect
		.write       (onchip_memory2_0_s1_write),         //       .write
		.readdata    (onchip_memory2_0_s1_readdata),      //       .readdata
		.writedata   (onchip_memory2_0_s1_writedata),     //       .writedata
		.byteenable  (onchip_memory2_0_s1_byteenable),    //       .byteenable
		.reset       (onchip_memory2_0_reset1_reset),     // reset1.reset
		.reset_req   (onchip_memory2_0_reset1_reset_req), //       .reset_req
		.address2    (onchip_memory2_0_s2_address),       //     s2.address
		.chipselect2 (onchip_memory2_0_s2_chipselect),    //       .chipselect
		.clken2      (onchip_memory2_0_s2_clken),         //       .clken
		.write2      (onchip_memory2_0_s2_write),         //       .write
		.readdata2   (onchip_memory2_0_s2_readdata),      //       .readdata
		.writedata2  (onchip_memory2_0_s2_writedata),     //       .writedata
		.byteenable2 (onchip_memory2_0_s2_byteenable),    //       .byteenable
		.clk2        (onchip_memory2_0_clk2_clk),         //   clk2.clk
		.reset2      (onchip_memory2_0_reset2_reset),     // reset2.reset
		.reset_req2  (onchip_memory2_0_reset2_reset_req), //       .reset_req
		.freeze      (1'b0)                               // (terminated)
	);

endmodule
