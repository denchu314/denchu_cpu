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


	integer idx;
	initial begin
		$dumpfile("main.vcd");
		$dumpvars(0, main);
//		for(idx = 0; idx < 8; idx = idx + 1) $dumpvars(1, main.uFifo.mem[idx]);
		
		#(CYCLE*400);
//			$display(main.uFifo.w_full);
		$finish;
		
	end
	
mMM_to_ST_arb #(
	.p_st_bits		(`WORD_BITS),
	.p_addr_bits 		(`MEM_ADDR_BITS),
	.p_fifo_length 		(8),
	.p_fifo_length_log2 	(3)
) uMM_to_ST_arb (
	.i_writedata		(0 /*data*/),
	.i_addr			(0 /*data[17:0]*/),
	.i_read_req		(0),
	.i_write_req		(0 /*valid*/),
	
	.o_readdata		(),
	.o_valid		(),
	
	.o_write_mem_complete	(),
	.o_read_mem_complete	(),
	
	.o_writedata		(),
	.o_write		(),
	.o_addr			(),
	.o_read			(),
	.i_readdata		(data),
	.i_readdatavalid	(valid),
	.i_waitrequest		(0),

	.clk			(clk),
	.rst			(rst)

);


endmodule
