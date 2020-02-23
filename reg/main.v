`timescale  1ns/1ns

`include "../define.v"
`define WORD_BITS 32

module main;
	reg rst;
	reg clk;
	reg [`WORD_BITS-1:0]	a;
	reg [`REG_ADDR_BITS-1:0]	addr;
	reg valid;


	parameter CYCLE = 1000; //clock rate = 1000ns(1MHz)


	//reset
	initial begin
				rst = 1;
		#(CYCLE*4)	rst = 0;
	end

	//clock
	initial begin
		clk = 0;
		end
	always begin
		#(CYCLE/2) clk = ~clk;
	end

	initial begin

		$dumpfile("main.vcd");
		$dumpvars(0, main);
				a 	<= 810;
				valid 	<= 0;
				addr 	<= 1;
		#(CYCLE*100)	a 	<= 810;
				valid 	<= 1;
				addr 	<= 1;
		#(CYCLE*100)	a 	<= 1919;
				valid 	<= 1;
				addr 	<= 0;
		#(CYCLE*100);
		$finish;
	end
	
	mRegister #(
		//.pStreamBits	(32)
	) uRegister (
	.iDstAddr	(addr),
	.iSrc0Addr	(0),
	.iSrc1Addr	(1),
	
	.iDstVal	(a),
	.iDstValid	(valid),
	
	.oSrc0Val	(),
	
	.oSrc1Val	(),
	
	.rst		(rst),
	.clk		(clk)
	);

endmodule
