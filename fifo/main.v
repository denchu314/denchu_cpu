`timescale  1ps/1ps

`include "../define.v"
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
		#(CYCLE*20)
		valid <= $random % 2;
	end


	integer idx;
	initial begin
		$dumpfile("main.vcd");
		$dumpvars(0, main);
		for(idx = 0; idx < 8; idx = idx + 1) $dumpvars(1, main.uFifo.mem[idx]);
		
		#(CYCLE*100);
			$display(main.uFifo.w_full);
		$finish;
		
	end
	
	mFifo #(
		.p_st_bits		(32),
		.p_fifo_length 		(8),
		.p_fifo_length_log2 	(3)
	) uFifo(
		.i_snk_data		(data),
		//.i_snk_valid		(valid),
		.i_snk_valid		(valid),
		.o_snk_ready		(),
		
		.o_src_data		(),
		.o_src_valid		(),
		.i_src_ready		(!valid),

		.clk			(clk),
		.rst			(rst)

	);


endmodule
