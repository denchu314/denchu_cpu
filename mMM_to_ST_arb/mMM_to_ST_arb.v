///////////////////////////////////////////
// This modules is in modakio cpu.
// mMM_to_ST_arb.v module ver 1.0
// 2019/03/17 writen by denchu
//
`ifndef	_mMM_TO_ST_ARB_
`define	_mMM_TO_ST_ARB_
`include "./define.v"

module mMM_to_ST_arb #(
	parameter	p_st_bits		= `WORD_BITS,
	parameter	p_addr_bits 		= `MEM_ADDR_BITS,
	parameter	p_fifo_length 		= 8,
	parameter	p_fifo_length_log2 	= 3
)(
	input	[p_st_bits-1:0]		i_writedata,
	input	[p_addr_bits-1:0]	i_addr,
	input				i_read_req,
	input				i_write_req,
	input				i_lwst_start,

	output	[p_st_bits-1:0]		o_readdata,
	output				o_valid,
	
	output				o_write_mem_complete,
	output				o_read_mem_complete,
	
	output	[p_st_bits-1:0]		o_writedata,
	output				o_write,
	output	[p_addr_bits-1:0]	o_addr,
	output				o_read,
	input	[p_st_bits-1:0]		i_readdata,
	input				i_readdatavalid,
	input				i_waitrequest,

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

	wire	[p_st_bits+p_addr_bits+2-1:0]	w_inst_fifo_in;
	//assign	w_inst_fifo_in = {i_writedata, i_addr, i_read_req, i_write_req};
	assign	w_inst_fifo_in[p_st_bits+p_addr_bits+2-1:p_addr_bits	+2] = i_writedata;
	assign	w_inst_fifo_in[		 p_addr_bits+2-1:		 2] = i_addr;
	assign	w_inst_fifo_in[1] = i_read_req;
	assign	w_inst_fifo_in[0] = (i_read_req == 1'b0)? i_write_req : 1'b0;

	mFifo #(
		.p_st_bits		(p_st_bits+p_addr_bits+2),
		.p_fifo_length 		(p_fifo_length),
		.p_fifo_length_log2 	(p_fifo_length_log2)
	) uInstFifo (
		.i_snk_data		(w_inst_fifo_in),
		.i_snk_valid		(i_lwst_start & (i_read_req | i_write_req)),
		.o_snk_ready		(),
		
		.o_src_data		(w_inst_fifo_out),
		.o_src_valid		(w_inst_fifo_valid_out),
		.i_src_ready		(!i_waitrequest),

		.clk			(clk),
		.rst			(rst)

	);
	
	wire	w_inst_fifo_valid_out;
	wire	[p_st_bits+p_addr_bits+2-1:0]	w_inst_fifo_out;
	assign	o_writedata 	= w_inst_fifo_out[p_st_bits+p_addr_bits+2-1:p_addr_bits+2];
	assign	o_addr		= w_inst_fifo_out[p_addr_bits+2-1:2];
	assign	o_read		= (w_inst_fifo_valid_out == 1'b1)? w_inst_fifo_out[1] : 1'b0;
	assign	o_write		= (w_inst_fifo_valid_out == 1'b1)? w_inst_fifo_out[0] : 1'b0;
	
	assign o_write_mem_complete = o_write & !i_waitrequest & !rst;
	assign o_read_mem_complete = i_readdatavalid & !i_waitrequest & !rst;

	mFifo #(
		.p_st_bits		(p_st_bits),
		.p_fifo_length 		(p_fifo_length),
		.p_fifo_length_log2 	(p_fifo_length_log2)
	) uReaddata (
		.i_snk_data		(i_readdata),
		.i_snk_valid		(i_readdatavalid),
		.o_snk_ready		(),
		
		.o_src_data		(o_readdata),
		.o_src_valid		(o_valid),
		.i_src_ready		(1'b1),

		.clk			(clk),
		.rst			(rst)

	);
	
	
endmodule

`endif
