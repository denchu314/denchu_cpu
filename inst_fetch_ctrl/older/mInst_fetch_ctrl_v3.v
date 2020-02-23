///////////////////////////////////////////
// This modules is in modakio cpu.
// mInst_fetch_ctrl module ver 1.0
// 2019/03/23 writen by denchu
//

`include "../define.v"
//`include "../arb5/mArb5.v"
//`include "../fifo/mFifo.v"

`define	STATE_READY	0
`define	STATE_FETCH	1

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
	
	input	[`MEM_ADDR_BITS-1:0]	i_be_bne_addr,
	input				i_be_bne_valid,
	
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
	
	output				o_fetch_complete,

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
	
	//state machine
	reg	r_state;
	wire	w_ready_to_fetch;
	wire	w_fetch_to_ready;
	
	always @(posedge clk)
	begin
		if(rst) begin
			r_state <= `STATE_READY;
		end else begin
			case (r_state)
				`STATE_READY: if(w_ready_to_fetch) r_state <= `STATE_FETCH;
				`STATE_FETCH: if(w_fetch_to_ready) r_state <= `STATE_READY;
			endcase
		end
	end
	assign	w_ready_to_fetch	= (((i_jr_valid | i_j_valid) | (i_jal_valid | o_inst_empty))| i_be_bne_valid)? 1'b1 : 1'b0;
	assign	w_fetch_to_ready	= (r_inst_counter == `NUM_OF_FETCH_INST)? 1 : 0;
	assign	o_fetch_complete	= w_fetch_to_ready;
	wire	w_state_ready;
	assign	w_state_ready		= (r_state == `STATE_READY)? 1 : 0;

	assign	o_ret_addr_valid	= i_jal_valid;
	

	reg	[`MEM_ADDR_BITS-1:0] 	r_program_counter;
	
	// program_counter
	always @(posedge clk)
	begin
		if(rst) begin
			r_program_counter <= 0;
		end else if (i_jr_valid & w_state_ready) begin
			r_program_counter <= i_jr_addr;
		end else if (i_j_valid & w_state_ready) begin
			r_program_counter <= i_j_addr;
		end else if (i_jal_valid & w_state_ready) begin
			r_program_counter <= i_jal_addr;
		end else if (i_be_bne_valid & w_state_ready) begin
			r_program_counter <= r_program_counter + i_be_bne_addr + (`WORD_BITS >> 3);
		end else if (i_inst_complete) begin
			r_program_counter <= r_program_counter + (`WORD_BITS >> 3);
		end
	end
	
	assign	o_ret_addr	= r_program_counter;

	assign	o_rst_inst_fifo	= (((i_jr_valid | i_j_valid) | (i_jal_valid | rst))| i_be_bne_valid)? 1 : 0;


	// inst counter
	reg	[`MEM_ADDR_BITS-1:0]	r_inst_counter;
	always @(posedge clk)
	begin
		if(rst) begin
			r_inst_counter <= 0;
		end else if (i_jr_valid & w_state_ready) begin
			r_inst_counter <= 0;
		end else if (i_j_valid & w_state_ready) begin
			r_inst_counter <= 0;
		end else if (i_jal_valid & w_state_ready) begin
			r_inst_counter <= 0;
		end else if (i_be_bne_valid & w_state_ready) begin
			r_inst_counter <= 0;
		end else if (i_inst_complete) begin
			r_inst_counter <= r_inst_counter - 1;
		end else if (o_inst_valid) begin
			r_inst_counter <= r_inst_counter + 1;
		end
	end
	
	assign	o_inst_empty = (r_inst_counter == 0)? 1 : 0;

	assign	o_burstcount = `NUM_OF_FETCH_INST * (`WORD_BITS >> 3);	

	wire	[`MEM_ADDR_BITS-1:0]	w_readinst_fifo_in_data;
	wire				w_readinst_fifo_in_valid;

	mArb5 #(
		.p_st_bits	(`MEM_ADDR_BITS)
	) uArb5	(
		.iSnk0Data	(i_jr_addr),
		.iSnk0Valid	(i_jr_valid & w_state_ready),
		.iSnk1Data	(i_j_addr),
		.iSnk1Valid	(i_j_valid & w_state_ready),
		.iSnk2Data	(i_jal_addr),
		.iSnk2Valid	(i_jal_valid & w_state_ready),
		.iSnk3Data	(r_program_counter),
		.iSnk3Valid	(o_inst_empty & w_state_ready),
		.iSnk4Data	(r_program_counter+i_be_bne_addr+(`WORD_BITS>>3)),
		.iSnk4Valid	(i_be_bne_valid & w_state_ready),
		
		.oSrc0Data	(w_readinst_fifo_in_data),
		.oSrc0Valid	(w_readinst_fifo_in_valid),
		
		.rst		(rst),
		.clk		(clk)
	); 
	
	mFifo #(
		.p_st_bits		(`MEM_ADDR_BITS),
		.p_fifo_length 		(8),
		.p_fifo_length_log2 	(3)
	) uReadinst (
		.i_snk_data		(w_readinst_fifo_in_data),
		.i_snk_valid		(w_readinst_fifo_in_valid),
		.o_snk_ready		(),
		
		.o_src_data		(o_addr),
		.o_src_valid		(o_read),
		.i_src_ready		(!i_waitrequest),

		.clk			(clk),
		.rst			(rst)
	);
	
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
