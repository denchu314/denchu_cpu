///////////////////////////////////////////
// This modules is in modakio cpu.
// mCpu_ctrl module ver 1.0
// 2019/04/29 writen by denchu
//
`ifndef	_mCPU_CTRL_
`define	_mCPU_CTRL_
`include	"./define.v"

`define	STATE_READY		0
`define	STATE_FETCH		1
`define	STATE_WAIT_TO_FETCH	2
`define	STATE_CALC		3
`define	STATE_WAIT_TO_CALC	4
`define	STATE_WAIT_TO_LWST	5


module mCpu_ctrl (
	output				o_inst_complete,
	output				o_rw_enable,
	input				i_empty,
	input				i_fetch_complete,
	input	[`WORD_BITS-1:0]	i_inst,
	input				i_inst_valid,
	input				i_write_mem_complete,
	input				i_read_mem_complete,
	//output				o_jump_enable,
	output				o_calc_start,
	input				i_calc_complete,
	input	[`WORD_BITS-1:0]	i_src0,
	input	[`WORD_BITS-1:0]	i_src1,
	output				o_be_bne,
	
	input	[`WORD_BITS-1:0]	i_writedata,
	output	[`WORD_BITS-1:0]	o_readdata,
	output				o_readdatavalid,
	input	[1:0]			i_addr,
	input				i_read,
	input				i_write,
	output				o_permit_fetch,

	input				clk,
	input				rst
);

	///////////////////////////
	// MM interface
	// addr	|regiter
	// 0	|state
	// 4	|boot
	
	reg	[`WORD_BITS-1:0]	r_readdata;
	reg				r_readdatavalid;
	reg	[`WORD_BITS-1:0]	r_boot;
	
	always @(posedge clk)
	begin if(rst) begin
			r_readdata <= 0;
		end else if(i_addr == 0) begin
			r_readdata <= r_state;
		end else if(i_addr == 1) begin
			r_readdata <= r_boot;
		end
	end
	
	assign	o_readdata	= r_readdata;
	

	always @(posedge clk)
	begin if(rst) begin
			r_readdatavalid <= 1'b0;
		end else begin
			r_readdatavalid <= i_read;
		end
	end
      
	always @(posedge clk)
	begin	
		if (rst) begin
			r_boot <= 0;
		end else if((i_addr == 1)&&(i_write == 1'b1)) begin
			r_boot <= i_writedata;
		end
	end
	
	assign	o_readdatavalid	= r_readdatavalid;

	///////////////////////////////////
	// state machine
	//
	//
	reg	[3:0]	r_state;
	wire	w_ready_to_fetch;
	wire	w_______to_fetch;
	wire	w_fetch_to_waitToFetch;
	wire	w_waitToFetch_to_fetch;
	wire	w_waitToFetch_to_calc;
	wire	w_waitToFetch_to_waitToLwst;
	wire	w_calc_to_waitToCalc;
	wire	w_waitToCalc_to_fetch;
	wire	w_waitToCalc_to_waitToLwst;
	wire	w_waitToCalc_to_calc;
	wire	w_waitToLwst_to_fetch;
	wire	w_waitToLwst_to_calc;
	wire	w_waitToLwst_to_waitToLwst;
	
	always @(posedge clk)
	begin
		if(rst) begin
			r_state <= `STATE_READY;
		end else if((i_addr == 0) && (i_write==1'b1)) begin
			r_state	<= i_writedata;
		end else begin
			case (r_state)
				`STATE_READY:		if(w_ready_to_fetch)			r_state <= `STATE_FETCH;
				`STATE_FETCH:		if(w_fetch_to_waitToFetch) 		r_state <= `STATE_WAIT_TO_FETCH;
				`STATE_WAIT_TO_FETCH: 	if(w_waitToFetch_to_fetch) 		r_state <= `STATE_FETCH;
							else if(w_waitToFetch_to_calc) 		r_state <= `STATE_CALC;
							else if(w_waitToFetch_to_waitToLwst) 	r_state <= `STATE_WAIT_TO_LWST;
							else if(w_______to_fetch) 		r_state <= `STATE_FETCH;
				`STATE_CALC: 		if(w_calc_to_waitToCalc) 		r_state <= `STATE_WAIT_TO_CALC;
					 		else if(w_______to_fetch) 		r_state <= `STATE_FETCH;
				`STATE_WAIT_TO_CALC: 	if(w_waitToCalc_to_fetch) 		r_state <= `STATE_FETCH;
							else if(w_waitToCalc_to_waitToLwst)	r_state	<= `STATE_WAIT_TO_LWST;
							else if(w_waitToCalc_to_calc)		r_state	<= `STATE_CALC;
							else if(w_______to_fetch)		r_state	<= `STATE_FETCH;
				`STATE_WAIT_TO_LWST: 	if(w_waitToLwst_to_fetch) 		r_state <= `STATE_FETCH;
							else if(w_waitToLwst_to_calc)		r_state	<= `STATE_CALC;
							else if(w_waitToCalc_to_waitToLwst)	r_state	<= `STATE_WAIT_TO_LWST;
							else if(w_______to_fetch)		r_state	<= `STATE_FETCH;
			endcase
		end
	end

	wire	[`TYPE_BITS	-1:0]				w_type;
	wire	[  `OP_BITS	-1:0]				w_op;
	assign	w_type	=	i_inst[`TYPE_BITS	+`TYPE_OFFSET-1	:`TYPE_OFFSET];
	assign	w_op	=	i_inst[  `OP_BITS	+  `OP_OFFSET-1	:  `OP_OFFSET];

	wire	w_lwst;
	wire	w_jump;
	wire	w_calc;
	
	assign	w_lwst	= (i_inst_valid == 1'b1) && ((w_type == `TYPE_I) && ((w_op == `OP_LW) || (w_op == `OP_ST)))? 1'b1 : 1'b0;
	assign	w_jump	= ((i_inst_valid == 1'b1) && (((w_type == `TYPE_LR) && (w_op == `OP_JR)) || ((w_type == `TYPE_J) && ((w_op == `OP_J) || (w_op == `OP_JAL))))) || (w_be || w_bne)? 1'b1 : 1'b0;
	assign	w_calc	= (i_inst_valid == 1'b1) && (((w_lwst==0) && (w_jump==0)))? 1'b1 : 1'b0;

	assign	w_ready_to_fetch		= (r_boot == 1)? 1'b1 : 1'b0;
	assign	w_______to_fetch		= (w_type == `TYPE_J && i_inst_valid == 1)? 1'b1 : 1'b0;
	//assign	w_fetch_to_waitToFetch		= 1'b1;
	assign	w_fetch_to_waitToFetch		= (r_permit_fetch_count >= (`BURST_LENGTH-1)) ? 1 : 0;
	assign	w_waitToFetch_to_fetch		= (i_fetch_complete == 1'b1) && (w_jump == 1'b1);
	assign	w_waitToFetch_to_calc		= (i_fetch_complete == 1'b1) && (w_calc == 1'b1);
	assign	w_waitToFetch_to_waitToLwst	= (i_fetch_complete == 1'b1) && (w_lwst == 1'b1) ;
	assign	w_calc_to_waitToCalc		= 1'b1;
	assign	w_waitToCalc_to_fetch		= (r_calc_complete_next == 1'b1) && (((i_empty == 1'b0) && (w_jump == 1'b1))||(i_empty == 1'b1));
	assign	w_waitToCalc_to_waitToLwst	= (r_calc_complete_next == 1'b1) && ((i_empty == 1'b0) && (w_lwst == 1'b1));
	assign	w_waitToCalc_to_calc		= (r_calc_complete_next == 1'b1) && ((i_empty == 1'b0) && (w_calc == 1'b1));
	assign	w_waitToLwst_to_fetch		= ((r_write_mem_complete_next == 1'b1) || (r_read_mem_complete_next == 1'b1)) && (((i_empty == 1'b0) && (w_jump == 1'b1)) || (i_empty == 1'b1));
	assign	w_waitToLwst_to_calc		= ((r_write_mem_complete_next == 1'b1) || (r_read_mem_complete_next == 1'b1)) && ((i_empty == 1'b0) && (w_calc == 1'b1));
	assign	w_waitToLwst_to_waitToLwst	= ((r_write_mem_complete_next == 1'b1) || (r_read_mem_complete_next == 1'b1)) && ((i_empty == 1'b0) && (w_lwst == 1'b1));

	assign	o_calc_start = (r_state == `STATE_CALC)? 1'b1 : 1'b0;

	reg	r_write_mem_complete_next;	
	reg	r_read_mem_complete_next;	
	reg	r_calc_complete_next;	
	reg	[2:0]	r_permit_fetch_count;

	always @(posedge clk)
	begin	
		if (rst) begin
			r_write_mem_complete_next <= 1'b0;
		end else begin
			r_write_mem_complete_next <= i_write_mem_complete;
		end
	end
      
	always @(posedge clk)
	begin	
		if (rst) begin
			r_read_mem_complete_next <= 1'b0;
		end else begin
			r_read_mem_complete_next <= i_read_mem_complete;
		end
	end
      
	always @(posedge clk)
	begin	
		if (rst) begin
			r_calc_complete_next <= 1'b0;
		end else begin
			r_calc_complete_next <= i_calc_complete;
		end
	end
	
	always @(posedge clk)
	begin	
		if (rst) begin
			r_permit_fetch_count <= 0;
		//end else if ((w_ready_to_fetch || w_waitToCalc_to_fetch) || (w_waitToFetch_to_fetch || w_waitToLwst_to_fetch)) begin
		//	r_calc_complete_next <= 0;
		end else if (r_state == `STATE_FETCH) begin
			r_permit_fetch_count <= r_permit_fetch_count + 1;
		end else begin
			r_permit_fetch_count <= 0;
		end
	end
	
	//assign	o_inst_complete = (i_write_mem_complete==1'b1) || ((i_read_mem_complete==1'b1) || (i_calc_complete==1'b1);
	assign	o_inst_complete = (i_write_mem_complete==1'b1) || ((i_read_mem_complete==1'b1) || (i_calc_complete==1'b1)) || (w_type == `TYPE_J && i_inst_valid == 1);
	
	wire	w_be;
	wire	w_bne;
	assign	w_be	= (((i_inst_valid==1'b1)&&(w_type==`TYPE_I))&&((w_op==`OP_BE)&&(i_src0==i_src1)))? 1'b1 : 1'b0;
	assign	w_bne	= (((i_inst_valid==1'b1)&&(w_type==`TYPE_I))&&((w_op==`OP_BNE)&&(i_src0!=i_src1)))? 1'b1 : 1'b0;
	//assign	w_be	= (((i_inst_valid==1'b1)))? 1'b1 : 1'b0;
	//assign	w_bne	= (((i_inst_valid==1'b1)))? 1'b1 : 1'b0;
	//assign	w_be	= (((w_op==`OP_BE)&&(i_src0==i_src1)))? 1'b1 : 1'b0;
	//assign	w_bne	= (((w_op==`OP_BNE)&&(i_src0!=i_src1)))? 1'b1 : 1'b0;
	assign	o_be_bne = (w_be || w_bne)? 1'b1 : 1'b0;
	assign	o_permit_fetch	= (r_state == `STATE_FETCH) ? 1'b1 : 1'b0;
	//assign	o_jump_enable = (((i_inst_valid == 1) && (w_type == `TYPE_J)) && ((r_calc_complete_next == 1)||(r_write_mem_complete_next==1||r_read_mem_complete_next==1) && (i_empty == 0)))? 1 : 0;
	assign	o_rw_enable = (r_state == `STATE_WAIT_TO_LWST)? 1 : 0;
endmodule
`endif
