///////////////////////////////////////////
// This modules is in modakio cpu.
// mInst_fetch_ctrl module ver 1.0
// 2019/03/23 writen by denchu
//

`include "../define.v"
`include "../lib/mOnehot_sender.v"
`include "../lib/mArb.v"

module mInst_fetch_ctrl #(
	parameter	p_fifo_length 		= 8,
	parameter	p_fifo_length_log2 	= 3
)(
	//To cpu
	output	[`MEM_ADDR_BITS-1:0]	o_ret_addr,
	output				o_ret_addr_valid,

	input	[`MEM_ADDR_BITS-1:0]	i_jr_addr,
	input				i_jr_valid,

	input	[`MEM_ADDR_BITS-1:0]	i_j_addr,
	input				i_j_valid,
	
	input	[`MEM_ADDR_BITS-1:0]	i_jal_addr,
	input				i_jal_valid,
	
	output	[`WORD_BITS-1:0]	o_inst,
	output				o_inst_valid,
	
	output				o_rst_inst_fifo,
	
	input				i_inst_complete,

	output				o_inst_empty,

	// To memory	
	output	[`WORD_BITS-1:0]	o_burstcount,
	output	[`MEM_ADDR_BITS-1:0]	o_addr,
	output				o_read,
	input				i_waitrequest,
	input	[`WORD_BITS-1:0]	i_readdata,
	input				i_readdatavalid,
	

	input				clk,
	input				rst

);
	//function integer log2;
        //input integer num;
        //	begin
        //		num = num - 1;
        //	for (log2 = 0; num > 0; log2 = log2 + 1)
        //		num = num >> 1;
        //	end
        //endfunction

	assign	o_ret_addr_valid	= i_jal_valid;

	reg	[`MEM_ADDR_BITS-1:0] 	r_program_counter;
	wire	[`MEM_ADDR_BITS-1:0]	w_addr;
	wire				w_addr_valid;
	
	// program_counter
	always @(posedge clk)
	begin
		if(rst) begin
			r_program_counter <= 0;
		end else if (w_addr_valid) begin
			r_program_counter <= w_addr;
		end else if (i_inst_complete) begin
			r_program_counter <= r_program_counter + (`WORD_BITS << 3);
		end
	end
	
	assign	o_ret_addr	= r_program_counter;

	mArb #(
		.p_st_bits	(`MEM_ADDR_BITS)
	)uArb(
		.iSnk0Data	(i_jr_addr),
		.iSnk0Valid	(i_jr_valid),
		.iSnk1Data	(i_j_addr),
		.iSnk1Valid	(i_j_valid),
		.iSnk2Data	(i_jal_addr),
		.iSnk2Valid	(i_jal_valid),
		
		.oSrc0Data	(w_addr),
		.oSrc0Valid	(w_addr_valid),
		
		.rst		(rst),
		.clk		(clk)
	); 
	assign	o_rst_inst_fifo	= ((i_jr_valid | i_j_valid) | i_jal_valid);

	wire	w_onehot_sender_out;

	mFifo #(
		.p_st_bits		(`MEM_ADDR_BITS),
		.p_fifo_length 		(8),
		.p_fifo_length_log2 	(3)
	) uReadinst (
		.i_snk_data		(r_program_counter),
		.i_snk_valid		(w_onehot_sender_out),
		.o_snk_ready		(),
		
		.o_src_data		(o_addr),
		.o_src_valid		(o_read),
		.i_src_ready		(!i_waitrequest),

		.clk			(clk),
		.rst			(rst)

	);

	wire	w_inst_empty;

	mOnehot_sender uOnehot_sender (
	.in	(w_inst_empty),
	.out	(w_onehot_sender_out),

	.clk	(clk),
	.rst	(rst)

);

	// inst counter
	
	reg	[`WORD_BITS-1:0]	r_inst_counter = {`WORD_BITS{1'b1}};
	always @(posedge clk)
	begin
		if(rst | o_rst_inst_fifo) begin
			r_inst_counter <= 0;
		end else if (o_inst_valid) begin
			r_inst_counter <= r_inst_counter + 1;
		end else if (i_inst_complete) begin
			r_inst_counter <= r_inst_counter - 1;
		end
	end
	assign	w_inst_empty = (r_inst_counter == 0)? 1 : 0;
	assign	o_inst_empty = w_inst_empty;

	assign	o_burstcount = (`WORD_BITS >> 3);	

	mFifo #(
		.p_st_bits		(`WORD_BITS),
		.p_fifo_length 		(8),
		.p_fifo_length_log2 	(3)
	) uReaddata (
		.i_snk_data		(i_readdata),
		.i_snk_valid		(i_readdatavalid),
		.o_snk_ready		(),
		
		.o_src_data		(o_inst),
		.o_src_valid		(o_inst_valid),
		.i_src_ready		(1'b1),

		.clk			(clk),
		.rst			(rst)

	);

		
endmodule
