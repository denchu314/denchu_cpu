///////////////////////////////////////////
// This modules is in modakio cpu.
// mArb5.v module ver 1.0
// 2019/03/11 writen by denchu
//
`ifndef	_mARB5_
`define	_mARB5_
`include	"./define.v"

module mArb5 #(
	parameter			p_st_bits = `WORD_BITS
)(
	input	[p_st_bits-1:0]	iSnk0Data,
	input			iSnk0Valid,
	input	[p_st_bits-1:0]	iSnk1Data,
	input			iSnk1Valid,
	input	[p_st_bits-1:0]	iSnk2Data,
	input			iSnk2Valid,
	input	[p_st_bits-1:0]	iSnk3Data,
	input			iSnk3Valid,
	input	[p_st_bits-1:0]	iSnk4Data,
	input			iSnk4Valid,
	
	output	[p_st_bits-1:0]	oSrc0Data,
	output			oSrc0Valid,
	
	input	rst,
	input	clk
); 

	assign oSrc0Data	=	(iSnk0Valid == 1'b1)? iSnk0Data : 
					(iSnk1Valid == 1'b1)? iSnk1Data : 
					(iSnk2Valid == 1'b1)? iSnk2Data : 
					(iSnk3Valid == 1'b1)? iSnk3Data :
					(iSnk4Valid == 1'b1)? iSnk4Data : 0;
	assign oSrc0Valid	=	(((iSnk0Valid | iSnk1Valid) | (iSnk2Valid | iSnk3Valid)))| iSnk4Valid;

endmodule

`endif
