`timescale 1ns/100ps

module Mux #(
	parameter WIDTH = 16
)
(
  input [ WIDTH - 1 : 0 ] A0,
  input [ WIDTH - 1 : 0 ] A1,
  input sel,
  output [ WIDTH -1 : 0 ] S0
);

  assign S0 = sel ? A1 : A0 ;
endmodule
