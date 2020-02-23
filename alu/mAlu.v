///////////////////////////////////////////
// This modules is in modakio cpu.
// mALUx module ver 1.0
// 2018/05/05 writen by dtanaka
//
`ifndef _mALU_
`define _mALU_
`include "./define.v"

module mAlu (
	input	[`WORD_BITS-1:0]	i_operand_0_val,
	input	[`WORD_BITS-1:0]	i_operand_1_val,
	output	[`WORD_BITS-1:0]	o_result_val,
	output				o_result_valid,
	
	input	[`TYPE_BITS-1:0]	i_type,
	input	[`OP_BITS-1:0]		i_op,
	input				i_calc_start,

	input				clk,
	input				rst
	);

	reg	[`WORD_BITS-1:0]	r_result_val;
	reg				r_result_valid;	

	wire	[`WORD_BITS-1:0]	w_cr_result	[(1<<`OP_BITS)-1:0];
	wire	[`WORD_BITS-1:0]	w_lr_result	[(1<<`OP_BITS)-1:0];
	wire	[`WORD_BITS-1:0]	w_i_result	[(1<<`OP_BITS)-1:0];
	wire	[`WORD_BITS-1:0]	w_j_result	[(1<<`OP_BITS)-1:0];
	
	//
	// calc reg
	//

	// OP_IADD
	assign	w_cr_result[`OP_IADD]	= i_operand_0_val + i_operand_1_val;
	
	// OP_UIADD
	assign	w_cr_result[`OP_UIADD]	= i_operand_0_val + i_operand_1_val;
	
	// OP_ISUB
	assign	w_cr_result[`OP_ISUB] 	= i_operand_0_val - i_operand_1_val;
	
	// OP_UISUB
	assign	w_cr_result[`OP_UISUB] 	= i_operand_0_val - i_operand_1_val;
	
	// OP_IMUL
	assign	w_cr_result[`OP_IMUL] 	= i_operand_0_val * i_operand_1_val;
	
	// OP_UIMUL
	assign	w_cr_result[`OP_UIMUL] 	= i_operand_0_val * i_operand_1_val;
	
	// OP_IDEV
	wire	w_operand_0_minus;
	wire	w_operand_1_minus;
	assign	w_operand_0_minus = i_operand_0_val[`WORD_BITS-1];
	assign	w_operand_1_minus = i_operand_1_val[`WORD_BITS-1];

	wire	[`WORD_BITS-1:0]	w_idev_operand_0_med;
	wire	[`WORD_BITS-1:0]	w_idev_operand_1_med;
	wire	[`WORD_BITS-1:0]	w_idev_result_med;

	assign	w_idev_operand_0_med 	= (w_operand_0_minus == 1'b1)? ~i_operand_0_val + 1 : i_operand_0_val;
	assign	w_idev_operand_1_med 	= (w_operand_1_minus == 1'b1)? ~i_operand_1_val + 1 : i_operand_1_val;
	assign	w_idev_result_med	=  w_idev_operand_0_med / w_idev_operand_1_med;
	assign	w_cr_result[`OP_IDEV]	= ((w_operand_0_minus ^ w_operand_1_minus) ==1'b1) ? ~w_idev_result_med + 1 : w_idev_result_med;
	
	// OP_UIDEV
	assign	w_cr_result[`OP_UIDEV] 	= i_operand_0_val / i_operand_1_val;
	
	// OP_FADD
	assign	w_cr_result[`OP_FADD] 	= 0;
	
	// OP_FCMP
	assign	w_cr_result[`OP_FCMP] 	= 0;
	
	// OP_FSUB
	assign	w_cr_result[`OP_FSUB] 	= 0;
	
	// NO USE
	assign	w_cr_result[`OP_CR_NOUSE11] 	= 0;
	
	// OP_FMUL
	assign	w_cr_result[`OP_FMUL] 	= 0;
	
	// NO USE
	assign	w_cr_result[`OP_CR_NOUSE13] 	= 0;

	// OP_FDEV
	assign	w_cr_result[`OP_FDEV] 	= 0;
	
	// NO USE
	assign	w_cr_result[`OP_CR_NOUSE15] 	= 0;
	
	//
	// logic reg
	//
	
	// OP_AND
	assign	w_lr_result[`OP_AND] 	= i_operand_0_val & i_operand_1_val;
	
	// OP_OR
	assign	w_lr_result[`OP_OR] 	= i_operand_0_val | i_operand_1_val;
	
	// OP_XOR
	assign	w_lr_result[`OP_XOR]	= i_operand_0_val ^ i_operand_1_val;
	
	// OP_UCMP
	assign	w_lr_result[`OP_UCMP] 	= (i_operand_0_val > i_operand_1_val)? 1 : 0;
	
	// OP_LSFT
	assign	w_lr_result[`OP_LSFT] 	= i_operand_0_val << i_operand_1_val;
	
	// OP_RSFT
	assign	w_lr_result[`OP_RSFT] 	= i_operand_0_val >> i_operand_1_val;
	
	// OP_CMP
	assign	w_lr_result[`OP_CMP] 	= ((i_operand_0_val[`WORD_BITS-1] == 1'b1) && (i_operand_1_val[`WORD_BITS-1] == 1'b0))? 0 :
				  	  ((i_operand_0_val[`WORD_BITS-1] == 1'b0) && (i_operand_1_val[`WORD_BITS-1] == 1'b1))? 1 :
				          (i_operand_0_val > i_operand_1_val)? 1 : 0;
	
	// OP_JR
	assign	w_lr_result[`OP_JR] 		= 0;
	
	//OP_LR_NOUSE8	8
	assign	w_lr_result[`OP_LR_NOUSE8] 	= 0;
	
	//OP_LR_NOUSE9	9
	assign	w_lr_result[`OP_LR_NOUSE9] 	= 0;
	
	//OP_LR_NOUSE10	10
	assign	w_lr_result[`OP_LR_NOUSE10] 	= 0;
	
	//OP_LR_NOUSE11	11
	assign	w_lr_result[`OP_LR_NOUSE11] 	= 0;
	
	//OP_LR_NOUSE12	12
	assign	w_lr_result[`OP_LR_NOUSE12] 	= 0;
	
	//OP_LR_NOUSE13	13
	assign	w_lr_result[`OP_LR_NOUSE13] 	= 0;
	
	//OP_LR_NOUSE14	14
	assign	w_lr_result[`OP_LR_NOUSE14] 	= 0;
	
	//OP_LR_NOUSE15	15
	assign	w_lr_result[`OP_LR_NOUSE15] 	= 0;

	//
	// Immediate
	//
	
	// OP_IADDI
	assign	w_i_result[`OP_IADDI] 		= w_cr_result[`OP_IADD];
	
	// OP_UIADDI
	assign	w_i_result[`OP_UIADDI] 		= w_cr_result[`OP_UIADD];
	
	// OP_ISUBI
	assign	w_i_result[`OP_ISUBI] 		= w_cr_result[`OP_ISUB];
	
	// OP_UISUBI
	assign	w_i_result[`OP_UISUBI] 		= w_cr_result[`OP_UISUB];
	
	// OP_IMULI
	assign	w_i_result[`OP_IMULI] 		= w_cr_result[`OP_IMUL];
	
	// OP_UIMULI
	assign	w_i_result[`OP_UIMULI] 		= w_cr_result[`OP_UIMUL];
	
	// OP_IDEVI
	assign	w_i_result[`OP_IDEVI] 		= w_cr_result[`OP_IDEV];
	
	// OP_UIDEVI
	assign	w_i_result[`OP_UIDEVI] 		= w_cr_result[`OP_UIDEV];
	
	// OP_LW
	assign	w_i_result[`OP_LW] 		= 0;
	
	// OP_ST
	assign	w_i_result[`OP_ST] 		= 0;
	
	// OP_LSFTI
	assign	w_i_result[`OP_LSFTI] 		= w_lr_result[`OP_LSFT];
	
	// OP_RSFTI
	assign	w_i_result[`OP_RSFTI] 		= w_lr_result[`OP_RSFT];
	
	// OP_BE
	assign	w_i_result[`OP_BE] 		= 0;
	
	// OP_BNE
	assign	w_i_result[`OP_BNE] 		= 0;
	
	// OP_CMPI
	assign	w_i_result[`OP_CMPI] 		= w_lr_result[`OP_CMP];
	
	// OP_UCMPI
	assign	w_i_result[`OP_UCMPI] 		= w_lr_result[`OP_UCMP];
	

	//
	// Jump
	//
	
	// OP_J
	assign	w_j_result[`OP_J] 		= 0;
	
	// OP_JAL
	assign	w_j_result[`OP_JAL] 		= 0;

	//OP_J_NOUSE2	2
	assign	w_j_result[`OP_J_NOUSE2] 	= 0;
	
	//OP_J_NOUSE3	3
	assign	w_j_result[`OP_J_NOUSE3] 	= 0;
	
	//OP_J_NOUSE4	
	assign	w_j_result[`OP_J_NOUSE4] 	= 0;
	
	//OP_J_NOUSE5	5
	assign	w_j_result[`OP_J_NOUSE5] 	= 0;
	
	//OP_J_NOUSE6	6
	assign	w_j_result[`OP_J_NOUSE6] 	= 0;
	
	//OP_J_NOUSE7	7
	assign	w_j_result[`OP_J_NOUSE7] 	= 0;
	
	//OP_J_NOUSE8	8
	assign	w_j_result[`OP_J_NOUSE8] 	= 0;
	
	//OP_J_NOUSE9	9
	assign	w_j_result[`OP_J_NOUSE9] 	= 0;
	
	//OP_J_NOUSE10	10
	assign	w_j_result[`OP_J_NOUSE10] 	= 0;
	
	//OP_J_NOUSE11	11
	assign	w_j_result[`OP_J_NOUSE11] 	= 0;
	
	//OP_J_NOUSE12	12
	assign	w_j_result[`OP_J_NOUSE12] 	= 0;
	
	//OP_J_NOUSE13	13
	assign	w_j_result[`OP_J_NOUSE13] 	= 0;
	
	//OP_J_NOUSE14	14
	assign	w_j_result[`OP_J_NOUSE14] 	= 0;
	
	//OP_J_NOUSE15	15
	assign	w_j_result[`OP_J_NOUSE15] 	= 0;

	//
	//  Interconnect
	//

	wire	[`WORD_BITS-1:0]	w_result_val;

	assign	w_result_val = 	(i_type==`TYPE_CR)? w_cr_result[i_op] :
				(i_type==`TYPE_LR)? w_lr_result[i_op] :
				(i_type==`TYPE_I)?  w_i_result [i_op] : w_j_result [i_op];
	always@(posedge clk)
	begin
		if(rst) begin
			r_result_val <= 0;
		end else begin
			r_result_val <= w_result_val;
		end
	end
	
	always@(posedge clk)
	begin
		if(rst) begin
			r_result_valid <= 0;
		end else begin
			r_result_valid <= i_calc_start;
		end
	end

	assign	o_result_val 	= r_result_val;
	assign	o_result_valid 	= r_result_valid;

endmodule	

`endif
