///////////////////////////////////////////
// This modules is in modakio cpu.
// mInst_fetch_ctrl module ver 1.0
// 2019/03/23 writen by denchu
//
`ifndef	_mINST_FETCH_CTRL_
`define	_mINST_FETCH_CTRL_
`include "./define.v"
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
	
	input				i_inst_complete,

	output				o_inst_empty,
	
	input				i_permit_fetch,
	
	output				o_rst_inst_fifo,
	//input				i_jump_enable,

	// To memory	
	output	[`WORD_BITS-1:0]	o_burstcount,
	output	[`MEM_ADDR_BITS-1:0]	o_addr,
	output				o_read,
	input				i_waitrequest,
	input	[`WORD_BITS-1:0]	i_readdata,
	input				i_readdatavalid,
	
	output				o_fetch_complete,

	input				i_shadow_switch,
	input	[`WORD_BITS-1:0]	i_intr_addr,
	
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

	assign	o_ret_addr_valid	= w_jal_valid;
	

	reg	[`MEM_ADDR_BITS-1:0] 	r_program_counter_front;
	reg	[`MEM_ADDR_BITS-1:0] 	r_program_counter_shadow;
	wire	w_be_bne_valid;
	wire	w_jr_valid;
	wire	w_j_valid;
	wire	w_jal_valid;

	//assign	w_be_bne_valid 	= i_be_bne_valid	& i_jump_enable;
	//assign	w_jr_valid  	= i_jr_valid 		& i_jump_enable;
	//assign	w_j_valid	= i_j_valid 		& i_jump_enable;
	//assign	w_jal_valid 	= i_jal_valid 		& i_jump_enable;
	assign	w_be_bne_valid 	= i_be_bne_valid;
	assign	w_jr_valid  	= i_jr_valid 	;
	assign	w_j_valid	= i_j_valid 	;
	assign	w_jal_valid 	= i_jal_valid 	;

	// program_counter front
	always @(posedge clk)
	begin
		if(rst) begin
			r_program_counter_front <= 0;
		end else if (w_jr_valid 	& !i_shadow_switch) begin
			r_program_counter_front <= i_jr_addr;
		end else if (w_j_valid 		& !i_shadow_switch) begin
			r_program_counter_front <= i_j_addr;
		end else if (w_jal_valid 	& !i_shadow_switch) begin
			r_program_counter_front <= i_jal_addr;
		end else if (w_be_bne_valid 	& !i_shadow_switch) begin
			r_program_counter_front <= r_program_counter_front + i_be_bne_addr + (`WORD_BITS / `BITS_PER_BYTE);
		end else if (i_permit_fetch 	& !i_shadow_switch) begin
			r_program_counter_front <= r_program_counter_front + (`WORD_BITS / `BITS_PER_BYTE);
		end
	end
	
	// program_counter shadow
	always @(posedge clk)
	begin
		if(rst) begin
			r_program_counter_shadow <= 0;
		end else if (w_jr_valid		& i_shadow_switch) begin
			r_program_counter_shadow <= i_jr_addr;
		end else if (w_j_valid		& i_shadow_switch) begin
			r_program_counter_shadow <= i_j_addr;
		end else if (w_jal_valid	& i_shadow_switch) begin
			r_program_counter_shadow <= i_jal_addr;
		end else if (w_be_bne_valid	& i_shadow_switch) begin
			r_program_counter_shadow <= r_program_counter_shadow + i_be_bne_addr + (`WORD_BITS / `BITS_PER_BYTE);
		end else if (i_permit_fetch	& i_shadow_switch) begin
			r_program_counter_shadow <= r_program_counter_shadow + (`WORD_BITS / `BITS_PER_BYTE);
		end
	end
	
	wire	[`MEM_ADDR_BITS-1:0]	w_program_counter;
	assign				w_program_counter	= (i_shadow_switch)? r_program_counter_shadow : r_program_counter_front;
	assign				o_ret_addr 		= w_program_counter;


	// inst counter
	reg	[`MEM_ADDR_BITS-1:0]	r_inst_counter;
	always @(posedge clk)
	begin
		if(rst) begin
			r_inst_counter <= 0;
		end else if (w_jr_valid) begin
			r_inst_counter <= 0;
		end else if (w_j_valid) begin
			r_inst_counter <= 0;
		end else if (w_jal_valid) begin
			r_inst_counter <= 0;
		end else if (w_be_bne_valid) begin
			r_inst_counter <= 0;
		end else if (i_inst_complete) begin
			r_inst_counter <= r_inst_counter - 1;
		end else if (o_inst_valid) begin
			r_inst_counter <= r_inst_counter + 1;
		end
	end
	
	assign	o_inst_empty = (r_inst_counter == 0)? 1 : 0;
	assign	o_fetch_complete = (r_inst_counter == `NUM_OF_FETCH_INST)? 1 : 0;

	assign	o_burstcount = 1;	
	//assign	o_burstcount = `NUM_OF_FETCH_INST * (`WORD_BITS / `BITS_PER_BYTE);	
	assign	o_rst_inst_fifo = ((w_be_bne_valid|w_jr_valid)|(w_j_valid|w_jal_valid));

	wire	[`MEM_ADDR_BITS-1:0]	w_readinst_fifo_in_data;
	wire				w_readinst_fifo_in_valid;


	mArb5 #(
		.p_st_bits	(`MEM_ADDR_BITS)
	) uArb5	(
		.iSnk0Data	(i_jr_addr),
		.iSnk0Valid	(w_jr_valid & i_permit_fetch),
		.iSnk1Data	(i_j_addr),
		.iSnk1Valid	(w_j_valid & i_permit_fetch),
		.iSnk2Data	(i_jal_addr),
		.iSnk2Valid	(w_jal_valid & i_permit_fetch),
		.iSnk3Data	(w_program_counter),
		.iSnk3Valid	(i_permit_fetch),
		//.iSnk3Valid	(o_inst_empty & i_permit_fetch),
		.iSnk4Data	(w_program_counter+i_be_bne_addr+(`WORD_BITS>>3)),
		.iSnk4Valid	(w_be_bne_valid & i_permit_fetch),
		
		.oSrc0Data	(w_readinst_fifo_in_data),
		.oSrc0Valid	(w_readinst_fifo_in_valid),
		
		.rst		(rst),
		.clk		(clk)
	); 
	
	mFifo #(
		.p_st_bits		(`MEM_ADDR_BITS),
		.p_fifo_length 		(8),
		.p_fifo_length_log2 	(3)
	) uReadinst_front (
		.i_snk_data		(w_readinst_fifo_in_data),
		.i_snk_valid		(w_readinst_fifo_in_valid & !i_shadow_switch),
		.o_snk_ready		(),
		
		.o_src_data		(w_addr_front),
		.o_src_valid		(w_read_front),
		.i_src_ready		(!i_waitrequest & !i_shadow_switch),

		.clk			(clk),
		.rst			(rst | o_rst_inst_fifo)
	);

	mFifo #(
		.p_st_bits		(`MEM_ADDR_BITS),
		.p_fifo_length 		(8),
		.p_fifo_length_log2 	(3)
	) uReadinst_shadow (
		.i_snk_data		(w_readinst_fifo_in_data),
		.i_snk_valid		(w_readinst_fifo_in_valid & i_shadow_switch),
		.o_snk_ready		(),
		
		.o_src_data		(w_addr_shadow),
		.o_src_valid		(w_read_shadow),
		.i_src_ready		(!i_waitrequest & i_shadow_switch),

		.clk			(clk),
		.rst			(rst | o_rst_inst_fifo)
	);

	wire	[`MEM_ADDR_BITS-1:0]	w_addr_front;
	wire				w_read_front;

	wire	[`MEM_ADDR_BITS-1:0]	w_addr_shadow;
	wire				w_read_shadow;

	assign	o_addr	= (i_shadow_switch)? w_addr_shadow : w_addr_front;
	assign	o_read	= (i_shadow_switch)? w_read_shadow : w_read_front;

	reg	[7:0]	reading_inst_counter;
	always @(posedge clk)
	begin
		if (rst) begin
			reading_inst_counter <= 0;	
		end else if (o_read & i_readdatavalid)begin
			reading_inst_counter <= reading_inst_counter;
		end else if (o_read & !i_waitrequest)begin
			reading_inst_counter <= reading_inst_counter + 1;
		end else if (i_readdatavalid) begin	
			reading_inst_counter <= reading_inst_counter - 1;
		end
	end
	
	wire	w_readdata_fifo_reset;
	reg	r_flash_flag;
	wire	w_flash_enable_trigger;
	wire	w_flash_disable_trigger;
	
	assign	w_flash_enable_trigger = o_rst_inst_fifo;
	assign	w_flash_disable_trigger = (reading_inst_counter == 1 && (i_readdatavalid == 1 && o_read == 0))? 1 : 0;
	
	always @(posedge clk)
	begin
		if (rst) begin
			r_flash_flag <= 0;	
		end else if (w_flash_enable_trigger)begin
			r_flash_flag <= 1;
		end else if (w_flash_disable_trigger) begin	
			r_flash_flag <= 0;
		end
	end
	
	assign	w_readdata_fifo_reset = r_flash_flag;

	wire	[`WORD_BITS-1:0]	w_inst_front;
	wire				w_inst_valid_front;
	wire	[`WORD_BITS-1:0]	w_inst_shadow;
	wire				w_inst_valid_shadow;

	mFifo #(
		.p_st_bits		(`WORD_BITS),
		.p_fifo_length 		(8),
		.p_fifo_length_log2 	(3)
	) uReaddata_front (
		.i_snk_data		(i_readdata),
		.i_snk_valid		(i_readdatavalid & !i_shadow_switch),
		.o_snk_ready		(),
		
		.o_src_data		(w_inst_front),
		.o_src_valid		(w_inst_valid_front),
		.i_src_ready		(1'b1 & !i_shadow_switch),

		.clk			(clk),
		.rst			(rst | (o_rst_inst_fifo | r_flash_flag))
	);

	mFifo #(
		.p_st_bits		(`WORD_BITS),
		.p_fifo_length 		(8),
		.p_fifo_length_log2 	(3)
	) uReaddata_shadow (
		.i_snk_data		(i_readdata),
		.i_snk_valid		(i_readdatavalid & i_shadow_switch),
		.o_snk_ready		(),
		
		.o_src_data		(w_inst_shadow),
		.o_src_valid		(w_inst_valid_shadow),
		.i_src_ready		(1'b1 & i_shadow_switch),

		.clk			(clk),
		.rst			(rst | (o_rst_inst_fifo | r_flash_flag))
	);

	assign o_inst		= (i_shadow_switch)? w_inst_shadow 		: w_inst_front;
	assign o_inst_valid	= (i_shadow_switch)? w_inst_valid_shadow 	: w_inst_valid_front;
		
endmodule

`endif
