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
	
	

	//random
	initial begin
		counter	<= 0;
	end
	always @(posedge clk) begin
		#(CYCLE*0.1)
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
	reg	[31:0]	r_data_readdata		;
	reg	[31:0]	r_data_readdadavalid	;
	reg	[31:0]	r_data_waitrequest	;
	reg	[31:0]  r_inst_waitrequest  	;
	reg	[31:0]  r_inst_readdata     	;
	reg	[31:0]  r_inst_readdatavalid	;
	reg	[31:0]  r_status_writedata	;
	reg	[31:0]	r_status_addr		;
	reg	[31:0]	r_status_read		;
	reg	[31:0]	r_status_write		;
	
	initial begin 
		$readmemh("test.hex", test);
	end
	always @(posedge clk)
	begin
		if(rst) begin
			r_data_readdata		<= 0;
			r_data_readdadavalid	<= 0;
			r_data_waitrequest	<= 0;
			r_inst_waitrequest  	<= 0;
			r_inst_readdata     	<= 0;
			r_inst_readdatavalid	<= 0;
			r_status_writedata	<= 0;
			r_status_addr		<= 0;
			r_status_read		<= 0;
			r_status_write		<= 0;
		end else begin
			r_data_readdata		<= test[counter][32*10-1:32* 9];
			r_data_readdadavalid	<= test[counter][32* 9-1:32* 8];
			r_data_waitrequest	<= test[counter][32* 8-1:32* 7];
			r_inst_waitrequest  	<= test[counter][32* 7-1:32* 6];
			r_inst_readdata     	<= test[counter][32* 6-1:32* 5];
			r_inst_readdatavalid	<= test[counter][32* 5-1:32* 4];
			r_status_writedata	<= test[counter][32* 4-1:32* 3];
			r_status_addr		<= test[counter][32* 3-1:32* 2];
			r_status_read		<= test[counter][32* 2-1:32* 1];
			r_status_write		<= test[counter][32* 1-1:32* 0];
		end
	end

	mCpu_top uCpu_top(
		// To memory(data)
		.o_data_writedata	(),
		.o_data_write		(),
		.o_data_addr		(),
		.o_data_read		(),
		.i_data_readdata	(r_data_readdata),
		.i_data_readdatavalid	(r_data_readdadavalid),
		.i_data_waitrequest	(r_data_waitrequest),

		// To memory(instruction)
		.o_inst_burstcount	(),
		.o_inst_addr		(),
		.o_inst_read		(),
		.i_inst_waitrequest	(r_inst_waitrequest),
		.i_inst_readdata	(r_inst_readdata),
		.i_inst_readdatavalid	(r_inst_readdatavalid),

		// To control	
		.i_status_writedata	(r_status_writedata),
		.o_status_readdata	(),
		.o_status_readdatavalid	(),
		.i_status_addr		(r_status_addr),
		.i_status_read		(r_status_read),
		.i_status_write		(r_status_writedata),

		.clk			(clk),
		.rst			(rst)
	);


endmodule
