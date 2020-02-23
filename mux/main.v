`timescale  1ns/1ns

`include "../define.v"

module main;
	reg rst;
	reg clk;
	reg sel;
	reg a;
	reg b;


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
		//$monitor ("%t: clk = %b, a = %b, b = %b", $time, clk, a, b);
				sel <= 1;
		#(CYCLE*100)	a <= 1;
				b <= 0;
		#(CYCLE*100)	a <= 0;
				b <= 1;
		#(CYCLE*100)	a <= 1;
				b <= 0;
		#(CYCLE*100)	a <= 0;
				b <= 1;
		#(CYCLE*100)	a <= 1;
				b <= 0;
		#(CYCLE*100)	a <= 0;
				b <= 1;
		#(CYCLE*100);
		$finish;
	end
	
	mMux #(
		.pStreamBits	(32)
	) uMux (
		.sel	(sel),
		.iIn0	(a),
		.iIn1	(b),
		.oOut	()
	);

endmodule
