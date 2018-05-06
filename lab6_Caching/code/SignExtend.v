`timescale 1ns/100ps

module SignExtend (
	input [7:0] in,
	output[15:0] out
);

assign out = {{8{in[7]}}, in };

endmodule
