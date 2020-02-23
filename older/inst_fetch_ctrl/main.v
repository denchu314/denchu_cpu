`timescale  1ps/1ps

`include "../define.v"
`include "../lib/mFifo.v"
`define WORD_BITS 32

module main;
	reg rst;
	reg clk;
	reg [`INST_BITS-1:0]	data;
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
	
	//random
	initial begin
		valid <= 0;
	end
	always @(posedge clk) begin
		//#(CYCLE*0.1)
		valid <= $random % 2;
	end

	reg	[3:0]	valid4;
	//random
	initial begin
		valid4 <= 0;
	end
	always @(posedge clk) begin
		//#(CYCLE*0.1)
		valid4 <= $random % 16;
	end

	integer idx;
	initial begin
		$dumpfile("main.vcd");
		$dumpvars(0, main);
//		for(idx = 0; idx < 8; idx = idx + 1) $dumpvars(1, main.uFifo.mem[idx]);
		
		#(CYCLE*400);
//			$display(main.uFifo.w_full);
		$finish;
		
	end
	
	
	mInst_fetch_ctrl #(
		.p_fifo_length 		(8),
		.p_fifo_length_log2 	(3)
	) uInst_fetch_ctrl (
		.o_ret_addr		(),
		.o_ret_addr_valid	(),
	
		.i_jr_addr		(data[17:0]),
		.i_jr_valid		(valid),
	
		.i_j_addr		(0),
		.i_j_valid		(0),
		
		.i_jal_addr		(0),
		.i_jal_valid		(0),
		
		.o_inst			(),
		.o_inst_valid		(),
		
		.o_rst_inst_fifo	(),
		
		.i_inst_complete	(0),
	
		.o_inst_empty		(),
	
		
		.o_burstcount		(),
		.o_addr			(),
		.o_read			(),
		.i_waitrequest		(0),
		.i_readdata		(0),
		.i_readdatavalid	(0),
		
	
		.clk			(clk),
		.rst			(rst)
	
	);

endmodule
