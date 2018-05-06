// DEFINITIONS
`define WORD_SIZE 16    // data and address word size

module Datapath(
	input [`WORD_SIZE-1:0] instruction,
	
	output[`WORD_SIZE-1:0] nxt_address,
	output[`WORD_SIZE-1:0] output_port, // for "WWD" instruction
	
	// input from Control Unit module
	input [`WORD_SIZE-1:0] cur_address,
	input RegDst,
	input Jump,
	input Branch,
	input MemtoReg,
	input MemRead,
	input MemWrite,
	input[3:0] ALUOp,
	input ALUSrcB,
	input RegWrite,
	input RegOutput,
	
	input clk,
	input reset_n
);

wire[3:0] w_OP;

wire w_bcond;
wire[1:0] rs, rt, rd, rw;
wire[5:0] funct;
wire[7:0] imm;
wire[11:0] jaddr;
wire[`WORD_SIZE-1:0] w_data1, w_data2, w_data3, immExt, w_A, w_B, w_C,
                     w_address_Next, w_address_Branch, w_address_bcond, w_address_Jump;

wire Zero;

assign rs    = instruction[11:10];
assign rt    = instruction[ 9: 8];
assign rd    = instruction[ 7: 6];
assign funct = instruction[ 5: 0];
assign imm   = instruction[ 7: 0];
assign jaddr = instruction[11: 0];

assign w_A     = w_data1;
assign w_data3 = w_C;

assign w_address_Next   = cur_address + 1;
assign w_address_Branch = cur_address + 1 + immExt ;
assign w_address_Jump   = { cur_address[15:12], jaddr};

//assign output_data = ;

Mux #(
	.WIDTH(2)
) muxRegDst (
	.A0 ( rt ),
	.A1 ( rd ),
	.sel( RegDst ),
	.S0 ( rw )
);

Mux #(
	.WIDTH(`WORD_SIZE)
) muxALUSrc (
	.A0 ( w_data2 ),
	.A1 ( immExt ),
	.sel( ALUSrcB ),
	.S0 ( w_B )
);

Mux #(
	.WIDTH(`WORD_SIZE)
) muxBranch (
	.A0 ( w_address_Next ),
	.A1 ( w_address_Branch ),
	.sel( Branch & w_bcond ),
	.S0 ( w_address_bcond )
);

Mux #(
	.WIDTH(`WORD_SIZE)
) muxJump (
	.A0 ( w_address_bcond ),
	.A1 ( w_address_Jump ),
	.sel( Jump ),
	.S0 ( nxt_address )
);

Mux #(
	.WIDTH(`WORD_SIZE)
) muxRegOutput (
.A0 ( `WORD_SIZE'bz ),
.A1 ( w_A ),
.sel( RegOutput ),
.S0 ( output_port )
);


RegisterFile rf(
	.Addr1( rs ),
	.Addr2( rt ),
	.Addr3( rw ),
	.Data1( w_data1 ),
	.Data2( w_data2 ),
	.Data3( w_data3 ),
	.Write( RegWrite ),
	.clk( clk ),
	.reset_n( reset_n )
);

SignExtend se(
	.in(imm),
	.out(immExt)
);

ALUControl aluc(
	.ALUOp(ALUOp),
	.funct(funct),
	.OP(w_OP)
);

ALU alu(
	.A(w_A),
	.B(w_B),
	.Cin(1'b0),
	.OP(w_OP),
	.C(w_C),
	.Cout(),
	.Zero(Zero)
);

endmodule
