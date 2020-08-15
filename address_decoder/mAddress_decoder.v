///////////////////////////////////////////
// This modules is in modakio cpu.
// mAddress_decoder module
// 2020/08/13 writen by denchu
//

`ifndef	_mADDRESS_DECODER_
`define	_mADDRESS_DECODER_
`include	"./define.v"


module mAddress_decoder (
	input	[`EXCEPTION_CODE_HARD_BITS-1:0]	i_h_intr_code,
	input	[`EXCEPTION_CODE_SOFT_BITS-1:0]	i_s_intr_code,
	output	[`WORD_BITS-1:0]		o_intr_address
);

	assign o_intr_address = (i_h_intr_code == `EXCEPTION_CODE_HARD_RESET)	? `INTR_VECTOR_ADDR_RESET:
				(i_h_intr_code == `EXCEPTION_CODE_HARD_TIMER)	? `INTR_VECTOR_ADDR_TIMER:
				(i_h_intr_code == `EXCEPTION_CODE_HARD_KEYBOARD)	? `INTR_VECTOR_ADDR_KEYBOARD:
				(i_h_intr_code == `EXCEPTION_CODE_HARD_ETHERNET)	? `INTR_VECTOR_ADDR_ETHERNET:
				(i_h_intr_code == `EXCEPTION_CODE_HARD_IO)	? `INTR_VECTOR_ADDR_IO:
				(i_s_intr_code == `EXCEPTION_CODE_SOFT_ZERODIV)	? `INTR_VECTOR_ADDR_ZERODIV:
				(i_s_intr_code == `EXCEPTION_CODE_SOFT_OVERFLOW)	? `INTR_VECTOR_ADDR_OVERFLOW:
				(i_s_intr_code == `EXCEPTION_CODE_SOFT_UNDERFLOW)	? `INTR_VECTOR_ADDR_UNDERFLOW:
				(i_s_intr_code == `EXCEPTION_CODE_SOFT_TRAP)	? `INTR_VECTOR_ADDR_TRAP:`INTR_VECTOR_ADDR_RESET;
	

endmodule

`endif
