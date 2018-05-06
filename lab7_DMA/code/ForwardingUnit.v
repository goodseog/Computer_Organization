module ForwardingUnit (
    input       EX_MEM_RegWrite,
    input       MEM_WB_RegWrite,
    input [1:0] ID_EX_RegisterRs,
    input [1:0] ID_EX_RegisterRt,
    input [1:0] EX_MEM_RegisterRd,
    input [1:0] MEM_WB_RegisterRd,
    
    output [1:0] ForwardA,
    output [1:0] ForwardB
);
    assign ForwardA = ( MEM_WB_RegWrite && !( EX_MEM_RegWrite && ( EX_MEM_RegisterRd == ID_EX_RegisterRs )) && ( MEM_WB_RegisterRd == ID_EX_RegisterRs ) ) ? 2'b01 :
                                            ( EX_MEM_RegWrite && ( EX_MEM_RegisterRd == ID_EX_RegisterRs )) ? 2'b10 : 2'b00;  
    assign ForwardB = ( MEM_WB_RegWrite && !( EX_MEM_RegWrite && ( EX_MEM_RegisterRd == ID_EX_RegisterRt )) && ( MEM_WB_RegisterRd == ID_EX_RegisterRt ) ) ? 2'b01 :
                                            ( EX_MEM_RegWrite && ( EX_MEM_RegisterRd == ID_EX_RegisterRt )) ? 2'b10 : 2'b00;  
endmodule

/*
if (MEM/WB.RegWrite and (MEM/WB.RegisterRd != 0 and
    not (EX/MEM.RegWrite and (EX/MEM.RegisterRd != 0) and 
        (EX/MEM.RegisterRd == ID/EX.RegisterRs)) and
        (MEM/WB.RegisterRd = ID/EX.RegisterRs)) ForwardA = 01

if (MEM/WB.RegWrite and (MEM/WB.RegisterRd != 0)
 and not(EX/MEM.RegWrite and (EX/MEM.RegisterRd != 0)
 and (EX/MEM.RegisterRd == ID/EX.RegisterRt))
 and (MEM/WB.RegisterRd = ID/EX.RegisterRt)) ForwardB = 01


if (EX/MEM.RegWrite
and (EX/MEM.RegisterRd ?‰  0)
and (EX/MEM.RegisterRd = ID/EX.RegisterRs)) ForwardA = 10

if (EX/MEM.RegWrite
and (EX/MEM.RegisterRd ?‰  0)
and (EX/MEM.RegisterRd = ID/EX.RegisterRt)) ForwardB = 10
*/