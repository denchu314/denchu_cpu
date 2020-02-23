///////////////////////////////////////////
// This modules is in modakio cpu.
// mMux module ver 1.0
// 2018/05/05 writen by denchu
//
`ifndef	_mMUX_
`define	_mMUX_

module mMux #(
	parameter	pStreamBits = 32
)(
	input		[pStreamBits-1:0]	iIn0,
	input		[pStreamBits-1:0]	iIn1,
	output		[pStreamBits-1:0]	oOut,
	
	input					sel
);

	assign	oOut	= (sel == 1'b0) ? iIn0 : iIn1;
endmodule

`endif
