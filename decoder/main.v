`timescale  1ns/1ns

`include "../define.v"
`define WORD_BITS 32

module main;
	reg rst;
	reg clk;
	reg [`INST_BITS-1:0]	inst;
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
	
	//count up
//	initial begin
//		inst = 0;
//		end
//		always @(posedge clk) begin
//			inst = inst + 1;
//		end
//
//	initial begin
	initial begin
		$dumpfile("main.vcd");
		$dumpvars(0, main);
//inst <= 32'h00221800;// iAdd 	K0 K1 R0  
//inst <= 32'h08221800;// iSub 	K0 K1 R0 
//inst <= 32'h10221800;// iMul 	K0 K1 R0  
//inst <= 32'h18221800;// iDev 	K0 K1 R0 
//inst <= 32'h20221800;// fAdd 	K0 K1 R0 
//inst <= 32'h28221800;// fSub 	K0 K1 R0 
//inst <= 32'h30221800;// fMul 	K0 K1 R0 
//inst <= 32'h38221800;// fDev 	K0 K1 R0 
//inst <= 32'h40221800;// and  	K0 K1 R0 
//inst <= 32'h44221800;// or   	K0 K1 R0 
//inst <= 32'h48221800;// xor  	K0 K1 R0 
//inst <= 32'h4c221800;// ucmp  	K0 K1 R0 
//inst <= 32'h50221800;// Lsft 	K0 K1 R0 
//inst <= 32'h54221800;// Rsft 	K0 K1 R0 
//inst <= 32'h58221800;// cmp  	K0 K1 R0 
//inst <= 32'h5c010000;// jr   	K0 K1 R0 
//inst <= 32'h80220003;// iAddi 	K0 K1 3
//inst <= 32'h88220003;// iSubi 	K0 K1 3
//inst <= 32'h90220003;// iMuli 	K0 K1 3
//inst <= 32'h98220003;// iDevi 	K0 K1 3
//inst <= 32'ha0220003;// lw 	K0 K1 3
//inst <= 32'ha4220003;// sw	K0 K1 3
//inst <= 32'ha8220003;// Lsfti 	K0 K1 3
//inst <= 32'hac220003;// Rsfti 	K0 K1 3
//inst <= 32'hb0220003;// be 	K0 K1 0x3
//inst <= 32'hb4220003;// bne 	K0 K1 3
//inst <= 32'hb8220003;// cmpi 	K0 K1 0x3
//inst <= 32'hbc220003;// ucmpi 	K0 K1 0x3
//inst <= 32'hc0000004;// j 	0x4
//inst <= 32'hc4000004;// jal 	0x4                   
		
		valid 	<= 1;
		inst <= 32'h00221800;// iAdd 	K0 K1 R0  
		#(CYCLE*10)
		inst <= 32'h08221800;// iSub 	K0 K1 R0 
		#(CYCLE*10)
		inst <= 32'h10221800;// iMul 	K0 K1 R0  
		#(CYCLE*10)
		inst <= 32'h18221800;// iDev 	K0 K1 R0 
		#(CYCLE*10)
		inst <= 32'h20221800;// fAdd 	K0 K1 R0 
		#(CYCLE*10)
		inst <= 32'h28221800;// fSub 	K0 K1 R0 
		#(CYCLE*10)
		inst <= 32'h30221800;// fMul 	K0 K1 R0 
		#(CYCLE*10)
		inst <= 32'h38221800;// fDev 	K0 K1 R0 
		#(CYCLE*10)
		inst <= 32'h40221800;// and  	K0 K1 R0 
		#(CYCLE*10)
		inst <= 32'h44221800;// or   	K0 K1 R0 
		#(CYCLE*10)
		inst <= 32'h48221800;// xor  	K0 K1 R0 
		#(CYCLE*10)
		inst <= 32'h4c221800;// ucmp  	K0 K1 R0 
		#(CYCLE*10)
		inst <= 32'h50221800;// Lsft 	K0 K1 R0 
		#(CYCLE*10)
		inst <= 32'h54221800;// Rsft 	K0 K1 R0 
		#(CYCLE*10)
		inst <= 32'h58221800;// cmp  	K0 K1 R0 
		#(CYCLE*10)
		inst <= 32'h5c010000;// jr   	K0 K1 R0 
		#(CYCLE*10)
		inst <= 32'h80220003;// iAddi 	K0 K1 3
		#(CYCLE*10)
		inst <= 32'h88220003;// iSubi 	K0 K1 3
		#(CYCLE*10)
		inst <= 32'h90220003;// iMuli 	K0 K1 3
		#(CYCLE*10)
		inst <= 32'h98220003;// iDevi 	K0 K1 3
		#(CYCLE*10)
		inst <= 32'ha0220003;// lw 	K0 K1 3
		#(CYCLE*10)
		inst <= 32'ha4220003;// sw	K0 K1 3
		#(CYCLE*10)
		inst <= 32'ha8220003;// Lsfti 	K0 K1 3
		#(CYCLE*10)
		inst <= 32'hac220003;// Rsfti 	K0 K1 3
		#(CYCLE*10)
		inst <= 32'hb0220003;// be 	K0 K1 0x3
		#(CYCLE*10)
		inst <= 32'hb4220003;// bne 	K0 K1 3
		#(CYCLE*10)
		inst <= 32'hb8220003;// cmpi 	K0 K1 0x3
		#(CYCLE*10)
		inst <= 32'hbc220003;// ucmpi 	K0 K1 0x3
		#(CYCLE*10)
		inst <= 32'hc0000004;// j 	0x4
		#(CYCLE*10)
		inst <= 32'hc4000004;// jal 	0x4                   
		#(CYCLE*10)
		$finish;
	end
	
	mDecoder uDecoder (	
	.i_inst			(inst),
	.i_inst_valid		(valid),
	
	.o_jr			(),

	.o_jal_addr		(),
	.o_jal_addr_valid	(),
	
	.o_j_addr		(),
	.o_j_addr_valid		(),

	.o_write_req		(),
	.o_read_req		(),
	
	.o_type			(),
	.o_op			(),
	.o_dst			(),
	.o_src0			(),
	.o_src1			(),
	.o_minor_imm		(),
	
	.rst			(rst),
	.clk			(clk)
	);


endmodule
