`timescale  1ns/1ns

`include "../define.v"
`define WORD_BITS 32

module main;
	reg rst;
	reg clk;
	reg [`WORD_BITS-1:0]	a;
	reg [`REG_ADDR_BITS-1:0]	addr;
	reg valid0;
	reg valid1;
	reg valid2;


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
	
	//count up
	initial begin
		a = 0;
		end
		always @(posedge clk) begin
			a = a + 1;
		end

	initial begin

		$dumpfile("main.vcd");
		$dumpvars(0, main);
				valid0 	<= 0;
				valid1 	<= 0;
				valid2 	<= 0;
		#(CYCLE*100)
				valid0 	<= 1;
				valid1 	<= 0;
				valid2 	<= 0;
		#(CYCLE*100)
				valid0 	<= 0;
				valid1 	<= 1;
				valid2 	<= 0;
		#(CYCLE*100)
				valid0 	<= 0;
				valid1 	<= 0;
				valid2 	<= 1;
		#(CYCLE*100);
		$finish;
	end
	
	mArb5 uArb5(
		.iSnk0Data	(a),
		.iSnk0Valid	(valid0),
		.iSnk1Data	(a<<2),
		.iSnk1Valid	(valid1),
		.iSnk2Data	(a<<4),
		.iSnk2Valid	(valid2),
		
		.oSrc0Data	(),
		.oSrc0Valid	(),
		
		.rst		(rst),
		.clk		(clk)
	); 

endmodule
