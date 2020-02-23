`timescale  1ps/1ps

`include "../define.v"
`include "../lib/mFifo.v"
`define WORD_BITS 32

module main;
	reg rst;
	reg clk;
	reg [`INST_BITS-1:0]	data;
	reg [9:0]	addr;
	reg valid;


	parameter CYCLE = 1000; //clock rate = 1000ns(1MHz)


	//reset
	initial begin
		//#(CYCLE*0.1)
				rst <= 1;
		#(CYCLE*4)	rst <= 0;
	end

	//clock
	initial begin
		clk <= 0;
	end
	always begin
		#(CYCLE/2) clk <= ~clk;
	end
	
	//count up
	initial begin
		data <= 0;
	end
	always @(posedge clk) begin
		//#(CYCLE*0.1)
			data <= data + 1;
	end
	
	//count up
	initial begin
		addr <= 0;
	end
	always @(posedge clk) begin
		//#(CYCLE*0.1)
			addr <= addr + 1;
	end
	
	//random
	initial begin
		valid <= 0;
	end
	always @(posedge clk) begin
		//#(CYCLE*0.1)
		//valid <= $random % 2;
		valid <= 1;
	end

	reg	readdata_valid;

	integer idx;
	initial begin
		$dumpfile("main.vcd");
		$dumpvars(0, main);
//		for(idx = 0; idx < 8; idx = idx + 1) $dumpvars(1, main.uFifo.mem[idx]);
		
		#(CYCLE*400);
//			$display(main.uFifo.w_full);
		$finish;
		
	end

	memory uMemory (
		.onchip_memory2_0_clk1_clk		(clk),         //   onchip_memory2_0_clk1.clk
		.onchip_memory2_0_clk2_clk		(clk),         //   onchip_memory2_0_clk2.clk
		.onchip_memory2_0_reset1_reset		(rst),     // onchip_memory2_0_reset1.reset
		.onchip_memory2_0_reset1_reset_req	(1'b0), //                        .reset_req
		.onchip_memory2_0_reset2_reset		(rst),     // onchip_memory2_0_reset2.reset
		.onchip_memory2_0_reset2_reset_req	(1'b0), //                        .reset_req
		.onchip_memory2_0_s1_address		(addr),       //     onchip_memory2_0_s1.address
		.onchip_memory2_0_s1_clken		(),         //                        .clken
		.onchip_memory2_0_s1_chipselect		(valid),    //                        .chipselect
		.onchip_memory2_0_s1_write		(valid),         //                        .write
		.onchip_memory2_0_s1_readdata		(),      //                        .readdata
		.onchip_memory2_0_s1_writedata		(data),     //                        .writedata
		.onchip_memory2_0_s1_byteenable		(),    //                        .byteenable
		.onchip_memory2_0_s2_address		(addr),       //     onchip_memory2_0_s2.address
		.onchip_memory2_0_s2_chipselect		(valid),    //                        .chipselect
		.onchip_memory2_0_s2_clken		(),         //                        .clken
		.onchip_memory2_0_s2_write		(valid),         //                        .write
		.onchip_memory2_0_s2_readdata		(),      //                        .readdata
		.onchip_memory2_0_s2_writedata		(data),     //                        .writedata
		.onchip_memory2_0_s2_byteenable		()     //                        .byteenable
	);
	

endmodule
