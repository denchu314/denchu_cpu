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
		
	input				iShadowSwitch,
	
	input	rst,
	input	clk
); 

	reg	[`NUM_OF_REG-1:0]	rRegisters 		[`WORD_BITS-1:0];
	reg	[`NUM_OF_REG-1:0]	rRegisters_shadow 	[`WORD_BITS-1:0];

	// front register	
	always @ (posedge clk)
	begin 
		if (rst) begin
			//atodekaku
		end else if (iDstValid & !iShadowSwitch) begin
			rRegisters[iDstAddr]		<=	iDstVal;
		end
	end

	// shadow register
	always @ (posedge clk)
	begin 
		if (rst) begin
			//atodekaku
		end else if (iDstValid & iShadowSwitch) begin
			rRegisters_shadow[iDstAddr]	<=	iDstVal;
		end
	end

	assign	oSrc0Val	=	(iShadowSwitch)?	((iSrc0Addr == 0)? `WORD_BITS'b0 : rRegisters_shadow[iSrc0Addr]) :
								((iSrc0Addr == 0)? `WORD_BITS'b0 : rRegisters[iSrc0Addr]);
	assign	oSrc1Val	=	(iShadowSwitch)?	((iSrc1Addr == 0)? `WORD_BITS'b0 : rRegisters_shadow[iSrc1Addr]) :
								((iSrc1Addr == 0)? `WORD_BITS'b0 : rRegisters[iSrc1Addr]);

endmodule

`endif
