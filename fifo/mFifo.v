///////////////////////////////////////////
// This modules is in modakio cpu.
// mArb.v module ver 1.0
// 2019/03/16 writen by denchu
//
`ifndef	_mFIFO_
`define	_mFIFO_
`include "./define.v"

module mFifo #(
	parameter	p_st_bits		= 32,
	parameter	p_fifo_length 		= 8,
	parameter	p_fifo_length_log2 	= 3
//	parameter	p_fifo_length_log2 	= log2(p_fifo_length)
)(
	input	[p_st_bits-1:0]	i_snk_data,
	input			i_snk_valid,
	output			o_snk_ready,
	
	output	[p_st_bits-1:0]	o_src_data,
	output			o_src_valid,
	input			i_src_ready,

	input			clk,
	input			rst

);
	//function integer log2;
        //input integer num;
        //	begin
        //		num = num - 1;
        //	for (log2 = 0; num > 0; log2 = log2 + 1)
        //		num = num >> 1;
        //	end
        //endfunction

	//reg	[p_fifo_length-1:0] 		mem [p_st_bits-1:0];
	reg	[p_st_bits-1:0] 		mem [p_fifo_length-1:0];
	reg	[p_fifo_length_log2-1:0]	w_ptr;
	reg	[p_fifo_length_log2-1:0]	r_ptr;

	// write pointer
	//always @(posedge clk or posedge rst)
	always @(posedge clk)
	begin
		if(rst) begin
			w_ptr <= 0;
		end else if (!w_full && i_snk_valid) begin
			w_ptr <= w_ptr + 1;
		end
	end
	
	// read pointer
	//always @(posedge clk or posedge rst)
	always @(posedge clk)
	begin
		if(rst) begin
			r_ptr <= 0;
		end else if (!w_empty && i_src_ready) begin
			r_ptr <= r_ptr + 1;
		end
	end

	//write buffer
	always @(posedge clk)
	begin
		if (!w_full && i_snk_valid) begin
			mem[w_ptr] <= i_snk_data;
		end
	end
	
	//read buffe
	assign o_src_data = mem[r_ptr];

	wire	w_full;
	assign 	w_full = ((w_ptr + 1 == r_ptr)||((r_ptr == 0) && (w_ptr == p_fifo_length - 1))) ? 1 : 0;
	assign	o_snk_ready = !w_full;

	wire	w_empty;
	assign 	w_empty = (w_ptr == r_ptr)? 1 : 0;
	assign	o_src_valid = !w_empty;
	
	
	
endmodule

`endif
