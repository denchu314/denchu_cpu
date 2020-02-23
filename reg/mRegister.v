///////////////////////////////////////////
// This modules is in modakio cpu.
// rRegister module ver 1.0
// 2018/05/05 writen by denchu
//
`ifndef	_mREGISTER_
`define	_mREGISTER_
`include	"./define.v"

module mRegister (
	input	[`REG_ADDR_BITS-1:0]	iDstAddr,
	input	[`REG_ADDR_BITS-1:0]	iSrc0Addr,
	input	[`REG_ADDR_BITS-1:0]	iSrc1Addr,
	
	input	[`WORD_BITS-1:0]	iDstVal,
	input				iDstValid,
	
	output	[`WORD_BITS-1:0]	oSrc0Val,
	
	output	[`WORD_BITS-1:0]	oSrc1Val,
	
	input	rst,
	input	clk
); 

	reg	[`NUM_OF_REG-1:0]	rRegisters [`WORD_BITS-1:0];
	
	always @ (posedge clk)
	begin 
		if (rst) begin
			//atodekaku
		end else if (iDstValid) begin
			rRegisters[iDstAddr]	<=	iDstVal;
		end
	end

	assign	oSrc0Val	=	(iSrc0Addr == 0)? `WORD_BITS'b0 : rRegisters[iSrc0Addr];
	assign	oSrc1Val	=	(iSrc1Addr == 0)? `WORD_BITS'b0 : rRegisters[iSrc1Addr];

endmodule

`endif
