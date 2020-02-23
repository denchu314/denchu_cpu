////////////////////////////////
// modakio cpu operation number
// operation number

// func log2
//function integer log2;
//	input integer in;
//	begin
//		in = in - 1;
//		for (log2 = 0; in > 0; log2 = log2+1)
//			in = in >> 1;
//	end
//endfunction



// 
// CalcReg(CR)
// 
`define TYPE_CR		0
// interger
`define	OP_IADD		0
`define	OP_UIADD	1
`define	OP_ISUB		2
`define	OP_UISUB	3
`define	OP_IMUL		4
`define	OP_UIMUL	5
`define	OP_IDEV		6
`define	OP_UIDEV	7

//floating point 
`define	OP_FADD		8
`define	OP_FCMP		9
`define	OP_FSUB		10
`define	OP_CR_NOUSE11	11
`define	OP_FMUL		12
`define	OP_CR_NOUSE13	13
`define	OP_FDEV		14
`define	OP_CR_NOUSE15	15

// 
// LogicReg(LR)
// 
`define TYPE_LR		1

// bit logical

`define	OP_AND		0
`define	OP_OR		1
`define	OP_XOR		2
`define	OP_UCMP		3
`define	OP_LSFT		4
`define	OP_RSFT		5
`define	OP_CMP		6
`define	OP_JR		7

`define	OP_LR_NOUSE8	8
`define	OP_LR_NOUSE9	9
`define	OP_LR_NOUSE10	10
`define	OP_LR_NOUSE11	11
`define	OP_LR_NOUSE12	12
`define	OP_LR_NOUSE13	13
`define	OP_LR_NOUSE14	14
`define	OP_LR_NOUSE15	15


// 
// Immediate
// 
`define TYPE_I		2

`define	OP_IADDI	0
`define	OP_UIADDI	1
`define	OP_ISUBI	2
`define	OP_UISUBI	3
`define	OP_IMULI	4
`define	OP_UIMULI	5
`define	OP_IDEVI	6
`define	OP_UIDEVI	7

`define	OP_LW		8
`define	OP_ST		9
`define	OP_LSFTI	10
`define	OP_RSFTI	11
`define	OP_BE		12
`define	OP_BNE		13
`define	OP_CMPI		14
`define	OP_UCMPI	15


// 
// Jump
// 
`define TYPE_J		3

`define	OP_J		0
`define	OP_JAL		1
`define	OP_J_NOUSE2	2
`define	OP_J_NOUSE3	3
`define	OP_J_NOUSE4	4
`define	OP_J_NOUSE5	5
`define	OP_J_NOUSE6	6
`define	OP_J_NOUSE7	7

`define	OP_J_NOUSE8	8
`define	OP_J_NOUSE9	9
`define	OP_J_NOUSE10	10
`define	OP_J_NOUSE11	11
`define	OP_J_NOUSE12	12
`define	OP_J_NOUSE13	13
`define	OP_J_NOUSE14	14
`define	OP_J_NOUSE15	15

`define	NUM_OF_OP	42

//
// HARDWARE DISCRIPTION
//
`define	NUM_OF_FETCH_INST	4
`define	INST_FIFO_LENGTH	`NUM_OF_FETCH_INST * 2

`define WORD_BITS	32
`define	NUM_OF_REG	32
`define REG_ADDR_BITS	5 
`define MEM_ADDR_BITS	18

`define BITS_PER_BYTE	8

`define INST_BITS	`WORD_BITS
`define TYPE_BITS	2
`define OP_BITS		4
`define DST_BITS	5
`define SRC0_BITS	5
`define SRC1_BITS	5
`define MINOR_IMM_BITS	16
`define MAJOR_IMM_BITS	26

`define TYPE_OFFSET	`INST_BITS - `TYPE_BITS
`define OP_OFFSET	`INST_BITS - `TYPE_BITS - `OP_BITS
`define DST_OFFSET	`INST_BITS - `TYPE_BITS - `OP_BITS - `DST_BITS
`define SRC0_OFFSET	`INST_BITS - `TYPE_BITS - `OP_BITS - `DST_BITS - `SRC0_BITS
`define SRC1_OFFSET	`INST_BITS - `TYPE_BITS - `OP_BITS - `DST_BITS - `SRC0_BITS - `SRC1_BITS
`define MINOR_IMM_OFFSET	`INST_BITS - `TYPE_BITS - `OP_BITS - `DST_BITS - `SRC0_BITS - `MINOR_IMM_BITS
`define MAJOR_IMM_OFFSET	`INST_BITS - `TYPE_BITS - `OP_BITS - `MAJOR_IMM_BITS

`define BURST_LENGTH	4
