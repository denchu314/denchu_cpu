///////////////////////////////////////////
// This modules is in modakio cpu.
// mCpu_top module ver 1.0
// 2019/05/01 writen by denchu
//

`include	"../define.v"
`include	"../alu/mAlu.v"
`include	"../arb3/mArb3.v"
`include	"../arb5/mArb5.v"
`include	"../cpu_ctrl/mCpu_ctrl.v"
`include	"../decoder/mDecoder.v"
//`include	"../fifo/mFifo.v"
`include	"../inst_fetch_ctrl/mInst_fetch_ctrl.v"
`include	"../mMM_to_ST_arb/mMM_to_ST_arb.v"
`include	"../mux/mMux.v"
`include	"../reg/mRegister.v"



module mCpu_top (
	// To memory(data)
	output	[`WORD_BITS-1:0]	o_data_writedata,
	output				o_data_write,
	output	[`MEM_ADDR_BITS-1:0]	o_data_addr,
	output				o_data_read,
	input	[`WORD_BITS-1:0]	i_data_readdata,
	input				i_data_readdatavalid,
	input				i_data_waitrequest,

	// To memory(instruction)
	output	[`WORD_BITS-1:0]	o_inst_burstcount,
	output	[`MEM_ADDR_BITS-1:0]	o_inst_addr,
	output				o_inst_read,
	input				i_inst_waitrequest,
	input	[`WORD_BITS-1:0]	i_inst_readdata,
	input				i_inst_readdatavalid,

	// To control	
	input	[`WORD_BITS-1:0]	i_status_writedata,
	input	[`WORD_BITS-1:0]	o_status_readdata,
	input				o_status_readdatavalid,
	input	[1:0]			i_status_addr,
	input				i_status_read,
	input				i_status_write,

	input				clk,
	input				rst
);
	wire	[`WORD_BITS-1:0]	w_alu_result_val;
	wire	[`WORD_BITS-1:0]	w_alu_result_valid;
	mAlu uAlu (
		.i_operand_0_val	(w_reg_src0),
		.i_operand_1_val	(w_mux_oOut),
		.o_result_val		(w_alu_result_val),
		.o_result_valid		(w_alu_result_valid),
		
		.i_type			(w_decoder_type),
		.i_op			(w_decoder_op),
		.i_calc_start		(w_cpu_ctrl_calc_start),

		.clk			(clk),
		.rst			(rst)
	);
	
	wire	w_type_is_i;
	assign	w_type_is_i	= (w_decoder_type == `TYPE_I)? 1'b1 : 1'b0;
	wire	[`WORD_BITS-1:0]	w_mux_oOut;

	mMux #(
		.pStreamBits		(`WORD_BITS)
	) uMux (
		.sel			(w_type_is_i),
		.iIn0			(w_reg_src1),
		.iIn1			(w_decoder_minor_imm),
		.oOut			(w_mux_oOut)
	);
	
	wire	[`WORD_BITS-1:0]	w_reg_src0;
	wire	[`WORD_BITS-1:0]	w_reg_src1;
	
	mRegister uRegister (
		.iDstAddr		(w_decoder_dst),
		.iSrc0Addr		(w_decoder_src0),
		.iSrc1Addr		(w_decoder_src1),
		
		.iDstVal		(w_arb3_data),
		.iDstValid		(w_arb3_valid),
		
		.oSrc0Val		(w_reg_src0),
		.oSrc1Val		(w_reg_src1),
		
		.rst			(rst),
		.clk			(clk)
	);

	wire	[`WORD_BITS-1:0]	w_arb3_data;
	wire				w_arb3_valid;
	
	mArb3 uArb3(
		.iSnk0Data		(w_alu_result_val),
		.iSnk0Valid		(w_alu_result_valid),
		.iSnk1Data		(w_mm_to_st_readdata),
		.iSnk1Valid		(w_mm_to_st_readdata_valid),
		.iSnk2Data		(w_inst_fetch_ctrl_ret_addr),
		.iSnk2Valid		(w_inst_fetch_ctrl_ret_addr_valid),
		
		.oSrc0Data		(w_arb3_data),
		.oSrc0Valid		(w_arb3_valid),
		
		.rst			(rst),
		.clk			(clk)
	); 

	wire	[`TYPE_BITS-1:0]	w_decoder_type;
	wire	[`OP_BITS-1:0]		w_decoder_op;
	wire	[`MINOR_IMM_BITS-1:0]	w_decoder_minor_imm;
	wire	[`DST_BITS-1:0]		w_decoder_dst;
	wire	[`SRC0_BITS-1:0]	w_decoder_src0;
	wire	[`SRC1_BITS-1:0]	w_decoder_src1;
	wire				w_decoder_write_req;
	wire				w_decoder_read_req;

	wire	[`WORD_BITS-1:0]	w_decoder_j_addr;
	wire				w_decoder_j_addr_valid;
	wire	[`WORD_BITS-1:0]	w_decoder_jal_addr;
	wire				w_decoder_jal_addr_valid;
	wire				w_decoder_jr_addr_valid;
	mDecoder uDecoder (	
		.i_inst			(w_fifo_inst),
		.i_inst_valid		(w_fifo_inst_valid),
		
		.o_jr			(w_decoder_jr_addr_valid),

		.o_jal_addr		(w_decoder_jal_addr),
		.o_jal_addr_valid	(w_decoder_jal_addr_valid),
		
		.o_j_addr		(w_decoder_j_addr),
		.o_j_addr_valid		(w_decoder_j_addr_valid),

		.o_write_req		(w_decoder_write_req),
		.o_read_req		(w_decoder_read_req),
		
		.o_type			(w_decoder_type),
		.o_op			(w_decoder_op),
		.o_dst			(w_decoder_dst),
		.o_src0			(w_decoder_src0),
		.o_src1			(w_decoder_src1),
		.o_minor_imm		(w_decoder_minor_imm),
		
		.rst			(rst),
		.clk			(clk)
	);
	
	wire				w_cpu_ctrl_calc_start;
	wire				w_cpu_ctrl_inst_complete;
	wire				w_cpu_ctrl_be_bne;

	mCpu_ctrl uCpu_ctrl(
		.o_inst_complete	(w_cpu_ctrl_inst_complete),
		.i_empty		(w_inst_fetch_ctrl_empty),
		.i_fetch_complete	(w_inst_fetch_ctrl_fetch_complete),

		.i_inst			(w_fifo_inst),
		.i_inst_valid		(w_fifo_inst_valid),
		
		.i_write_mem_complete	(w_mm_to_st_write_mem_complete),
		.i_read_mem_complete	(w_mm_to_st_read_mem_complete),

		.o_calc_start		(w_cpu_ctrl_calc_start),
		.i_calc_complete	(w_alu_result_valid),
		.i_src0			(w_reg_src0),
		.i_src1			(w_reg_src1),
		.o_be_bne		(w_cpu_ctrl_be_bne),
		
		.i_writedata		(i_status_writedata),
		.o_readdata		(o_status_readdata),
		.o_readdatavalid	(o_status_readdatavalid),
		.i_addr			(i_status_addr),
		.i_read			(i_status_read),
		.i_write		(i_status_write),

		.clk			(clk),
		.rst			(rst)
	);

	wire	[`WORD_BITS-1:0]	w_inst_fetch_ctrl_ret_addr;
	wire				w_inst_fetch_ctrl_ret_addr_valid;
	wire				w_inst_fetch_ctrl_empty;
	wire				w_inst_fetch_ctrl_fetch_complete;
	wire	[`WORD_BITS-1:0]	w_inst_fetch_ctrl_inst;
	wire				w_inst_fetch_ctrl_inst_valid;
	wire				w_inst_fetch_ctrl_rst_fifo;

	mInst_fetch_ctrl #(
		.p_fifo_length 		(8),
		.p_fifo_length_log2 	(3)
	) uInst_fetch_ctrl (
		.o_ret_addr		(w_inst_fetch_ctrl_ret_addr),
		.o_ret_addr_valid	(w_inst_fetch_ctrl_ret_addr_valid),
	
		.i_jr_addr		(w_reg_src0),
		.i_jr_valid		(w_decoder_jr_addr_valid),
	
		.i_j_addr		(w_decoder_j_addr),
		.i_j_valid		(w_decoder_j_addr_valid),
		
		.i_jal_addr		(w_decoder_jal_addr),
		.i_jal_valid		(w_decoder_jal_addr_valid),
	
		.i_be_bne_addr		(w_decoder_minor_imm),
		.i_be_bne_valid		(w_cpu_ctrl_be_bne),
		
		.o_inst			(w_inst_fetch_ctrl_inst),
		.o_inst_valid		(w_inst_fetch_ctrl_inst_valid),
		
		.o_rst_inst_fifo	(w_inst_fetch_ctrl_rst_fifo),
		
		.i_inst_complete	(w_cpu_ctrl_inst_complete),
	
		.o_inst_empty		(w_inst_fetch_ctrl_empty),
		
		.o_burstcount		(o_inst_burstcount),
		.o_addr			(o_inst_addr),
		.o_read			(o_inst_read),
		.i_waitrequest		(i_inst_waitrequest),
		.i_readdata		(i_inst_readdata),
		.i_readdatavalid	(i_inst_readdatavalid),

		.o_fetch_complete	(w_inst_fetch_ctrl_fetch_complete),
	
		.clk			(clk),
		.rst			(rst)
	);

	wire	[`WORD_BITS-1:0]	w_mm_to_st_readdata;
	wire				w_mm_to_st_readdata_valid;
	wire				w_mm_to_st_write_mem_complete;
	wire				w_mm_to_st_read_mem_complete;
	wire	[`WORD_BITS-1:0]	w_minor_imm_plus_reg_src0;
	assign w_minor_imm_plus_src0	= w_decoder_minor_imm + w_reg_src0; 

	mMM_to_ST_arb #(
		.p_st_bits		(`WORD_BITS),
		.p_addr_bits 		(`MEM_ADDR_BITS),
		.p_fifo_length 		(8),
		.p_fifo_length_log2 	(3)
	) uMM_to_ST_arb (
		.i_writedata		(w_reg_src1),
		.i_addr			(w_minor_imm_plus_reg_src0),

		.i_read_req		(w_decoder_read_req),
		.i_write_req		(w_decoder_write_req),
		
		.o_readdata		(w_mm_to_st_readdata),
		.o_valid		(w_mm_to_st_readdata_valid),
		
		.o_write_mem_complete	(w_mm_to_st_write_mem_complete),
		.o_read_mem_complete	(w_mm_to_st_read_mem_complete),
		
		.o_writedata		(o_data_writedata),
		.o_write		(o_data_write),
		.o_addr			(o_data_addr),
		.o_read			(o_data_read),
		.i_readdata		(i_data_readdata),
		.i_readdatavalid	(i_data_readdatavalid),
		.i_waitrequest		(i_data_waitrequest),

		.clk			(clk),
		.rst			(rst)
	);

	wire	[`WORD_BITS-1:0]	w_fifo_inst;	
	wire				w_fifo_inst_valid;	

	mFifo #(
		.p_st_bits		(`WORD_BITS),
		.p_fifo_length 		(8),
		.p_fifo_length_log2 	(3)
	) uFifo (
		.i_snk_data		(w_inst_fetch_ctrl_inst),
		.i_snk_valid		(w_inst_fetch_ctrl_inst_valid),
		.o_snk_ready		(),
		
		.o_src_data		(w_fifo_inst),
		.o_src_valid		(w_fifo_inst_valid),
		.i_src_ready		(w_cpu_ctrl_inst_complete),

		.clk			(clk),
		.rst			(rst | w_inst_fetch_ctrl_rst_fifo)

	);

endmodule
