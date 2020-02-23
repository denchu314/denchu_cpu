///////////////////////////////////////////
// This modules is in modakio cpu.
// mOnehot_sender module ver 1.0
// 2019/03/23 writen by denchu
//
`ifndef	_mONEHOT_SENDER_
`define	_mONEHOT_SENDER_
`include "./define.v"

module mOnehot_sender (
	input				in,
	output				out,
	
	input				clk,
	input				rst
);

	reg	one_clock_before;

	// write pointer
	always @(posedge clk)
	begin
		if(rst) begin
			one_clock_before <= 0;
		end else begin
			one_clock_before <= in;
		end
	end

	assign out = (in == 1'b1 && one_clock_before == 1'b0)? 1'b1 : 1'b0;
	
endmodule

`endif
