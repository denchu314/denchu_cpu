`timescale  1ps/1ps

`include "../define.v"
`include "../lib/mFifo.v"
`define WORD_BITS 32

module main;
	reg rst;
	reg clk;
	reg [`INST_BITS-1:0]	data;
	reg [`INST_BITS-1:0]	counter;
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
		counter	<= 0;
	end
	always @(posedge clk) begin
		//#(CYCLE*0.1)
		counter <= counter + 1;
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

	reg	[32*10-1:0]	test	[1023:0];
	reg	[31:0]	r_src0;
	reg	[31:0]	r_src1;
	reg	[31:0]	r_type;
	reg	[31:0]	r_op;
	reg	[31:0]	r_calc_start;
	reg	[31:0]	r_calc_complete;

	reg	[31:0]	r_writedata;
	reg	[31:0]	r_addr;
	reg	[31:0]	r_read;
	reg	[31:0]	r_write;
	
	initial begin 
		$readmemh("test.hex", test);
	end
	always @(posedge clk)
	begin
		if(rst) begin
			r_src0			<=0;
			r_src1			<=0;
			r_type			<=0;
			r_op			<=0;
			r_calc_start		<=0;
			r_calc_complete		<=0;
			r_writedata		<=0;
			r_addr			<=0;
			r_read			<=0;
			r_write			<=0;
		end else begin
			r_src0			<=test[counter][32*10-1:32* 9];
			r_src1			<=test[counter][32* 9-1:32* 8];
			r_type			<=test[counter][32* 8-1:32* 7];
			r_op			<=test[counter][32* 7-1:32* 6];
			r_calc_start		<=test[counter][32* 6-1:32* 5];
			r_calc_complete		<=test[counter][32* 5-1:32* 4];
			r_writedata		<=test[counter][32* 4-1:32* 3];
			r_addr			<=test[counter][32* 3-1:32* 2];
			r_read			<=test[counter][32* 2-1:32* 1];
			r_write			<=test[counter][32* 1-1:32* 0];
		end
	end

	initial begin
		$dumpfile("main.vcd");
		$dumpvars(0, main);
//		for(idx = 0; idx < 8; idx = idx + 1) $dumpvars(1, main.uFifo.mem[idx]);
		
		#(CYCLE*400);
//			$display(main.uFifo.w_full);
		$finish;
		
	end
	
	
	mAlu uAlu (
		.i_operand_0_val	(r_src0),
		.i_operand_1_val	(r_src1),
		.o_result_val		(),
		.o_result_valid		(),
		
		.i_type			(r_type),
		.i_op			(r_op),
		.i_calc_start		(r_calc_start),

		.clk			(clk),
		.rst			(rst)
	);

endmodule
