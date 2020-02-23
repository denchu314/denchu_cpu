///////////////////////////////////////////
// This modules is in modakio cpu.
// mDecoder.v module ver 1.0
// 2019/03/12 writen by denchu
//
`ifndef	_mDECODER_
`define	_mDECODER_
`include	"./define.v"

module mDecoder (
	input	[`INST_BITS-1:0]	i_inst,
	input				i_inst_valid,
	
	output				o_jr,

	output	[`WORD_BITS-1:0]	o_jal_addr,
	output				o_jal_addr_valid,
	
	output	[`WORD_BITS-1:0]	o_j_addr,
	output				o_j_addr_valid,

	output				o_write_req,
	output				o_read_req,
	
	output	[`TYPE_BITS-1:0]	o_type,
	output	[`OP_BITS-1:0]		o_op,
	output	[`DST_BITS-1:0]		o_dst,
	output	[`SRC0_BITS-1:0]	o_src0,
	output	[`SRC1_BITS-1:0]	o_src1,
	output	[`MINOR_IMM_BITS-1:0]	o_minor_imm,
	
	input	rst,
	input	clk
); 
	wire   [`MAJOR_IMM_BITS-1:0]	w_major_imm;
	wire   [`SRC1_BITS-1:0]		w_src1;

	assign o_jr		= (((o_type == `TYPE_LR) && (o_op == `OP_JR))  && i_inst_valid)? 1 : 0;
	
	assign o_jal_addr	= w_major_imm;
	assign o_jal_addr_valid	= (((o_type == `TYPE_J)  && (o_op == `OP_JAL)) && i_inst_valid) ? 1 : 0;
	
	assign o_j_addr		= w_major_imm;
	assign o_j_addr_valid	= (((o_type == `TYPE_J)  && (o_op == `OP_J))   && i_inst_valid)? 1 : 0;

	assign o_write_req	= (((o_type == `TYPE_I)  && (o_op == `OP_ST)) && i_inst_valid)? 1 : 0;
	assign o_read_req	= (((o_type == `TYPE_I)  && (o_op == `OP_LW)) && i_inst_valid)? 1 : 0;
	
	assign o_type 		= i_inst[     `TYPE_BITS +      `TYPE_OFFSET - 1:     `TYPE_OFFSET];
	assign o_op 		= i_inst[       `OP_BITS +        `OP_OFFSET - 1:       `OP_OFFSET];
	assign o_dst 		= i_inst[      `DST_BITS +       `DST_OFFSET - 1:      `DST_OFFSET];
	assign o_src0 		= i_inst[     `SRC0_BITS +      `SRC0_OFFSET - 1:     `SRC0_OFFSET];
	assign w_src1 		= i_inst[     `SRC1_BITS +      `SRC1_OFFSET - 1:     `SRC1_OFFSET];
	assign o_src1 		= (((o_type == `TYPE_I)&&(o_op == `OP_ST))||((o_type == `TYPE_I)&&(o_op == `OP_BE)))||((o_type == `TYPE_I)&&(o_op == `OP_BNE)) ? o_dst : w_src1;
	assign o_minor_imm 	= i_inst[`MINOR_IMM_BITS + `MINOR_IMM_OFFSET - 1:`MINOR_IMM_OFFSET];
	assign w_major_imm 	= i_inst[`MAJOR_IMM_BITS + `MAJOR_IMM_OFFSET - 1:`MAJOR_IMM_OFFSET];

endmodule

`endif
